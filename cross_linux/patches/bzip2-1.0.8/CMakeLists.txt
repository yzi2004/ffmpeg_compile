
cmake_minimum_required (VERSION 3.1)
project (bzip2 C)

set (MAJOR_VERSION 1)
set (MINOR_VERSION 0)
set (VERSION_PATCH 8)
set (VERSION 1.0.8)

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")
set(INSTALL_MAN_DIR "${CMAKE_INSTALL_PREFIX}/share/man" CACHE PATH "Installation directory for manual pages")
set(INSTALL_PKGCONFIG_DIR "${INSTALL_LIB_DIR}/pkgconfig" CACHE PATH "Installation directory for pkgconfig (.pc) files")

include(CMakeOptions.txt)

if(ENABLE_LIB_ONLY AND (ENABLE_APP OR ENABLE_EXAMPLES))
    # Remember when disabled options are disabled for later diagnostics.
    set(ENABLE_LIB_ONLY_DISABLED_OTHERS 1)
else()
    set(ENABLE_LIB_ONLY_DISABLED_OTHERS 0)
endif()

if(ENABLE_LIB_ONLY)
    set(ENABLE_APP      OFF)
    set(ENABLE_EXAMPLES OFF)
endif()

include(CheckIncludeFile)
check_include_file(arpa/inet.h    HAVE_ARPA_INET_H)
check_include_file(fcntl.h        HAVE_FCNTL_H)
check_include_file(inttypes.h     HAVE_INTTYPES_H)
check_include_file(limits.h       HAVE_LIMITS_H)
check_include_file(netdb.h        HAVE_NETDB_H)
check_include_file(netinet/in.h   HAVE_NETINET_IN_H)
check_include_file(pwd.h          HAVE_PWD_H)
check_include_file(sys/socket.h   HAVE_SYS_SOCKET_H)
check_include_file(sys/time.h     HAVE_SYS_TIME_H)
check_include_file(syslog.h       HAVE_SYSLOG_H)
check_include_file(time.h         HAVE_TIME_H)
check_include_file(unistd.h       HAVE_UNISTD_H)

include(CheckTypeSize)

# Checks for typedefs, structures, and compiler characteristics.
# AC_TYPE_SIZE_T
check_type_size("ssize_t" SIZEOF_SSIZE_T)
if(NOT SIZEOF_SSIZE_T)
    # ssize_t is a signed type in POSIX storing at least -1.
    # Set it to "int" to match the behavior of AC_TYPE_SSIZE_T (autotools).
    set(ssize_t int)
endif()

include(CheckStructHasMember)
check_struct_has_member("struct tm" tm_gmtoff time.h HAVE_STRUCT_TM_TM_GMTOFF)

# Checks for library functions.
include(CheckFunctionExists)
check_function_exists(_Exit     HAVE__EXIT)
check_function_exists(accept4   HAVE_ACCEPT4)
check_function_exists(mkostemp  HAVE_MKOSTEMP)

include(CheckSymbolExists)

# XXX does this correctly detect initgroups (un)availability on cygwin?
check_symbol_exists(initgroups grp.h HAVE_DECL_INITGROUPS)
if(NOT HAVE_DECL_INITGROUPS AND HAVE_UNISTD_H)
    # FreeBSD declares initgroups() in unistd.h
    check_symbol_exists(initgroups unistd.h HAVE_DECL_INITGROUPS2)
    if(HAVE_DECL_INITGROUPS2)
        set(HAVE_DECL_INITGROUPS 1)
    endif()
endif()

# bz2.pc (pkg-config file)
set(prefix      ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(bindir      ${INSTALL_BIN_DIR})
set(libdir      ${INSTALL_LIB_DIR})
set(includedir  ${INSTALL_INC_DIR})
set(VERSION     ${VERSION})

configure_file(
    bz2.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/bz2.pc
    @ONLY)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/bz2.pc
    DESTINATION ${INSTALL_PKGCONFIG_DIR})

#
# The build targets.
#   In a larger project, the following would be in subdirectories and
#   These targets would be included with `add_subdirectory()`
#
set(BZ2_SOURCES
    blocksort.c
    huffman.c
    crctable.c
    randtable.c
    compress.c
    decompress.c
    bzlib.c)

# The bz2 OBJECT-library, required for bzip2, bzip2recover.
add_library(bz2_ObjLib OBJECT)
target_sources(bz2_ObjLib
    PRIVATE   ${BZ2_SOURCES}
    PUBLIC    ${CMAKE_CURRENT_SOURCE_DIR}/bzlib_private.h
    INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/bzlib.h)

add_library(bz2 STATIC)
target_sources(bz2
        PRIVATE     ${BZ2_SOURCES}
        PUBLIC      ${CMAKE_CURRENT_SOURCE_DIR}/bzlib_private.h
        INTERFACE   ${CMAKE_CURRENT_SOURCE_DIR}/bzlib.h)
target_compile_definitions(bz2 PUBLIC BZ2_STATICLIB)
install(TARGETS bz2 DESTINATION ${INSTALL_LIB_DIR})
install(FILES bzlib.h DESTINATION ${INSTALL_INC_DIR})

if(ENABLE_APP)
    # The bzip2 executable.
    add_executable(bzip2)
    target_sources(bzip2
        PRIVATE   bzip2.c)
    target_link_libraries(bzip2
        PRIVATE   bz2_ObjLib)
    if(WIN32)
        target_compile_definitions(bzip2 PUBLIC BZ_LCCWIN32 BZ_UNIX=0)
    else()
        target_compile_definitions(bzip2 PUBLIC BZ_LCCWIN32=0 BZ_UNIX)
    endif()
    install(TARGETS bzip2 DESTINATION ${INSTALL_BIN_DIR})

    # The bzip2recover executable.
    add_executable(bzip2recover)
    target_sources(bzip2recover
        PRIVATE   bzip2recover.c)
    target_link_libraries(bzip2recover
        PRIVATE bz2_ObjLib)
    if(WIN32)
        target_compile_definitions(bzip2recover PUBLIC BZ_LCCWIN32 BZ_UNIX=0)
    else()
        target_compile_definitions(bzip2recover PUBLIC BZ_LCCWIN32=0 BZ_UNIX)
    endif()
    install(TARGETS bzip2recover DESTINATION ${INSTALL_BIN_DIR})

    if(NOT WIN32)
        # Install shell scripts, and renamed copies.
        install(PROGRAMS bzdiff bzgrep bzmore
            DESTINATION ${INSTALL_BIN_DIR})
    endif()

endif()

if(ENABLE_LIB_ONLY_DISABLED_OTHERS)
    message("Only the library will be built. To build other components "
            "(such as applications and examples), set ENABLE_LIB_ONLY=OFF.")
endif()

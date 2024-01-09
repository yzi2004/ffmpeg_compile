cmake_minimum_required(VERSION 3.0)

project (mp3lame C CXX ASM)

set (MAJOR_VERSION 3)
set (MINOR_VERSION 100)
set (VERSION 3.100)

#if(WIN32)
#	add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/Dll)
#endif()

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")
set(INSTALL_PKGCONFIG_DIR "${INSTALL_LIB_DIR}/pkgconfig" CACHE PATH "Installation directory for pkgconfig (.pc) files")


add_definitions(-DHAVE_STDINT_H)
add_definitions(-DHAVE_MPGLIB)
add_definitions(-DDECODE_ON_THE_FLY)
add_definitions(-DUSE_FAST_LOG)
add_definitions(-DTAKEHIRO_IEEE754_HACK)

if((${CMAKE_CXX_COMPILER_ID} STREQUAL MSVC))
	add_definitions(-DUSE_LAYER_2)
	add_definitions(-DHAVE_CONFIG_H)
	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-D_CRT_SECURE_NO_DEPRECATED)
	configure_file(configMS.h config.h @ONLY)
else()
	add_definitions(-DSTDC_HEADERS)
	if(NOT ieee754_float32_t)
		add_definitions(-Dieee754_float32_t=float)
	endif()
endif()

aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/libmp3lame SOURCE_LIB)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/libmp3lame/vector/ SOURCE_LIB)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/mpglib SOURCE_LIB)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libmp3lame)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/mpglib)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_library(${PROJECT_NAME} STATIC ${SOURCE_LIB})

target_include_directories(${PROJECT_NAME} 
	PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

install(TARGETS ${PROJECT_NAME} DESTINATION ${INSTALL_LIB_DIR})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/lame.h DESTINATION ${INSTALL_INC_DIR}/lame)

# bzip2.pc (pkg-config file)
set(prefix      ${CMAKE_INSTALL_PREFIX})
set(exec_prefix ${CMAKE_INSTALL_PREFIX})
set(bindir      ${INSTALL_BIN_DIR})
set(libdir      ${INSTALL_LIB_DIR})
set(includedir  ${INSTALL_INC_DIR})
set(VERSION     ${VERSION})

configure_file(
    lame.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/lame.pc
    @ONLY)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/lame.pc
    DESTINATION ${INSTALL_PKGCONFIG_DIR})
 #Default Settings, for user to be vigilant about x265 version being reported during product build.
set (BZIP2_MAJOR_VERSION 1)
set (BZIP2_MINOR_VERSION 0)
set (BZIP2_VERSION_PATCH 8)
set (BZIP2_VERSION ${BZIP2_MAJOR_VERSION}.{BZIP2_MINOR_VERSION}.{BZIP2_VERSION_PATCH})

#Find version control software to be used for live and extracted repositories from compressed tarballs
set(GIT_ARCHETYPE OFF)
find_package(Git QUIET) 
if(GIT_FOUND)
    find_program(GIT_EXECUTABLE git)
    message(STATUS "GIT_EXECUTABLE ${GIT_EXECUTABLE}")
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)
        set(GIT_ARCHETYPE ON)
    endif()
endif(GIT_FOUND)

if(GIT_ARCHETYPE)
execute_process(
        COMMAND
        ${GIT_EXECUTABLE} describe --abbrev=0 --tags
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        OUTPUT_VARIABLE VERSION_TAG
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
endif(GIT_ARCHETYPE)

if(VERSION_TAG MATCHES "bzip2-")
    string(REGEX MATCH "^([A-Za-z0-9_]*)-([0-9]+)\\.([0-9]+)\\.([0-9]+)" VERSION_TAG ${VERSION_TAG})
	set(BZIP2_MAJOR_VERSION ${CMAKE_MATCH_2})
	set(BZIP2_MINOR_VERSION ${CMAKE_MATCH_3})
	set(BZIP2_VERSION_PATCH ${CMAKE_MATCH_4})
endif()

message(STATUS "bzip2 VERSION ${bzip2_VERSION}")

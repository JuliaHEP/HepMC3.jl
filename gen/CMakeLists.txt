cmake_minimum_required(VERSION 3.21)
project(HepMC3Wrap)

set(CMAKE_MACOSX_RPATH 1)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

#---Find JlCxx package-------------------------------------------------------------
find_package(JlCxx)
get_target_property(JlCxx_location JlCxx::cxxwrap_julia LOCATION)
get_filename_component(JlCxx_location ${JlCxx_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${JlCxx_location}")
message(STATUS "Found JlCxx at ${JlCxx_location}")

#---Find HepMC3---------------------------------------------------------------------
find_package(HepMC3 REQUIRED)
find_package(ZLIB REQUIRED)
file(REAL_PATH ${CMAKE_SOURCE_DIR}/../gen SOURCE_DIR)
file(GLOB GEN_SOURCES CONFIGURE_DEPENDS  ${SOURCE_DIR}/cpp/Jl*.cxx)
add_library(HepMC3Wrap SHARED 
    ${SOURCE_DIR}/cpp/HepMC3Wrap.cxx 
    ${SOURCE_DIR}/cpp/HepMC3WrapImpl.cpp  # Add this line
    ${SOURCE_DIR}/cpp/jlHepMC3.cxx 
    ${GEN_SOURCES})

target_include_directories(HepMC3Wrap PRIVATE ${SOURCE_DIR})

#Comment this out 
target_compile_definitions(HepMC3Wrap PRIVATE HEPMC3_USE_COMPRESSION=1)


target_link_libraries(HepMC3Wrap 
    JlCxx::cxxwrap_julia 
    JlCxx::cxxwrap_julia_stl 
    HepMC3::HepMC3
    ZLIB::ZLIB)

install(TARGETS HepMC3Wrap
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib
        RUNTIME DESTINATION lib)


        


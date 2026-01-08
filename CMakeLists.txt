cmake_minimum_required(VERSION 3.20)

project(aura_glow
  VERSION 0.1.0
  DESCRIPTION "Aura Glow - On-device beauty-tech vision engine (core scaffolding)"
  LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(AURAGLOW_BUILD_DEMO "Build demo app" ON)

add_subdirectory(engine)

if(AURAGLOW_BUILD_DEMO)
  add_subdirectory(apps/demo)
endif()

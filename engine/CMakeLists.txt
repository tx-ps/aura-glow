add_library(auraglow_engine
  src/engine.cpp
)

target_include_directories(auraglow_engine
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_features(auraglow_engine PUBLIC cxx_std_17)

if(MSVC)
  target_compile_options(auraglow_engine PRIVATE /W4 /permissive-)
else()
  target_compile_options(auraglow_engine PRIVATE -Wall -Wextra -Wpedantic)
endif()

add_executable(auraglow_demo main.cpp)
target_link_libraries(auraglow_demo PRIVATE auraglow_engine)

if(MSVC)
  target_compile_options(auraglow_demo PRIVATE /W4 /permissive-)
else()
  target_compile_options(auraglow_demo PRIVATE -Wall -Wextra -Wpedantic)
endif()

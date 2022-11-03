cmake_minimum_required(VERSION 3.10)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(PROJECT_NAME "ImGui")

project(${PROJECT_NAME} CXX)

set(SOURCES
    "imconfig.h"
    "imgui_demo.cpp"
    "imgui_draw.cpp"
    "imgui_widgets.cpp"
    "imgui_tables.cpp"
    "imgui_internal.h"
    "imgui.cpp"
    "imgui.h"
    "imstb_rectpack.h"
    "imstb_textedit.h"
    "imstb_truetype.h"
    "misc/freetype/imgui_freetype.cpp"
    "misc/freetype/imgui_freetype.h"
)

add_library(${PROJECT_NAME} STATIC
    ${SOURCES}
)

target_link_libraries(${PROJECT_NAME}
    FreeType2
)

target_include_directories(${PROJECT_NAME}
    PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}"
)

EASE_configure_library(${PROJECT_NAME} "")


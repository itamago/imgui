---------------------------------------
 README FIRST
---------------------------------------

Dear ImGui is highly portable and only requires a few things to run and render:

 - Providing mouse/keyboard inputs
 - Uploading the font atlas texture into graphics memory
 - Providing a render function to render indexed textured triangles
 - Optional: clipboard support, mouse cursor supports, Windows IME support, etc.
 - Optional (Advanced,Beta): platform window API to use multi-viewport.

This is essentially what the example bindings in this folder are providing + obligatory portability cruft.

It is important to understand the difference between the core Dear ImGui library (files in the root folder)
and examples bindings which we are describing here (examples/ folder).
You should be able to write bindings for pretty much any platform and any 3D graphics API. With some extra
effort you can even perform the rendering remotely, on a different machine than the one running the logic.

This folder contains two things:

 - Example bindings for popular platforms/graphics API, which you can use as is or adapt for your own use.
   They are the imgui_impl_XXXX files found in the examples/ folder.

 - Example applications (standalone, ready-to-build) using the aforementioned bindings.
   They are the in the XXXX_example/ sub-folders.

You can find binaries of some of those example applications at: 
  http://www.miracleworld.net/imgui/binaries


---------------------------------------
 MISC COMMENTS AND SUGGESTIONS
---------------------------------------

 - Newcomers, read 'PROGRAMMER GUIDE' in imgui.cpp for notes on how to setup ImGui in your codebase.

 - Please read the comments and instruction at the top of each file.

 - If you are using of the backend provided here, so you can copy the imgui_impl_xxx.cpp/h files
   to your project and use them unmodified. Each imgui_impl_xxxx.cpp comes with its own individual
   ChangeLog at the top of the .cpp files, so if you want to update them later it will be easier to
   catch up with what changed.

 - To LEARN how to setup imgui, you may refer to 'opengl2_example/' because is the simplest one to read.
   However, do NOT USE the OpenGL2 renderer if your code is using any modern GL3+ calls.
   Mixing old fixed-pipeline OpenGL2 and modern OpenGL3+ is going to make everything more complicated.
   Read comments below for details. If you are not sure, in doubt, use the OpenGL3 renderer.

 - Dear ImGui has 0 to 1 frame of lag for most behaviors, at 60 FPS your experience should be pleasant.
   However, consider that OS mouse cursors are typically drawn through a specific hardware accelerated path
   and will feel smoother than common GPU rendered contents (including Dear ImGui windows). 
   You may experiment with the io.MouseDrawCursor flag to request ImGui to draw a mouse cursor itself, 
   to visualize the lag between a hardware cursor and a software cursor. However, rendering a mouse cursor
   at 60 FPS will feel slow. It might be beneficial to the user experience to switch to a software rendered
   cursor only when an interactive drag is in progress. 
   Note that some setup or GPU drivers are likely to be causing extra lag depending on their settings.
   If you are not sure who to blame if you feeling that dragging something is laggy, try to build an
   application drawing a shape directly under the mouse cursor. 


---------------------------------------
 EXAMPLE BINDINGS
---------------------------------------

Most the example bindings are split in 2 parts:

 - The "Platform" bindings, in charge of: mouse/keyboard/gamepad inputs, cursor shape, timing, windowing.
   Examples: Windows (imgui_impl_win32.cpp), GLFW (imgui_impl_glfw.cpp), SDL2 (imgui_impl_sdl2.cpp)

 - The "Renderer" bindings, in charge of: creating the main font texture, rendering imgui draw data.
   Examples: DirectX11 (imgui_impl_dx11.cpp), GL3 (imgui_impl_opengl3.cpp), Vulkan (imgui_impl_vulkan.cpp)

 - The example _applications_ usually combine 1 platform + 1 renderer binding to create a working program.
   Examples: the directx11_example/ application combines imgui_impl_win32.cpp + imgui_impl_dx11.cpp.

 - Some bindings for higher level frameworks carry both "Platform" and "Renderer" parts in one file.
   This is the case for Allegro 5 (imgui_impl_allegro5.cpp), Marmalade (imgui_impl_marmalade5.cpp).

 - If you use your own engine, you may decide to use some of existing bindings and/or rewrite some using 
   your own API. As a recommendation, if you are new to Dear ImGui, try using the existing binding as-is
   first, before moving on to rewrite some of the code. Although it is tempting to rewrite both of the 
   imgui_impl_xxxx files to fit under your coding style, consider that it is not necessary!
   In fact, if you are new to Dear ImGui, rewriting them will almost always be harder.

   Example: your engine is built over Windows + DirectX11 but you have your own high-level rendering system 
   layered over DirectX11.
     Suggestion: step 1: try using imgui_impl_win32.cpp + imgui_impl_dx11.cpp first. 
     Once this work, _if_ you want you can replace the imgui_impl_dx11.cpp code with a custom renderer 
     using your own functions, etc. 
     Please consider using the bindings to the lower-level platform/graphics API as-is.

   Example: your engine is multi-platform (consoles, phones, etc.), you have high-level systems everywhere.
     Suggestion: step 1: try using a non-portable binding first (e.g. win32 + underlying graphics API)!
     This is counter-intuitive, but this will get you running faster! Once you better understand how imgui
     works and is bound, you can rewrite the code using your own systems.

 - From Dear ImGui 1.XX we added an (optional) feature called "viewport" which allows imgui windows to be 
   seamlessly detached from the main application window. This is achieved using an extra layer to the 
   platform and renderer bindings, which allows imgui to communicate platform-specific requests such as 
   "create an additional OS window", "create a render context", "get the OS position of this window" etc. 
   When using this feature, the coupling with your OS/renderer becomes much tighter than a regular imgui 
   integration. It is also much more complicated and require more work to integrate correctly.
   If you are new to imgui and you are trying to integrate it into your application, first try to ignore
   everything related to Viewport and Platform Windows. You'll be able to come back to it later!
   Note that if you decide to use unmodified imgui_impl_xxxx.cpp files, you will automatically benefit from 
   improvements and fixes related to viewports and platform windows without extra work on your side.
   See 'ImGuiPlatformIO' for details.  

List of officially maintained Platforms Bindings:

    imgui_impl_glfw.cpp
    imgui_impl_sdl2.cpp
    imgui_impl_win32.cpp

List of officially maintained Renderer Bindings:

    imgui_impl_dx9.cpp
    imgui_impl_dx10.cpp
    imgui_impl_dx11.cpp
    imgui_impl_dx12.cpp
    imgui_impl_opengl2.cpp
    imgui_impl_opengl3.cpp
    imgui_impl_vulkan.cpp

List of officially maintained high-level Frameworks Bindings (combine Platform + Renderer)

    imgui_impl_allegro5.cpp
    imgui_impl_marmalade.cpp

Third-party framework, graphics API and languages bindings:

    https://github.com/ocornut/imgui/wiki/Links

    Languages: C, C#, ChaiScript, D, Go, Haxe, Java, Lua, Odin, Pascal, PureBasic, Python, Rust, Swift...
    Frameworks: FreeGlut, Cinder, Cocos2d-x, Emscripten, SFML, GML/GameMaker Studio, Irrlicht, Ogre, 
    OpenSceneGraph, openFrameworks, LOVE, NanoRT, Nim Game Lib, Qt3d, SFML, Unreal Engine 4...
    Miscellaneous: Software Renderer, RemoteImgui, etc.


---------------------------------------
 EXAMPLE APPLICATIONS
---------------------------------------

Building:
  Unfortunately in 2018 it is still tedious to create and maintain portable build files using external 
  libraries (the kind we're using here to create a window and render 3D triangles) without relying on 
  third party software. For most examples here I choose to provide:
   - Makefiles for Linux/OSX
   - Batch files for Visual Studio 2008+
   - A .sln project file for Visual Studio 2010+ 
  Please let me know if they don't work with your setup!
  You can probably just import the imgui_impl_xxx.cpp/.h files into your own codebase or compile those
  directly with a command-line compiler.


directx9_example/
    DirectX9 example, Windows only.
    = main.cpp + imgui_impl_win32.cpp + imgui_impl_dx9.cpp
    
directx10_example/
    DirectX10 example, Windows only.
    = main.cpp + imgui_impl_win32.cpp + imgui_impl_dx10.cpp

directx11_example/
    DirectX11 example, Windows only.
    = main.cpp + imgui_impl_win32.cpp + imgui_impl_dx11.cpp
    
directx12_example/
    DirectX12 example, Windows only.
    This is quite long and tedious, because: DirectX12.
    = main.cpp + imgui_impl_win32.cpp + imgui_impl_dx12.cpp

opengl2_example/
    **DO NOT USE THIS CODE IF YOUR CODE/ENGINE IS USING MODERN OPENGL (SHADERS, VBO, VAO, etc.)**
    **Prefer using the code in the opengl3_example/ folder**
    GLFW + OpenGL example (legacy, fixed pipeline).
    This code is mostly provided as a reference to learn about ImGui integration, because it is shorter.
    If your code is using GL3+ context or any semi modern OpenGL calls, using this renderer is likely to
    make things more complicated, will require your code to reset many OpenGL attributes to their initial
    state, and might confuse your GPU driver. One star, not recommended.
    = main.cpp + imgui_impl_glfw.cpp + imgui_impl_opengl2.cpp

opengl3_example/
    GLFW (Win32, Mac, Linux) + OpenGL example (programmable pipeline, binding modern functions with GL3W).
    This uses more modern OpenGL calls and custom shaders. 
    Prefer using that if you are using modern OpenGL in your application (anything with shaders).
    = main.cpp + imgui_impl_glfw.cpp + imgui_impl_opengl3.cpp
	
vulkan_example/
    Vulkan example.
    This is quite long and tedious, because: Vulkan.
    = main.cpp + imgui_impl_glfw.cpp + imgui_impl_vulkan.cpp

sdl_opengl2_example/
    **DO NOT USE THIS CODE IF YOUR CODE/ENGINE IS USING MODERN OPENGL (SHADERS, VBO, VAO, etc.)**
    **Prefer using the code in the sdl_opengl3_example/ folder**
    SDL2 (Win32, Mac, Linux etc.) + OpenGL example (legacy, fixed pipeline).
    This code is mostly provided as a reference to learn about ImGui integration, because it is shorter.
    If your code is using GL3+ context or any semi modern OpenGL calls, using this renderer is likely to
    make things more complicated, will require your code to reset many OpenGL attributes to their initial
    state, and might confuse your GPU driver. One star, not recommended. 
    = main.cpp + imgui_impl_sdl2.cpp + imgui_impl_opengl2.cpp

sdl_opengl3_example/
    SDL2 (Win32, Mac, Linux, etc.) + OpenGL3 example.
    This uses more modern OpenGL calls and custom shaders. 
    Prefer using that if you are using modern OpenGL in your application (anything with shaders).
    = main.cpp + imgui_impl_sdl2.cpp + imgui_impl_opengl3.cpp

sdl_vulkan_example/
    SDL2 (Win32, Mac, Linux, etc.) + Vulkan example.
    This is quite long and tedious, because: Vulkan.
    = main.cpp + imgui_impl_glfw.cpp + imgui_impl_vulkan.cpp

apple_example/
    OSX & iOS example + OpenGL2.
    THIS EXAMPLE HAS NOT BEEN MAINTAINED PROPERLY AND NEEDS A MAINTAINER.
    Consider using the opengl3_example/ instead.
    On iOS, Using Synergy to access keyboard/mouse data from server computer.
    Synergy keyboard integration is rather hacky.

allegro5_example/
    Allegro 5 example.
    = main.cpp + imgui_impl_allegro5.cpp

marmalade_example/
    Marmalade example using IwGx
    = main.cpp + imgui_impl_marmalade.cpp

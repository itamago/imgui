
#include "screen.h"
#include "imgui_impl_metal_sdl.h"

id<MTLDevice>           g_device = nil;
id <MTLCommandQueue>    g_queue  = nil;


int main(int, char**)
{
    // Setup SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0)
    {
        printf("Error: %s\n", SDL_GetError());
        return -1;
    }

    /// METAL device
    g_device = MTLCreateSystemDefaultDevice();
    IM_ASSERT(g_device != nil);

    /// Setup window
    Screen* screen = new Screen(g_device, "Dear ImGui SDL2+Metal example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, true /* withBorders */);
    printf("retina = %.1f\n", screen->GetRetinaFactor());


    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;       // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;           // Enable Docking
    io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;         // Enable Multi-Viewport / Platform Windows
    //io.ConfigFlags |= ImGuiConfigFlags_ViewportsNoTaskBarIcons;
    //io.ConfigFlags |= ImGuiConfigFlags_ViewportsNoMerge;

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();

    // When viewports are enabled we tweak WindowRounding/WindowBg so platform windows can look identical to regular ones.
    ImGuiStyle& style = ImGui::GetStyle();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
    {
        style.WindowRounding = 0.0f;
        style.Colors[ImGuiCol_WindowBg].w = 1.0f;
    }

    // Setup Platform/Renderer bindings
    ImGui_ImplSDL2_InitForMetal(screen->winSDL);

    ImGui_ImplMetal_Init(g_device);

    g_queue = [g_device newCommandQueue];

#if 0

    /// METAL resources
    MTLRenderPassDescriptor* renderdesc = [MTLRenderPassDescriptor renderPassDescriptor];
    MTLRenderPassColorAttachmentDescriptor* colorattachment = renderdesc.colorAttachments[0];
    IM_ASSERT(renderdesc!=nil && colorattachment!=nil);

    id <MTLCommandQueue> queue = [g_device newCommandQueue];
    IM_ASSERT(queue!=nil);


    int countFrame = 0;

    for (;;)
    {
        SDL_Event evt;
        while (SDL_PollEvent(&evt))
        {
            /// Handle SDL events.
            ImGui_ImplSDL2_ProcessEvent(&evt);
        }

        @autoreleasepool /// In order to release the drawable automatically
        {
            id <MTLCommandBuffer> cmdbuf = [queue commandBuffer];

            /// Clear to a red-orange color when beginning the render pass.
            colorattachment.clearColor  = MTLClearColorMake(
                                                sin(countFrame * 3.14f/60.0f),
                                                sin(1.2f + countFrame * 3.14f/120.0f),
                                                sin(countFrame * 3.14f/90.0f),
                                                1.0);
            colorattachment.loadAction  = MTLLoadActionClear;
            colorattachment.storeAction = MTLStoreActionStore;

            id <CAMetalDrawable> drawable = [screen->metalLayer nextDrawable];
            colorattachment.texture = drawable.texture;
//            printf("render size = %d x %d\n", drawable.texture.width, drawable.texture.height);

            /// The drawable's texture is cleared to the specified color here.
            id <MTLRenderCommandEncoder> encoder = [cmdbuf renderCommandEncoderWithDescriptor:renderdesc];
            [encoder endEncoding];

            [cmdbuf presentDrawable:drawable];
            [cmdbuf commit];
        }

//      printf("frame #%d\n", countFrame);
        countFrame++;
    }

#else

    // Our state
    bool show_demo_window = true;
    bool show_another_window = false;
    ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

    /// Pass description
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    MTLRenderPassColorAttachmentDescriptor* colorattachment = renderPassDescriptor.colorAttachments[0];
    IM_ASSERT(renderPassDescriptor!=nil && colorattachment!=nil);
    colorattachment.clearColor = MTLClearColorMake(clear_color.x, clear_color.y, clear_color.z, clear_color.w);

    int countFrame = 0;

    // Main loop
    bool done = false;
    while (!done)
    {
        countFrame++;

        // Poll and handle events (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            ImGui_ImplSDL2_ProcessEvent(&event);
            if (event.type == SDL_QUIT)
                done = true;
            if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_RESIZED && event.window.windowID == SDL_GetWindowID(screen->winSDL))
            {
                screen->UpdateDrawableSize();
            }
        }

        /// Maybe hard to do it each frame, but Metal seems resilient and doesnt do anything if the size remains equal
        screen->UpdateDrawableSize();

        /// Command buffer
        id<MTLCommandBuffer> commandBuffer = [g_queue commandBuffer];

        /// Clear screen
        colorattachment.clearColor  = MTLClearColorMake(
                                            sin(countFrame * 3.14f/60.0f),
                                            sin(1.2f + countFrame * 3.14f/120.0f),
                                            sin(countFrame * 3.14f/90.0f),
                                            1.0);
        colorattachment.loadAction  = MTLLoadActionClear;
        colorattachment.storeAction = MTLStoreActionStore;

        @autoreleasepool /// In order to release the drawable automatically
        {
            id <CAMetalDrawable> drawable = [screen->metalLayer nextDrawable];
            colorattachment.texture = drawable.texture;
    //      printf("render size = %d x %d\n", drawable.texture.width, drawable.texture.height);

            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

            // Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(renderPassDescriptor);

            ImGui_ImplSDL2_NewFrame(screen->winSDL);

            /// FIXIT
            {
                ImGuiIO &io = ImGui::GetIO();
                io.DisplaySize.x = screen->view.bounds.size.width;
                io.DisplaySize.y = screen->view.bounds.size.height;

            #if TARGET_OS_OSX
                CGFloat framebufferScale = screen->winNative.screen.backingScaleFactor ?: NSScreen.mainScreen.backingScaleFactor;
            #else
                CGFloat framebufferScale = screen->winNative.screen.scale ?: UIScreen.mainScreen.scale;
            #endif
                io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);

            }

            ImGui::NewFrame();

            // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
            if (show_demo_window)
                ImGui::ShowDemoWindow(&show_demo_window);

            // 2. Show a simple window that we create ourselves. We use a Begin/End pair to created a named window.
            {
                static float f = 0.0f;
                static int counter = 0;

                ImGui::Begin("Hello, world!");                          // Create a window called "Hello, world!" and append into it.

                ImGui::Text("This is some useful text.");               // Display some text (you can use a format strings too)
                ImGui::Checkbox("Demo Window", &show_demo_window);      // Edit bools storing our window open/close state
                ImGui::Checkbox("Another Window", &show_another_window);

                ImGui::SliderFloat("float", &f, 0.0f, 1.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
                ImGui::ColorEdit3("clear color", (float*)&clear_color); // Edit 3 floats representing a color

                if (ImGui::Button("Button"))                            // Buttons return true when clicked (most widgets return true when edited/activated)
                    counter++;
                ImGui::SameLine();
                ImGui::Text("counter = %d", counter);

                ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);
                ImGui::End();
            }

            // 3. Show another simple window.
            if (show_another_window)
            {
                ImGui::Begin("Another Window", &show_another_window);   // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
                ImGui::Text("Hello from another window!");
                if (ImGui::Button("Close Me"))
                    show_another_window = false;
                ImGui::End();
            }

            // Rendering
            ImGui::Render();


//          memcpy(&wd->ClearValue.color.float32[0], &clear_color, 4 * sizeof(float));
//          FrameRender(wd);
            ImDrawData *drawData = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);

            // Update and Render additional Platform Windows
            if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
            {
                ImGui::UpdatePlatformWindows();
                ImGui::RenderPlatformWindowsDefault();
            }

            [renderEncoder endEncoding];
            [commandBuffer presentDrawable:drawable];
        } /// @autoreleasepool /// In order to release the drawable automatically

        [commandBuffer commit];
    }

    // Cleanup
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();

#endif

    DELETESAFE(screen);
    SDL_Quit();

    return 0;
}

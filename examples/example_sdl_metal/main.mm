
#include "screen.h"
#include "imgui_impl_metal_sdl.h"
#include <thread>

id<MTLDevice>           g_device        = nil;
id <MTLCommandQueue>    g_commandQueue  = nil;
bool                    g_done          = false;
Screen*                 g_screen        = NULL;

void RenderLoop();

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
    g_screen = new Screen(g_device, "Dear ImGui SDL2+Metal example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, true /* withBorders */);
    printf("retina = %.1f\n", g_screen->GetRetinaFactor());

    /// Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;       // Enable Keyboard Controls
    //io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;           // Enable Docking
    io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;         // Enable Multi-Viewport / Platform Windows
    //io.ConfigFlags |= ImGuiConfigFlags_ViewportsNoTaskBarIcons;
    //io.ConfigFlags |= ImGuiConfigFlags_ViewportsNoMerge;

    /// Setup Dear ImGui style
    ImGui::StyleColorsDark();

    // When viewports are enabled we tweak WindowRounding/WindowBg so platform windows can look identical to regular ones.
    ImGuiStyle& style = ImGui::GetStyle();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
    {
        style.WindowRounding = 0.0f;
        style.Colors[ImGuiCol_WindowBg].w = 1.0f;
    }

    /// Reload default font
#if 0
    ImFontConfig font_cfg;
    font_cfg.SizePixels = 13.0f * g_screen->GetRetinaFactor();
    io.Fonts->AddFontDefault(&font_cfg);
#endif

    /// Setup Platform/Renderer bindings
    ImGui_ImplSDL2_InitForMetal(g_screen->winSDL);
    ImGui_ImplMetal_Init(g_device);
    g_commandQueue = [g_device newCommandQueue];

    /// Launch render-thread
    std::thread render_thread(RenderLoop);

    /// SDL event loop
    g_done = false;
    while (!g_done)
    {
#if 1
        SDL_Event event;
        if (SDL_WaitEvent(&event)) /// execution suspends here while waiting on an event
        {
            ImGui_ImplSDL2_ProcessEvent(&event);
            if (event.type == SDL_QUIT)
                g_done = true;
        }
#else
        SDL_Event event;
        while (SDL_PollEvent(&event))
        {
            ImGui_ImplSDL2_ProcessEvent(&event);
            if (event.type == SDL_QUIT)
                g_done = true;
//            if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_RESIZED && event.window.windowID == SDL_GetWindowID(g_screen->winSDL))
//            {
//                g_screen->UpdateDrawableSize();
//            }
        }
#endif
    }

    // Cleanup
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();

    DELETESAFE(g_screen);
    SDL_Quit();

    return 0;
}


void RenderLoop()
{
    /// Our state
    bool show_demo_window = true;
    bool show_another_window = false;
    ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

    /// Pass description
    MTLRenderPassDescriptor* renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    IM_ASSERT(renderPassDescriptor!=nil);

    int countFrame = 0;

    /// Main loop
    while (!g_done)
    {
        countFrame++;

        /// Maybe hard to do it each frame, but Metal seems resilient and doesnt do anything if the size remains equal
        g_screen->UpdateDrawableSize();

        /// Command buffer
        id<MTLCommandBuffer> commandBuffer = [g_commandQueue commandBuffer];

        /// Clear screen
        MTLRenderPassColorAttachmentDescriptor* color_attachment = renderPassDescriptor.colorAttachments[0];
        color_attachment.clearColor  = MTLClearColorMake(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        color_attachment.loadAction  = MTLLoadActionClear;
        color_attachment.storeAction = MTLStoreActionStore;

        @autoreleasepool /// In order to release the drawable automatically
        {
            /// Get the next drawable
            id <CAMetalDrawable> drawable = [g_screen->metalLayer nextDrawable];
            color_attachment.texture = drawable.texture;

            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

            /// Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui_ImplSDL2_NewFrame(g_screen->winSDL);
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

            ImDrawData* drawData = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);

            // Update and Render additional Platform Windows
            if (ImGui::GetIO().ConfigFlags & ImGuiConfigFlags_ViewportsEnable)
            {
                ImGui::UpdatePlatformWindows();
                ImGui::RenderPlatformWindowsDefault();
            }

            [renderEncoder endEncoding];
            [commandBuffer presentDrawable:drawable];
        } /// @autoreleasepool /// In order to release the drawable automatically

        [commandBuffer commit];
    }

}

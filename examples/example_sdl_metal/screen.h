
#pragma once

#include "header.h"

#if TARGET_OS_OSX
    #define    NativeWindow    NSWindow
    #define    NativeView      NSView
#elif TARGET_OS_IOS
    #define    NativeWindow    UIWindow
    #define    NativeView      UIView
#else
    #error must be implemented
#endif

struct Screen
{
    SDL_Window*     winSDL     = NULL;
    NativeWindow*   winNative  = nil;
    NativeView*     view       = nil;
    CAMetalLayer*   metalLayer = nil;

            Screen              (id<MTLDevice> device, const char* name, int x, int y, int w, int h, bool withBorders);
            ~Screen             ();
    float   GetRetinaFactor     ()  const;
    ImVec2  GetDrawableSize     ()  const;
    void    UpdateDrawableSize  ();
};


#pragma once

#include <stdio.h>          // printf, fprintf
#include <stdlib.h>         // abort
#include <SDL.h>
#include <SDL_syswm.h>
#if defined(__APPLE__)
#  include "TargetConditionals.h"
#endif
#import  <QuartzCore/CAMetalLayer.h>
#import  <Metal/Metal.h>
#import  <MetalKit/MetalKit.h>

#include "imgui.h"
#include "imgui_impl_sdl.h"

#if TARGET_OS_IOS
#import  <UIKit/UIKit.h>
#import  <Foundation/Foundation.h>
#endif

#if (defined TARGET_OS_MAC && TARGET_OS_MAC==1)
#  define SDL_HAS_METAL                     1
#else
#  define SDL_HAS_METAL                     0
#endif

#define DELETEARRAY(x)   do { if (x) { delete []x; (x) = NULL; } } while(0)
#define DELETESAFE(x)    do { if (x) { delete x;   (x) = NULL; } } while(0)

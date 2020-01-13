
#include "screen.h"

#pragma mark -  Specific iOS

#if TARGET_OS_IOS

@interface MetalView_iOS : UIView
@property (nonatomic) CAMetalLayer *metalLayer;
@end

@implementation MetalView_iOS

+ (Class)layerClass
{
    return [CAMetalLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        /// Resize properly when rotated
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        /// Use the screen's native scale (retina resolution, when available.)
        self.contentScaleFactor = [UIScreen mainScreen].nativeScale;

        _metalLayer = (CAMetalLayer *) self.layer;
        _metalLayer.opaque = YES;
        _metalLayer.device = MTLCreateSystemDefaultDevice();
    }

    return self;
}

@end /// MetalView_iOS

#endif /// TARGET_OS_IOS

#pragma mark -  Screen

float Screen::GetRetinaFactor() const
{
#if TARGET_OS_OSX
    return [winNative backingScaleFactor];
#elif TARGET_OS_IOS
    return [[UIScreen mainScreen] nativeScale];
#else
    #error must be implemented
#endif
}

Screen::Screen(id<MTLDevice> device, const char* name, int x, int y, int w, int h, bool withBorders)
{
    /// Create SDL window
    winSDL = SDL_CreateWindow(name,
                              x,
                              y,
                              w,
                              h,
                              SDL_WINDOW_HIDDEN
                            | SDL_WINDOW_ALLOW_HIGHDPI
                            | SDL_WINDOW_RESIZABLE
                              );
    IM_ASSERT(winSDL != NULL);

    /// Get info
    SDL_SysWMinfo window_system_info;
    SDL_VERSION(&window_system_info.version);
    SDL_GetWindowWMInfo(winSDL, &window_system_info);

#if TARGET_OS_OSX

    IM_ASSERT(window_system_info.subsystem == SDL_SYSWM_COCOA);

    /// Retrieve OSX native window
    winNative = window_system_info.info.cocoa.window;
    IM_ASSERT(winNative != nil);

    /// Retrieve native view
    view = winNative.contentView;
    view.wantsLayer = YES;
    view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    /// Set style with or w/o borders
    winNative.styleMask = (withBorders ? NSWindowStyleMaskTitled : NSWindowStyleMaskBorderless);
    winNative.styleMask |= NSWindowStyleMaskResizable;

    /// Create CAMetalLayer
    metalLayer = [CAMetalLayer layer];
    IM_ASSERT(metalLayer != nil);
    metalLayer.device           = device;
    metalLayer.pixelFormat      = MTLPixelFormatBGRA8Unorm;
    metalLayer.framebufferOnly  = YES;
    metalLayer.frame            = winNative.frame;

    /// Assign CAMetalLayer to native window
    winNative.contentView.layer = metalLayer;
    winNative.opaque            = YES;
    winNative.backgroundColor   = nil;

#elif TARGET_OS_IOS

    IM_ASSERT(window_system_info.subsystem == SDL_SYSWM_UIKIT);

    winNative = window_system_info.info.uikit.window;
    IM_ASSERT(winNative != nil);

    UIView* sdlview = winNative.rootViewController.view;

    MetalView_iOS* viewIOS = [[MetalView_iOS alloc] initWithFrame:sdlview.frame];
    [sdlview addSubview:viewIOS];
    metalLayer = viewIOS.metalLayer;
    view = viewIOS;

#else
    #error not implemented for this platform
#endif

    SDL_ShowWindow(winSDL);
}

Screen::~Screen()
{
    SDL_DestroyWindow(winSDL);
}

void Screen::UpdateDrawableSize()
{
#if TARGET_OS_OSX
    CGSize size  = winNative.contentView.bounds.size;
    size.width  *= winNative.backingScaleFactor;
    size.height *= winNative.backingScaleFactor;
    metalLayer.drawableSize = size;
#elif TARGET_OS_IOS
    UIView* sdlview = winNative.rootViewController.view;
    CGSize size  = sdlview.bounds.size;
    size.width  *= sdlview.contentScaleFactor;
    size.height *= sdlview.contentScaleFactor;
    metalLayer.drawableSize = size;
#endif
}

ImVec2 Screen::GetDrawableSize()  const
{
    return ImVec2(metalLayer.drawableSize.width, metalLayer.drawableSize.height);
}



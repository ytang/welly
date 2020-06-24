//
//  XIQuickLookBridge.m
//  Preview via Quick Look
//
//  Created by boost @ 9# on 7/11/08.
//  Copyright 2008 Xi Wang. All rights reserved.
//

#import "WLQuickLookBridge.h"
#import "SynthesizeSingleton.h"

@interface WLQuickLookBridge (WLQuickLookBridgeSingleton)
+ (WLQuickLookBridge *)sharedInstance;
@end

@interface QLPreviewPanel : NSPanel
+ (QLPreviewPanel*)sharedPreviewPanel;
- (void)close;
- (void)makeKeyAndOrderFrontWithEffect:(int)flag canClose:(BOOL)canClose;
// 10.5 only
- (void)setURLs:(NSArray *)URLs currentIndex:(NSUInteger)index preservingDisplayState:(BOOL)flag;
- (void)setEnableDragNDrop:(BOOL)flag;
// 10.6 and above
@property(readonly) id currentController;
@property NSInteger currentPreviewItemIndex;
- (void)updateController;
- (id)sharedPreviewView;
- (void)reloadDataPreservingDisplayState:(BOOL)flag;
@end

@interface QLPreviewView : NSView
@property (NS_NONATOMIC_IOSONLY) BOOL enableDragNDrop;
- (void)setDelegate:(id)delegate;
- (void)setAutomaticallyMakePreviewFirstResponder:(BOOL)arg1;
@end

@interface QLPreviewPanelController : NSWindowController
@property(readonly) QLPreviewView *previewView;
@property(retain) QLPreviewView *sharedPreviewView; 
@end

@implementation WLQuickLookBridge

static BOOL isLeopard;
static BOOL isLion;

SYNTHESIZE_SINGLETON_FOR_CLASS(WLQuickLookBridge)

+ (void)initialize {
    // SInt32 ver;
    // Since deployment target set to 10.8, there's no need to detect these 2 values
    // Set to NO to silent Xcode deprecation warnings.
    isLeopard = NO; // Gestalt(gestaltSystemVersion, &ver) == noErr && ver < 0x1060;
    isLion = YES; // Gestalt(gestaltSystemVersion, &ver) == noErr && ver >= 0x1070;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _URLs = [[NSMutableArray alloc] init];
        // 10.5: /System/Library/PrivateFrameworks/QuickLookUI.framework
        // 10.6: /System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework
        // 10.7: /System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework
        [[NSBundle bundleWithPath:@"/System/Library/…/QuickLookUI.framework"] load];
        _panel = [NSClassFromString(@"QLPreviewPanel") sharedPreviewPanel];
        // To deal with full screen window level
        // Modified by gtCarrera
        //[_panel setLevel:kCGStatusWindowLevel+1];
        // End
        id controller = [_panel windowController];
        [controller setDelegate:self];
        if (isLeopard) {
            [_panel setEnableDragNDrop:YES];
        } else {
            [_panel setDataSource:self];
            QLPreviewView *view = [controller previewView];
            [view setEnableDragNDrop:YES];
            //[view setAutomaticallyMakePreviewFirstResponder:YES];
            [view setDelegate:self];
        }
    }
    return self;
}


// delegate for QLPreviewPanel
// zoom effect from the current mouse coordinates
- (NSRect)previewPanel:(NSPanel*)panel frameForURL:(NSURL*)URL {
    NSRect frame;
    frame.origin = [NSEvent mouseLocation];
    frame.size.width = 1;
    frame.size.height = 1;
    return frame;
}

- (BOOL)previewView:(id)aView acceptDrop:(id)aObject onPreviewItem:(id)item {
    return YES;
}

- (BOOL)previewView:(id)aView writePreviewItem:(id)item toPasteboard:(id)pboard {
    [pboard declareTypes:@[NSURLPboardType] owner:nil];
    [item writeToPasteboard:pboard];
    return YES;
}

- (void)previewView:(id)aView didShowPreviewItem:(id)item {
    //[aView setEnableDragNDrop:YES];
}

+ (NSMutableArray *)URLs {
    return [self sharedInstance]->_URLs;
}

+ (id)Panel {
    return [self sharedInstance]->_panel;
}

+ (void)orderFront {
    if (isLion) {
        [[self Panel] makeKeyAndOrderFront:self];
        return;
    }
    // 1 = fade in, 2 = zoom in
    [[self Panel] makeKeyAndOrderFrontWithEffect:2 canClose:YES];
}

+ (void)add:(NSURL *)URL {
    NSMutableArray *URLs = [self URLs];
    // check if the url is already under preview
    NSUInteger index = [URLs indexOfObject:URL];
    if (index == NSNotFound) {
        index = URLs.count;
        [URLs addObject:URL];
    }
    // update
    if (isLeopard)
        [[self Panel] setURLs:URLs currentIndex:index preservingDisplayState:YES];
    else {
        [[self Panel] setCurrentPreviewItemIndex:index];
        [[self Panel] reloadDataPreservingDisplayState:YES];
    }
    [self orderFront];
}
/*
+ (void)removeAll {
    [[self URLs] removeAllObjects];
    [[self sharedPanel] close];
    // we don't call setURLs here
}*/

#pragma mark -
#pragma mark QLPreviewPanelDataSource protocol

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(id)panel {
    return _URLs.count;
}

- (id)previewPanel:(id)panel previewItemAtIndex:(NSInteger)index {
    return _URLs[index];
}

@end

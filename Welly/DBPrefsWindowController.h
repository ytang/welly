//
//  DBPrefsWindowController.h
//
//  Created by Dave Batton
//  http://www.Mere-Mortal-Software.com/blog/
//
//  Documentation for this class is available here:
//  http://www.mere-mortal-software.com/blog/details.php?d=2007-03-11
//
//  Copyright 2007. Some rights reserved.
//  This work is licensed under a Creative Commons license:
//  http://creativecommons.org/licenses/by/3.0/
//
//  11 March 2007 : Initial 1.0 release
//  15 March 2007 : Version 1.1
//                  Resizing is now handled along with the cross-fade by
//                  the NSViewAnimation routine.
//                  Cut the fade time in half to speed up the window resize.
//                  -setupToolbar is now called each time the window opens so
//                  you can configure it differently each time if you want.
//                  Holding down the shift key will now slow down the animation.
//                  This can be disabled by using the new -setShiftSlowsAnimation:
//                  method.
//  23 March 2007 : Version 1.1.1
//                  The initial first responder now gets set when the view is
//                  swapped so that the user can tab to the objects displayed
//                  in the window.
//                  Also added a work-around to Cocoa's insistance on drawing
//                  a focus ring around the first toolbar icon when going from
//                  a view with a focusable item to a view without a focusable item.
//
//  31 May 2007 :   Version 1.1.2
//                  The window's title bar and toolbar heights are now calculated at
//                  runtime, rather than being hard-coded.
//                  Fixed a redraw problem and a window placement problem associated
//                  with large preference windows.
//                  Added some code to supress compiler warnings from unused parameters.
//                  Fixed a couple of objects that weren't being properly released.
//


#import <Cocoa/Cocoa.h>
#import <AppKit/NSAnimation.h>

@interface DBPrefsWindowController : NSWindowController <NSAnimationDelegate, NSToolbarDelegate> {
    NSMutableArray *toolbarIdentifiers;
    NSMutableDictionary *toolbarViews;
    NSMutableDictionary *toolbarItems;
    
    BOOL _crossFade;
    BOOL _shiftSlowsAnimation;
    
    IBOutlet NSPopUpButton *_telnetPopUpButton;
    IBOutlet NSPopUpButton *_sshPopUpButton;
    
    IBOutlet NSView *_generalPrefView;
    IBOutlet NSView *_connectionPrefView;
    IBOutlet NSView *_fontsPrefView;
    IBOutlet NSView *_colorsPrefView;
    IBOutlet NSView *_autoReplyPrefView;
    
    NSView *contentSubview;
    NSViewAnimation *viewAnimation;
}

- (IBAction) setChineseFont: (id) sender;
- (IBAction) setEnglishFont: (id) sender;

- (IBAction) setDefaultTelnetClient: (id) sender;
- (IBAction) setDefaultSSHClient: (id) sender;

+ (DBPrefsWindowController *)sharedPrefsWindowController;
+ (NSString *)nibName;

- (void)setupToolbar;
- (void)addView:(NSView *)view label:(NSString *)label;
- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image;

@property (NS_NONATOMIC_IOSONLY) BOOL crossFade;
@property (NS_NONATOMIC_IOSONLY) BOOL shiftSlowsAnimation;

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate;
- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView;
- (NSRect)frameForView:(NSView *)view;


@end

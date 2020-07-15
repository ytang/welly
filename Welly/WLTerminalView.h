//
//  WLTerminalView.h
//  MacBlueTelnet
//
//  Created by Yung-Luen Lan on 2006/6/9.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"
#import "WLSitesPanelController.h"
#import "WLMouseBehaviorManager.h"
#import "WLTermView.h"
#import "WLTerminal.h"

@class WLTermView;
@class YLMarkedTextView;
@class WLMouseBehaviorManager;
@class WLURLManager;

#define disableMouseByKeyingTimerInterval 0.3

@interface WLTerminalView : WLTermView <NSTextInputClient, WLTerminalObserver, WLContextualMenuHandler, WLMouseUpHandler> {
    NSTimer *_timer;
    
    id _markedText;
    NSRange _selectedRange;
    NSRange _markedRange;
    
    IBOutlet YLMarkedTextView *_textField;
    
    NSInteger _selectionLocation;
    NSInteger _selectionLength;
    BOOL _wantsRectangleSelection;
    BOOL _hasRectangleSelected;
    
    BOOL _isInUrlMode;
    BOOL _isNotCancelingSelection;
    BOOL _isKeying;
    BOOL _isMouseActive;
    
    NSTimer *_activityCheckingTimer;
    
    WLMouseBehaviorManager *_mouseBehaviorDelegate;
    WLURLManager *_urlManager;

    // Core Animation
    CALayer *_ipAddrLayer;
    CALayer *_clickEntryLayer;
    CALayer *_popUpLayer;
    CALayer *_buttonLayer;
    
    CALayer *_urlLineLayer;
    CALayer *_urlIndicatorLayer;
    
    CGColorRef _popUpLayerTextColor;
    CGFontRef _popUpLayerTextFont;
}
@property BOOL isInUrlMode;
@property BOOL isMouseActive;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL shouldWarnCompose;

- (void)copy:(id)sender;
- (void)pasteWrap:(id)sender;
- (void)paste:(id)sender;
- (void)pasteColor:(id)sender;

//- (void)refreshHiddenRegion;

- (void)clearSelection;

- (void) showCustomizedPopUpMessage:(NSString *) myMessage;


- (NSRect)rectAtRow:(NSInteger)r
             column:(NSInteger)c
             height:(NSInteger)h
              width:(NSInteger)w;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL shouldEnableMouse;

- (void)sendText:(NSString *)text;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *selectedPlainString ;
//- (BOOL)hasBlinkCell ;

- (void)insertText:(id)aString withDelay:(int)microsecond;
/* Url Menu */
- (void)switchURL;
- (void)exitURL;

// Mouse operation
- (void)deactivateMouseForKeying;
- (void)activateMouseForKeying:(NSTimer*)timer;

- (NSInteger)convertIndexFromPoint:(NSPoint)aPoint;
@property (NS_NONATOMIC_IOSONLY, readonly) NSPoint mouseLocationInView;

#pragma mark -
#pragma mark Core Animation
// for ip seeker
- (void)drawIPAddrBox:(NSRect)rect;
- (void)clearIPAddrBox;

// for post view
- (void)drawClickEntry:(NSRect)rect;
- (void)clearClickEntry;

// for button
- (void)drawButton:(NSRect)rect
       withMessage:(NSString *)message;
- (void)clearButton;

// for URL
- (void)showIndicatorAtPoint:(NSPoint)point;
- (void)removeIndicator;

// To show pop up message by core animation
// This method might be changed in future
// by gtCarrera @ 9#
- (void)drawPopUpMessage:(NSString*)message;
- (void)removePopUpMessage;
@end

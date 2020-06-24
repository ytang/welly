//
//  LLFullScreenController.h
//  Welly
//
//  Created by gtCarrera @ 9# on 08-8-11.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLFullScreenProcessor.h"
@protocol WLPresentationModeProcessor;

@interface WLPresentationController : NSObject<WLFullScreenProcessor> 
@property (readonly) BOOL isInPresentationMode;

// Init functions
- (instancetype)initWithProcessor:(NSObject <WLPresentationModeProcessor>*)pro 
                       targetView:(NSView*)tview 
                        superView:(NSView*)sview
                   originalWindow:(NSWindow*)owin;
- (instancetype)initWithTargetView:(NSView*)tview 
                         superView:(NSView*)sview
                    originalWindow:(NSWindow*)owin;
// Handle functions
- (void)togglePresentationMode;
- (void)exitPresentationMode;

@end

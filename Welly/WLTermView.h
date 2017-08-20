//
//  WLTermView.h
//  Welly
//
//  Created by K.O.ed on 09-11-2.
//  Copyright 2009 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLTabView.h"
#import "WLTerminal.h"

@class WLTerminal, WLConnection, WLAsciiArtRender;

@interface WLTermView : NSView <WLTabItemContentObserver, WLTerminalObserver>

@property (readwrite, assign, nonatomic) CGFloat fontWidth;
@property (readwrite, assign, nonatomic) CGFloat fontHeight;
@property (readwrite, assign, nonatomic) NSInteger x;
@property (readwrite, assign, nonatomic) NSInteger y;
@property (readwrite, assign, nonatomic) NSInteger maxRow;
@property (readwrite, assign, nonatomic) NSInteger maxColumn;


@property (readonly, strong, nonatomic) WLTerminal *frontMostTerminal;
@property (readonly, strong, nonatomic) WLConnection *frontMostConnection;
@property (readonly, nonatomic, getter=isConnected) BOOL connected;
// get current BBS image
@property (readonly, copy, nonatomic) NSImage *image;

- (void)updateBackedImage;
- (void)configure;

- (void)refreshDisplay;
- (void)terminalDidUpdate:(WLTerminal *)terminal;

@end

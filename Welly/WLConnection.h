//
//  WLConnection.h
//  Welly
//
//  YLConnection.h
//  MacBlueTelnet
//
//  Created by Lan Yung-Luen on 12/7/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLProtocol.h"
#import <MMTabBarView/MMTabBarView.h>

@class WLSite, WLTerminal, WLTerminalFeeder, WLMessageDelegate;

// modified by boost @ 9#
// inhert from NSObjectController for MMTabBarView
@interface WLConnection : NSObject <MMTabBarItem>

@property (readwrite, strong, nonatomic) WLSite *site;
@property (readwrite, strong, nonatomic) WLTerminal *terminal;
@property (readwrite, strong, nonatomic) WLTerminalFeeder *terminalFeeder;
@property (readwrite, strong, nonatomic) NSObject <WLProtocol> *protocol;
@property (readwrite, assign, nonatomic, getter=isConnected) BOOL connected;
@property (readonly, strong, nonatomic) NSDate *lastTouchDate;
@property (readonly, assign, nonatomic) NSInteger messageCount;
@property (readonly, strong, nonatomic) WLMessageDelegate *messageDelegate;
// for MMTabBarView
@property (readwrite, strong) NSImage *icon;
@property (readwrite, assign) BOOL isProcessing;
@property (readwrite, assign) NSInteger objectCount;
@property (readwrite, assign) BOOL hasCloseButton;

- (instancetype)initWithSite:(WLSite *)site;

- (void)close;
- (void)reconnect;
- (void)sendMessage:(NSData *)msg;
- (void)sendBytes:(const void *)buf 
		   length:(NSInteger)length;
- (void)sendText:(NSString *)text;
- (void)sendText:(NSString *)text 
	   withDelay:(int)microsecond;

/* message */
- (void)didReceiveNewMessage:(NSString *)message
				  fromCaller:(NSString *)caller;
- (void)increaseMessageCount:(NSInteger)value;
- (void)resetMessageCount;
@end

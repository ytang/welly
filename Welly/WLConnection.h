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
#import "WLTabBarCellContentProvider.h"

@class WLSite, WLTerminal, WLTerminalFeeder, WLMessageDelegate;

// modified by boost @ 9#
// inhert from NSObjectController for PSMTabBarControl
@interface WLConnection : NSObject <WLTabBarCellContentProvider>

@property (readwrite, retain, nonatomic) WLSite *site;
@property (readwrite, retain, nonatomic) WLTerminal *terminal;
@property (readwrite, retain, nonatomic) WLTerminalFeeder *terminalFeeder;
@property (readwrite, retain, nonatomic) NSObject <WLProtocol> *protocol;
@property (readwrite, assign, nonatomic, getter=isConnected) BOOL connected;
@property (readonly, retain, nonatomic) NSDate *lastTouchDate;
@property (readonly, assign, nonatomic) NSInteger messageCount;
@property (readonly, retain, nonatomic) WLMessageDelegate *messageDelegate;
// for PSMTabBarControl
@property (readwrite, retain, nonatomic) NSImage *icon;
@property (readwrite, assign, nonatomic) BOOL isProcessing;
@property (readwrite, assign, nonatomic) NSInteger objectCount;
@property (readwrite, assign, nonatomic) id tabViewItemController;

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

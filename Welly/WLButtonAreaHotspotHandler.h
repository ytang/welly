//
//  WLButtonAreaHotspotHandler.h
//  Welly
//
//  Created by K.O.ed on 09-1-27.
//  Copyright 2009 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLMouseHotspotHandler.h"
#import "WLTerminal.h"

NSString * const WLButtonNameComposePost;
NSString * const WLButtonNameDeletePost;
NSString * const WLButtonNameShowNote;
NSString * const WLButtonNameShowHelp;
NSString * const WLButtonNameNormalToDigest;
NSString * const WLButtonNameDigestToThread;
NSString * const WLButtonNameThreadToMark;
NSString * const WLButtonNameMarkToOrigin;
NSString * const WLButtonNameOriginToNormal;
NSString * const WLButtonNameSwitchDisplayAllBoards;
NSString * const WLButtonNameSwitchSortBoards;
NSString * const WLButtonNameSwitchBoardsNumber;
NSString * const WLButtonNameDeleteBoard;

typedef struct {
	int state;
	__unsafe_unretained NSString *signature;
	int signatureLengthOfBytes;
	__unsafe_unretained NSString *buttonName;
	__unsafe_unretained NSString *commandSequence;
} WLButtonDescription;

@class WLTerminalView;
@interface WLButtonAreaHotspotHandler : WLMouseHotspotHandler <WLMouseUpHandler, WLUpdatable> {
	NSString *_commandSequence;
}
@end

//
//  LLURLManager.h
//  Welly
//
//  Created by K.O.ed on 09-3-16.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLMouseHotspotHandler.h"

@interface WLURLManager : WLMouseHotspotHandler <WLUpdatable, WLMouseUpHandler, WLContextualMenuHandler> {
	NSMutableArray *_currentURLList;
	NSInteger _currentSelectedURLIndex;
	
	//NSMutableString *_currentURLStringBuffer;
}
@property (NS_NONATOMIC_IOSONLY, readonly) NSPoint currentSelectedURLPos;
- (BOOL)openCurrentURL:(NSEvent *)event;
@property (NS_NONATOMIC_IOSONLY, readonly) NSPoint moveNext;
@property (NS_NONATOMIC_IOSONLY, readonly) NSPoint movePrev;
- (void)addURL:(NSString *)urlString
	   atIndex:(NSInteger)index
		length:(NSInteger)length;
@end

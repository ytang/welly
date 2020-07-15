//
//  LLPopUpMessage.m
//  Welly
//
//  Created by gtCarrera @ 9# on 08-9-11.
//  Copyright 2008. All rights reserved.
//

#import "WLPopUpMessage.h"
#import "WLTerminalView.h"

@implementation WLPopUpMessage

WLTerminalView *_view;
NSTimer *_prevTimer;

#pragma mark Class methods
+ (void)hidePopUpMessage {
    if (_view) {
        [_view removePopUpMessage];
    }
    _prevTimer = nil;
}

+ (void)showPopUpMessage:(NSString*)message 
                duration:(CGFloat)duration 
                    view:(WLTerminalView *)view {
    if (_prevTimer) {
        [_prevTimer invalidate];
    }
    [view drawPopUpMessage:message];
    _view = view;
    _prevTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                  target:self 
                                                selector:@selector(hidePopUpMessage)
                                                userInfo:nil
                                                 repeats:NO];
}

@end

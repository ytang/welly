//
//  WLUserNotificationCenterDelegate.m
//  Welly
//
//  Created by Yang Tang on 8/9/20.
//  Copyright © 2020 ytang.com. All rights reserved.
//

#import "WLUserNotificationCenterDelegate.h"

#import "WLMainFrameController.h"
#import "WLTabView.h"

#import "SynthesizeSingleton.h"

@implementation WLUserNotificationCenterDelegate
SYNTHESIZE_SINGLETON_FOR_CLASS(WLUserNotificationCenterDelegate)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification {
    WLTabView *view = WLMainFrameController.sharedInstance.tabView;
    NSData *identifier = notification.userInfo[@"identifier"];
    NSUInteger index = [view.tabViewItems indexOfObjectPassingTest:^BOOL(__kindof NSTabViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id objId = obj.identifier;
        return [identifier isEqualToData:[NSData dataWithBytes:&objId length:__SIZEOF_POINTER__]];
    }];
    if (index != NSNotFound) {
        [view selectTabViewItemAtIndex:index];
    }
    
    [NSUserNotificationCenter.defaultUserNotificationCenter removeDeliveredNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}
@end

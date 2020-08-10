//
//  WLUserNotificationCenterDelegate.h
//  Welly
//
//  Created by Yang Tang on 8/9/20.
//  Copyright © 2020 ytang.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLUserNotificationCenterDelegate : NSObject <NSUserNotificationCenterDelegate>
+ (WLUserNotificationCenterDelegate *)sharedInstance;
@end

NS_ASSUME_NONNULL_END

//
//  WLTabBarItem.h
//  Welly
//
//  Created by Naitong Yu on 2017/8/19.
//  Copyright © 2017 net9.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMTabBarView/MMTabBarView.h>

@interface WLTabBarItem : NSObject <MMTabBarItem>

@property (copy)   NSString  *title;
@property (strong) NSImage   *icon;
@property (assign) BOOL      isProcessing;
@property (assign) BOOL      hasCloseButton;
@property (assign) NSInteger objectCount;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

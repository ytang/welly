//
//  WLTabBarItem.m
//  Welly
//
//  Created by Naitong Yu on 2017/8/19.
//  Copyright © 2017 net9.org. All rights reserved.
//

#import "WLTabBarDummyItem.h"
#import "WLGlobalConfig.h"

@implementation WLTabBarDummyItem

- (instancetype)init {
    if (self = [super init]) {
        if ([WLGlobalConfig shouldEnableCoverFlow]) {
            _title = @"Cover Flow";
        } else {
            _title = NSLocalizedString(@"DefaultSiteName", @"Site");
        }
        _icon = nil;
        _isProcessing = NO;
        _objectCount = 0;
        _hasCloseButton = YES;
    }
    return self;
}

@end

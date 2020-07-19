//
//  WLTouchBarController.m
//  Welly
//
//  Created by Yang Tang on 7/18/20.
//  Copyright © 2020 ytang.com. All rights reserved.
//

#import "WLTouchBarController.h"

#import "WLConnection.h"
#import "WLTabBarDummyItem.h"
#import "WLTabView.h"

#import "SynthesizeSingleton.h"

@implementation WLTouchBarController

SYNTHESIZE_SINGLETON_FOR_CLASS(WLTouchBarController)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateSiteName:)
                                                     name:WLTabViewSelectionDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)updateSiteName:(NSNotification *)notification {
    id content = notification.userInfo[@"content"];
    if ([content isKindOfClass:[WLConnection class]]) {
        _siteNameTouchBarField.stringValue = [content site].name;
    } else if ([content isKindOfClass:[WLTabBarDummyItem class]]) {
        _siteNameTouchBarField.stringValue = [content title];
    } else {
        _siteNameTouchBarField.stringValue = @"";
    }
}

@end

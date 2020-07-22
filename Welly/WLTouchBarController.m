//
//  WLTouchBarController.m
//  Welly
//
//  Created by Yang Tang on 7/18/20.
//  Copyright © 2020 ytang.com. All rights reserved.
//

#import "WLTouchBarController.h"

#import "WLConnection.h"
#import "WLMainFrameController.h"
#import "WLTabBarDummyItem.h"
#import "WLTerminalView.h"

#import "SynthesizeSingleton.h"

const NSNotificationName WLTabViewSelectionDidChangeNotification;
const NSNotificationName WLTerminalViewDidEnterURLModeNotification;
const NSNotificationName WLTerminalViewDidExitURLModeNotification;
const NSNotificationName WLURLManagerNotification;

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterURLMode)
                                                     name:WLTerminalViewDidEnterURLModeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didExitURLMode)
                                                     name:WLTerminalViewDidExitURLModeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateURLMode:)
                                                     name:WLURLManagerNotification
                                                   object:nil];
    }
    return self;
}

- (void)resetItems {
    _touchBar.templateItems = [NSSet setWithObjects:_sitesPanelButton, _reconnectButton, _siteNameField, _flexibleSpace, nil];
}

- (void)updateSiteName:(NSNotification *)notification {
    id content = notification.userInfo[@"content"];
    NSTextField *field = (NSTextField *)_siteNameField.view;
    if ([content isKindOfClass:[WLConnection class]]) {
        field.stringValue = [content site].name;
        if (![content isConnected]) {
            [self resetItems];
        }
    } else {
        field.stringValue = [content isKindOfClass:[WLTabBarDummyItem class]] ? [content title] : @"";
        [self resetItems];
    }
}

#pragma mark -
#pragma mark URL Mode
- (IBAction)switchURLMode:(id)sender {
    id view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [view switchURL];
    }
}

- (void)didEnterURLMode {
    _touchBar.templateItems = [[_touchBar.templateItems objectsPassingTest:^BOOL(NSTouchBarItem * _Nonnull obj, BOOL * _Nonnull stop) {
        return ![obj isEqual:_siteNameField] && ![obj isEqual:_urlModeButton];
    }] setByAddingObject:_urlModeField];
}

- (void)didExitURLMode {
    _touchBar.templateItems = [[_touchBar.templateItems objectsPassingTest:^BOOL(NSTouchBarItem * _Nonnull obj, BOOL * _Nonnull stop) {
        return ![obj isEqual:_urlModeField];
    }] setByAddingObjectsFromArray:@[_siteNameField, _urlModeButton]];
}

- (void)updateURLMode:(NSNotification *)notification {
    if ([notification.userInfo[@"count"] unsignedLongValue] > 0) {
        _touchBar.templateItems = [_touchBar.templateItems setByAddingObject:_urlModeButton];
    } else {
        _touchBar.templateItems = [_touchBar.templateItems objectsPassingTest:^BOOL(NSTouchBarItem * _Nonnull obj, BOOL * _Nonnull stop) {
            return ![obj isEqual:_urlModeButton];
        }];
    }
}

@end

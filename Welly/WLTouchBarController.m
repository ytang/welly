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
const NSNotificationName WLTerminalViewURLModeDidChangeNotification;
const NSNotificationName WLURLManagerNotification;
const NSNotificationName WLTerminalBBSStateDidChangeNotification;

NSString *const _composeCommandSequence = @"\020";
NSString *const _threadModeCommandSequence = @"\07""2\n";
NSString *const _markModeCommandSequence = @"\07""3\n";
NSString *const _authorModeCommandSequence = @"\07""5\n\n";
NSString *const _titleModeCommandSequence = @"\07""6\n";

@implementation WLTouchBarController {
    NSSet<NSTouchBarItem *> *_urlModeItems;
    NSSet<NSTouchBarItem *> *_urlModeHiddenItems;
    NSSet<NSTouchBarItem *> *_urlModeButtonItems;
    NSSet<NSTouchBarItem *> *_composePostItems;
    NSSet<NSTouchBarItem *> *_viewPostItems;
    NSSet<NSTouchBarItem *> *_browseBoardItems;
}

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
                                                 selector:@selector(urlModeDidChange:)
                                                     name:WLTerminalViewURLModeDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateURLMode:)
                                                     name:WLURLManagerNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bbsStateDidChange:)
                                                     name:WLTerminalBBSStateDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)resetItems {
    _touchBar.templateItems = [NSSet setWithObjects:_sitesPanelButton, _reconnectButton, _siteNameField, _flexibleSpace, nil];
    _urlModeItems = [NSSet setWithObjects:_urlModeField, _previousURLButton, _nextURLButton, _previewURLButton, _openURLInBrowserButton, nil];
    _urlModeHiddenItems = [NSSet setWithObjects:_siteNameField, _urlModeButton, nil];
    _urlModeButtonItems = [NSSet setWithObjects:_urlModeButton, nil];
    _composePostItems = [NSSet setWithObjects:_emoticonsPanelButton, _composePanelButton, nil];
    _viewPostItems = [NSSet setWithObjects:_postDownloadPanelButton, nil];
    _browseBoardItems = [NSSet setWithObjects:_threadModeButton, _markModeButton, _authorModeButton, _titleModeButton, _composeButton, nil];
}

- (void)updateItems:(NSSet<NSTouchBarItem *> *)items when:(BOOL)condition {
    if (condition) {
        _touchBar.templateItems = [_touchBar.templateItems setByAddingObjectsFromSet:items];
    } else {
        _touchBar.templateItems = [_touchBar.templateItems objectsPassingTest:^BOOL(NSTouchBarItem * _Nonnull obj, BOOL * _Nonnull stop) {
            return ![items containsObject:obj];
        }];
    }
}

- (void)updateSiteName:(NSNotification *)notification {
    id content = notification.userInfo[@"content"];
    NSTextField *field = (NSTextField *)_siteNameField.view;
    if ([content isKindOfClass:[WLConnection class]]) {
        field.stringValue = [content site].name;
        if ([content isConnected]) {
            [self updateBBSState:[content terminal].bbsState];
        } else {
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
    NSView *view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [(WLTerminalView *)view switchURL];
    }
}

- (IBAction)previousURL:(id)sender {
    NSView *view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [(WLTerminalView *)view previousURL];
    }
}

- (IBAction)nextURL:(id)sender {
    NSView *view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [(WLTerminalView *)view nextURL];
    }
}

- (IBAction)previewURL:(id)sender {
    NSView *view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [(WLTerminalView *)view openURL:NO];
    }
}

- (IBAction)openURLInBrowser:(id)sender {
    NSView *view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [(WLTerminalView *)view openURL:YES];
    }
}

- (void)urlModeDidChange:(NSNotification *)notification {
    BOOL urlMode = [notification.userInfo[@"urlMode"] boolValue];
    [self updateItems:_urlModeItems when:urlMode];
    [self updateItems:_urlModeHiddenItems when:!urlMode];
}

- (void)updateURLMode:(NSNotification *)notification {
    [self updateItems:_urlModeButtonItems when:[notification.userInfo[@"count"] unsignedLongValue] > 0];
}

#pragma mark -
#pragma mark BBS State
- (void)updateBBSState:(BBSState)bbsState {
    [self updateItems:_composePostItems when:bbsState.state == BBSComposePost];
    [self updateItems:_viewPostItems when:bbsState.state == BBSViewPost];
    if (WLMainFrameController.sharedInstance.tabView.frontMostTerminal.bbsType == WLFirebird) {
        [self updateItems:_browseBoardItems when:bbsState.state == BBSBrowseBoard];
    }
}

- (void)bbsStateDidChange:(NSNotification *)notification {
    BBSState bbsState;
    [notification.userInfo[@"bbsState"] getValue:&bbsState];
    [self updateBBSState:bbsState];
}

- (void)sendText:(NSString *)text {
    NSView *view = WLMainFrameController.sharedInstance.tabView.frontMostView;
    if ([view isKindOfClass:[WLTerminalView class]]) {
        [(WLTerminalView *)view sendText:text];
    }
}

- (IBAction)compose:(id)sender {
    [self sendText:_composeCommandSequence];
}

- (IBAction)threadMode:(id)sender {
    [self sendText:_threadModeCommandSequence];
}

- (IBAction)markMode:(id)sender {
    [self sendText:_markModeCommandSequence];
}

- (IBAction)authorMode:(id)sender {
    [self sendText:_authorModeCommandSequence];
}

- (IBAction)titleMode:(id)sender {
    [self sendText:_titleModeCommandSequence];
}

@end

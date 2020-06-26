//
//  WLMainFrameController+TabControl.m
//  Welly
//
//  Created by K.O.ed on 10-4-30.
//  Copyright 2010 Welly Group. All rights reserved.
//

#import "WLMainFrameController+TabControl.h"

#import "WLTabBarControl.h"
#import "WLTabView.h"
#import "WLConnection.h"
#import "WLSite.h"
#import "WLGlobalConfig.h"

@interface WLMainFrameController () <MMTabBarViewDelegate>

- (void)updateEncodingMenu;
- (void)exitPresentationMode;

@end

@implementation WLMainFrameController (TabControl)

- (void)initializeTabControl {
    // tab control style
    [_tabBarControl setCanCloseOnlyTab:YES];
    [_tabBarControl setStyleNamed:@"Yosemite"];
    NSAssert([_tabBarControl delegate] == self, @"set in .nib");
    //show a new-tab button
    [_tabBarControl setShowAddTabButton:YES];
    
    // open the portal
    // the switch
    [self tabViewDidChangeNumberOfTabViewItems:_tabView];
}

#pragma mark -
#pragma mark Actions
- (IBAction)newTab:(id)sender {
    // Draw the portal and entering the portal control mode if needed...
    if ([WLGlobalConfig shouldEnableCoverFlow]) {
        [_tabView newTabWithCoverFlowPortal];
    } else {
        [self newConnectionWithSite:[WLSite site]];
        // let user input
        [_mainWindow makeFirstResponder:_addressBar];
    }
}

- (IBAction)selectNextTab:(id)sender {
    NSTabViewItem *sel = _tabView.selectedTabViewItem;
    if (sel == nil)
        return;
    NSInteger index = [_tabView indexOfTabViewItem:sel] + 1;
    if (index == [_tabView numberOfTabViewItems]) {
        index = 0;
    }
    [_tabView selectTabViewItemAtIndex:index];
}

- (IBAction)selectPrevTab:(id)sender {
    NSTabViewItem *sel = _tabView.selectedTabViewItem;
    if (sel == nil)
        return;
    NSInteger index = [_tabView indexOfTabViewItem:sel] - 1;
    if (index < 0) {
        index = [_tabView numberOfTabViewItems] - 1;
    }
    [_tabView selectTabViewItemAtIndex:index];
}

- (IBAction)closeTab:(id)sender {
    NSTabViewItem *tabViewItem = [_tabView selectedTabViewItem];
    
    if (!tabViewItem) {
        return;
    }
    
    if (([_tabBarControl delegate]) && ([[_tabBarControl delegate] respondsToSelector:@selector(tabView:shouldCloseTabViewItem:)])) {
        if (![[_tabBarControl delegate] tabView:_tabView shouldCloseTabViewItem:tabViewItem]) {
            return;
        }
    }
    
    if (([_tabBarControl delegate]) && ([[_tabBarControl delegate] respondsToSelector:@selector(tabView:willCloseTabViewItem:)])) {
        [[_tabBarControl delegate] tabView:_tabView willCloseTabViewItem:tabViewItem];
    }
    
    [_tabView removeTabViewItem:tabViewItem];
    
    if (([_tabBarControl delegate]) && ([[_tabBarControl delegate] respondsToSelector:@selector(tabView:didCloseTabViewItem:)])) {
        [[_tabBarControl delegate] tabView:_tabView didCloseTabViewItem:tabViewItem];
    }
}

#pragma mark -
#pragma mark TabView delegation

- (void)addNewTabToTabView:(NSTabView *)aTabView {
    [self newTab:self];
}

- (BOOL)tabView:(NSTabView *)tabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    // Restore from full screen firstly
    [self exitPresentationMode];
    
    // TODO: why not put these in WLTabView?
    if (![tabViewItem.identifier isKindOfClass:[WLConnection class]] ||
        ![tabViewItem.identifier isConnected]) 
        return YES;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WLConfirmOnCloseEnabledKeyName]) 
        return YES;
    
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Are you sure you want to close this tab?", @"Sheet Title")
                                     defaultButton:NSLocalizedString(@"Close", @"Default Button")
                                   alternateButton:NSLocalizedString(@"Cancel", @"Cancel Button")
                                       otherButton:nil
                         informativeTextWithFormat:NSLocalizedString(@"The connection is still alive. If you close this tab, the connection will be lost. Do you want to close this tab anyway?", @"Sheet Message")];
    if ([alert runModal] == NSAlertDefaultReturn)
        return YES;
    return NO;
}

- (void)tabView:(NSTabView *)tabView willCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    // close the connection
    if ([tabViewItem.identifier isKindOfClass:[WLConnection class]])
        [tabViewItem.identifier close];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSAssert(tabView == _tabView, @"tabView");
    [_addressBar setStringValue:@""];
    if ([tabViewItem.identifier isKindOfClass:[WLConnection class]]) {
        WLConnection *connection = tabViewItem.identifier;
        WLSite *site = connection.site;
        if (connection && site.address) {
            [_addressBar setStringValue:site.address];
            [connection resetMessageCount];
        }
        
        [_mainWindow makeFirstResponder:tabView];
        
        [self updateEncodingMenu];
#define CELLSTATE(x) ((x) ? NSOnState : NSOffState)
        [_detectDoubleByteButton setState:CELLSTATE([site shouldDetectDoubleByte])];
        [_detectDoubleByteMenuItem setState:CELLSTATE([site shouldDetectDoubleByte])];
        [_autoReplyButton setState:CELLSTATE([site shouldAutoReply])];
        [_autoReplyMenuItem setState:CELLSTATE([site shouldAutoReply])];
        [_mouseButton setState:CELLSTATE([site shouldEnableMouse])];
#undef CELLSTATE
    }
}

- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView {
    // all tab closed, no didSelectTabViewItem will happen
    if (tabView.numberOfTabViewItems == 0) {
        if ([WLGlobalConfig shouldEnableCoverFlow]) {
            [_mainWindow makeFirstResponder:tabView];
        } else {
            [_mainWindow makeFirstResponder:_addressBar];
        }
    }
}

@end

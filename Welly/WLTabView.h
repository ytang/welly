//
//  WLTabView.h
//  Welly
//
//  Created by K.O.ed on 10-4-20.
//  Copyright 2010 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLSitesPanelController.h"

#import "WLTerminal.h"

const NSNotificationName WLTabViewSelectionDidChangeNotification;

@class WLTerminalView;
@class WLConnection;
@class WLTabBarControl;

@protocol WLTabItemContentObserver

- (void)didChangeContent:(id)content;

@end


@interface WLTabView : NSTabView {
    IBOutlet WLTerminalView *_terminalView;
    IBOutlet WLTabBarControl *_tabBarControl;
}

// for Font size
- (IBAction)increaseFontSize:(id)sender;
- (IBAction)decreaseFontSize:(id)sender;

- (void)newTabWithConnection:(WLConnection *)theConnection 
                       label:(NSString *)theLabel;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *frontMostView;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) WLConnection *frontMostConnection;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) WLTerminal *frontMostTerminal;

@end

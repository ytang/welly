//
//  WLTouchBarController.h
//  Welly
//
//  Created by Yang Tang on 7/18/20.
//  Copyright © 2020 ytang.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLTouchBarController : NSObject {
    IBOutlet NSTouchBar *_touchBar;
    
    IBOutlet NSTouchBarItem *_sitesPanelButton;
    IBOutlet NSTouchBarItem *_reconnectButton;
    IBOutlet NSTouchBarItem *_siteNameField;
    IBOutlet NSTouchBarItem *_urlModeField;
    IBOutlet NSTouchBarItem *_flexibleSpace;
    IBOutlet NSTouchBarItem *_urlModeButton;
    IBOutlet NSTouchBarItem *_previousURLButton;
    IBOutlet NSTouchBarItem *_nextURLButton;
    IBOutlet NSTouchBarItem *_previewURLButton;
    IBOutlet NSTouchBarItem *_openURLInBrowserButton;
    IBOutlet NSTouchBarItem *_composeButton;
    IBOutlet NSTouchBarItem *_threadModeButton;
    IBOutlet NSTouchBarItem *_markModeButton;
    IBOutlet NSTouchBarItem *_authorModeButton;
    IBOutlet NSTouchBarItem *_titleModeButton;
    IBOutlet NSTouchBarItem *_emoticonsPanelButton;
    IBOutlet NSTouchBarItem *_postDownloadPanelButton;
    IBOutlet NSTouchBarItem *_composePanelButton;
}

+ (WLTouchBarController *)sharedInstance;

- (IBAction)switchURLMode:(id)sender;
- (IBAction)previousURL:(id)sender;
- (IBAction)nextURL:(id)sender;
- (IBAction)previewURL:(id)sender;
- (IBAction)openURLInBrowser:(id)sender;
- (IBAction)compose:(id)sender;
- (IBAction)threadMode:(id)sender;
- (IBAction)markMode:(id)sender;
- (IBAction)authorMode:(id)sender;
- (IBAction)titleMode:(id)sender;

- (void)resetItems;

@end

NS_ASSUME_NONNULL_END

//
//  WLSiteDelegate.h
//  Welly
//
//  Created by K.O.ed on 09-9-29.
//  Copyright 2009 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLSite.h"

#define floatWindowLevel kCGStatusWindowLevel+1

@interface WLSitesPanelController : NSObject {
    /* Sites Array */
    NSMutableArray *_sites;
    IBOutlet NSArrayController *_sitesController;
    
    /* Site Panel Outlets */
    IBOutlet NSPanel *_sitesPanel;
    IBOutlet NSTableView *_tableView;
    IBOutlet NSTextField *_siteNameField;
    IBOutlet NSTextField *_siteAddressField;
    
    IBOutlet NSPopUpButton *_proxyTypeButton;
    IBOutlet NSTextField *_proxyAddressField;
    
    /* Password Window Outlets */
    IBOutlet NSPanel *_passwordPanel;
    IBOutlet NSSecureTextField *_passwordField;
}
@property (readonly) NSArray *sites;

/* Accessors */
+ (WLSitesPanelController *)sharedInstance;
+ (NSArray *)sites;
+ (WLSite *)siteAtIndex:(NSUInteger)index;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger countOfSites;

/* Site Panel Actions */
- (IBAction)connectSelectedSite:(id)sender;
- (IBAction)closeSitesPanel:(id)sender;

- (IBAction)proxyTypeDidChange:(id)sender;
- (void)openSitesPanelInWindow:(NSWindow *)mainWindow;
- (void)openSitesPanelInWindow:(NSWindow *)mainWindow 
                    andAddSite:(WLSite *)site;

/* password window actions */
- (IBAction)openPasswordDialog:(id)sender;
- (IBAction)confirmPassword:(id)sender;
- (IBAction)cancelPassword:(id)sender;

@end

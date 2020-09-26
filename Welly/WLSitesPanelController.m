//
//  WLSiteDelegate.m
//  Welly
//
//  Created by K.O.ed on 09-9-29.
//  Copyright 2009 Welly Group. All rights reserved.
//

#import "WLSitesPanelController.h"
#import "WLMainFrameController.h"
#import "WLGlobalConfig.h"
#import "SynthesizeSingleton.h"

#define SiteTableViewDataType @"SiteTableViewDataType"
#define kSitePanelNibFilename @"SitesPanel"

@interface WLSitesPanelController()
- (void)loadSites;

/* sites accessors */
- (id)objectInSitesAtIndex:(NSUInteger)index;
- (void)getSites:(__unsafe_unretained id *)objects
           range:(NSRange)range;
- (void)insertObject:(id)anObject 
      inSitesAtIndex:(NSUInteger)index;
- (void)removeObjectFromSitesAtIndex:(NSUInteger)index;
- (void)replaceObjectInSitesAtIndex:(NSUInteger)index 
                         withObject:(id)anObject;
@end

@implementation WLSitesPanelController
@synthesize sites = _sites;

SYNTHESIZE_SINGLETON_FOR_CLASS(WLSitesPanelController)

#pragma mark -
#pragma mark Initialize and Destruction
- (instancetype)init {
    if (self = [super init]) {
        @synchronized(self) {
            // init may be called multiple times, 
            // but there is only one shared instance.
            // So we need to make sure these arrays have been alloc only once
            if (!_sites) {
                _sites = [[NSMutableArray alloc] init];
                [self loadSites];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(updateSiteNameTouchBarItem)
                                                             name:NSTableViewSelectionDidChangeNotification
                                                           object:_tableView];
            }
        }
    }
    return self;
}

- (void)loadNibFile {
    if (!_sitesPanel) {
        [[NSBundle mainBundle] loadNibNamed:kSitePanelNibFilename owner:self topLevelObjects:nil];
    }
}

- (void)awakeFromNib {
    // register drag & drop in site view
    [_tableView registerForDraggedTypes:@[SiteTableViewDataType]];
}

#pragma mark -
#pragma mark Save/Load Sites Array
- (void)loadSites {
    NSArray *array = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Sites"];
    if (!array.count) {
        [self loadDefaultSites];
        return;
    }
    for (NSDictionary *d in array)
        [self insertObject:[WLSite siteWithDictionary:d] inSitesAtIndex:self.countOfSites];
}

- (void)loadDefaultSites {
    [self insertObject:[WLSite siteWithName:@"水木社区"
                                    address:@"bbs.newsmth.net"
                                   encoding:WLGBKEncoding
                               ansiColorKey:YLEscEscANSIColorKey]
        inSitesAtIndex:self.countOfSites];
    [self insertObject:[WLSite siteWithName:@"未名空间"
                                    address:@"mitbbs.com"
                                   encoding:WLGBKEncoding
                               ansiColorKey:YLEscEscANSIColorKey]
        inSitesAtIndex:self.countOfSites];
    [self insertObject:[WLSite siteWithName:@"批踢踢實業坊"
                                    address:@"ssh://bbs@ptt.cc"
                                   encoding:WLBig5Encoding
                               ansiColorKey:YLCtrlUANSIColorKey]
        inSitesAtIndex:WLGlobalConfig.sharedInstance.defaultEncoding == WLBig5Encoding ? 0 : self.countOfSites];
}

- (void)saveSites {
    NSMutableArray *a = [NSMutableArray array];
    for (WLSite *s in _sites)
        [a addObject:[s dictionaryOfSite]];
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:@"Sites"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Site Panel Actions
- (void)openSitesPanelInWindow:(NSWindow *)mainWindow {
    // Load Nib file if necessary
    [self loadNibFile];
    [NSApp beginSheet:_sitesPanel
       modalForWindow:mainWindow
        modalDelegate:nil
       didEndSelector:NULL
          contextInfo:nil];
    [_sitesPanel setLevel:floatWindowLevel];
    [self updateSiteNameTouchBarItem];
}

- (void)openSitesPanelInWindow:(NSWindow *)mainWindow 
                    andAddSite:(WLSite *)site {
    site = [site copy];
    //[self performSelector:@selector(openSitesPanelInWindow:) withObject:mainWindow afterDelay:0.1];
    [self openSitesPanelInWindow:mainWindow];
    [_sitesController addObject:site];
    [_sitesController setSelectedObjects:@[site]];
    if (_siteNameField.acceptsFirstResponder)
        [_sitesPanel makeFirstResponder:_siteNameField];
}

- (IBAction)connectSelectedSite:(id)sender {
    NSArray *a = _sitesController.selectedObjects;
    [self closeSitesPanel:sender];
    
    if (a.count == 1) {
        WLSite *s = a[0];
        [[WLMainFrameController sharedInstance] newConnectionWithSite:[s copy]];
    }
}

- (IBAction)closeSitesPanel:(id)sender {
    [_sitesPanel endEditingFor:nil];
    [NSApp endSheet:_sitesPanel];
    [_sitesPanel orderOut:self];
    [self saveSites];
}

- (IBAction)proxyTypeDidChange:(id)sender {
    _proxyAddressField.enabled = (_proxyTypeButton.indexOfSelectedItem >= 2);
}

#pragma mark -
#pragma mark Password Window Actions
- (IBAction)openPasswordDialog:(id)sender {
    NSString *siteAddress = _siteAddressField.stringValue;
    if (siteAddress.length == 0)
        return;
    _sitesPanel.level = 0;
    if (![siteAddress hasPrefix:@"ssh"] && [siteAddress rangeOfString:@"@"].location == NSNotFound) {
        NSBeginAlertSheet(NSLocalizedString(@"Site address format error", @"Sheet Title"),
                          nil,
                          nil,
                          nil,
                          _sitesPanel,
                          self,
                          nil,
                          nil,
                          nil,
                          NSLocalizedString(@"Your BBS ID (username) should be provided explicitly by \"id@\" in the site address field in order to use auto-login for telnet connections.", @"Sheet Message"));
        return;
    }
    [NSApp beginSheet:_passwordPanel
       modalForWindow:_sitesPanel
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
}

- (IBAction)confirmPassword:(id)sender {
    [_passwordPanel endEditingFor:nil];
    const char *service = "Welly";
    const char *account = _siteAddressField.stringValue.UTF8String;
    SecKeychainItemRef itemRef;
    if (!SecKeychainFindGenericPassword(nil,
                                        (UInt32)strlen(service), service,
                                        (UInt32)strlen(account), account,
                                        nil, nil,
                                        &itemRef))
        SecKeychainItemDelete(itemRef);
    const char *pass = _passwordField.stringValue.UTF8String;
    if (*pass) {
        SecKeychainAddGenericPassword(nil,
                                      (UInt32)strlen(service), service,
                                      (UInt32)strlen(account), account,
                                      (UInt32)strlen(pass), pass,
                                      nil);
    }
    _passwordField.stringValue = @"";
    [NSApp endSheet:_passwordPanel];
    [_passwordPanel orderOut:self];
}

- (IBAction)cancelPassword:(id)sender {
    [_passwordPanel endEditingFor:nil];
    _passwordField.stringValue = @"";
    [NSApp endSheet:_passwordPanel];
    [_passwordPanel orderOut:self];
}

#pragma mark -
#pragma mark Site View Drag & Drop
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    // copy to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:@[SiteTableViewDataType] owner:self];
    [pboard setData:data forType:SiteTableViewDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv 
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row 
       proposedDropOperation:(NSTableViewDropOperation)op {
    // don't hover
    if (op == NSTableViewDropOn)
        return NSDragOperationNone;
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView 
       acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row 
    dropOperation:(NSTableViewDropOperation)op {
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:SiteTableViewDataType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = rowIndexes.firstIndex;
    // move
    NSObject *obj = _sites[dragRow];
    [_sitesController insertObject:obj atArrangedObjectIndex:row];
    if (row < dragRow)
        ++dragRow;
    [_sitesController removeObjectAtArrangedObjectIndex:dragRow];
    // done
    return YES;
}

#pragma mark -
#pragma mark Sites Accessors
+ (NSArray *)sites {
    return [self sharedInstance].sites;
}

+ (WLSite *)siteAtIndex:(NSUInteger)index {
    return [[self sharedInstance] objectInSitesAtIndex:index];
}

- (NSUInteger)countOfSites {
    return _sites.count;
}

- (id)objectInSitesAtIndex:(NSUInteger)index {
    if (index >= _sites.count)
        return NULL;
    return _sites[index];
}

- (void)getSites:(__unsafe_unretained id *)objects
           range:(NSRange)range {
    [_sites getObjects:objects range:range];
}

- (void)insertObject:(id)anObject 
      inSitesAtIndex:(NSUInteger)index {
    [_sites insertObject:anObject atIndex:index];
}

- (void)removeObjectFromSitesAtIndex:(NSUInteger)index {
    [_sites removeObjectAtIndex:index];
}

- (void)replaceObjectInSitesAtIndex:(NSUInteger)index 
                         withObject:(id)anObject {
    _sites[index] = anObject;
}

#pragma mark -
#pragma mark Touch Bar
- (void)updateSiteNameTouchBarItem {
    NSArray *selectedSites = _sitesController.selectedObjects;
    if (selectedSites.count == 1) {
        WLSite *site = selectedSites[0];
        _siteNameTouchBarField.stringValue = site.name;
        _siteNamePasswordTouchBarField.stringValue = site.name;
    }
}
@end

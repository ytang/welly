//
//  DBPrefsWindowController.m
//

#import "DBPrefsWindowController.h"
#import "WLGlobalConfig.h"
#import <ApplicationServices/ApplicationServices.h>

static DBPrefsWindowController *_sharedPrefsWindowController = nil;

@interface DBPrefsWindowController (Private)
- (void) setupMenuOfURLScheme: (NSString *) scheme forPopUpButton: (NSPopUpButton *) button ;
+ (NSArray *) applicationIdentifierArrayForURLScheme: (NSString *) scheme ;
@end

@implementation DBPrefsWindowController

#pragma mark -
#pragma mark Class Methods


+ (DBPrefsWindowController *)sharedPrefsWindowController
{
    if (!_sharedPrefsWindowController) {
        _sharedPrefsWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
    }
    return _sharedPrefsWindowController;
}

+ (NSArray *)applicationIdentifierArrayForURLScheme: (NSString *) scheme {
    CFArrayRef array = LSCopyAllHandlersForURLScheme((__bridge CFStringRef)scheme);
    NSMutableArray *result = [NSMutableArray arrayWithArray: (__bridge NSArray *) array];
    CFRelease(array);
    return result;
}


+ (NSString *)nibName
// Subclasses can override this to use a nib with a different name.
{
    return @"Preferences";
}

#pragma mark -
#pragma mark Setup & Teardown

- (void)setupMenuOfURLScheme:(NSString *)scheme 
              forPopUpButton:(NSPopUpButton *)button {
    NSString *wellyIdentifier = [NSBundle mainBundle].bundleIdentifier.lowercaseString;
    NSMutableArray *array = [NSMutableArray arrayWithArray: [DBPrefsWindowController applicationIdentifierArrayForURLScheme: scheme]];
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];
    NSMutableArray *menuItems = [NSMutableArray array];
    
    int wellyCount = 0;
    for (NSString *appId in array) 
        if ([appId.lowercaseString isEqualToString: wellyIdentifier]) 
            wellyCount++;
    if (wellyCount == 0)
        [array addObject: [NSBundle mainBundle].bundleIdentifier];
    
    for (NSString *appId in array) {
        CFStringRef appNameInCFString;
        NSString *appPath = [ws absolutePathForAppBundleWithIdentifier: appId];
        if (appPath) {
            NSURL *appURL = [NSURL fileURLWithPath: appPath];
            if (LSCopyDisplayNameForURL((__bridge CFURLRef)appURL, &appNameInCFString) == noErr) {                
                NSString *appName = [NSString stringWithString: (__bridge NSString *) appNameInCFString];
                CFRelease(appNameInCFString);
                
                if (wellyCount > 1 && [appId.lowercaseString isEqualToString: wellyIdentifier])
                    appName = [NSString stringWithFormat:@"%@ (%@)", appName, [NSBundle bundleWithPath: appPath].infoDictionary[@"CFBundleVersion"]];
                
                NSImage *appIcon = [ws iconForFile:appPath];
                appIcon.size = NSMakeSize(16, 16);
                
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle: (NSString *)appName action: NULL keyEquivalent: @""];
                item.representedObject = appId;
                if (appIcon) item.image = appIcon;
                [menuItems addObject: item];
            }            
        }
    }
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle: @"PopUp Menu"];
    for (NSMenuItem *item in menuItems) 
        [menu addItem: item];
    button.menu = menu;
    
    /* Select the default client */
    CFStringRef defaultHandler = LSCopyDefaultHandlerForURLScheme((__bridge CFStringRef) scheme);
    if (defaultHandler) {
        NSInteger index = [button indexOfItemWithRepresentedObject: (__bridge NSString *) defaultHandler];
        if (index != -1) 
            [button selectItemAtIndex: index];
        CFRelease(defaultHandler);
    }
}

- (void)awakeFromNib {
    [self setupMenuOfURLScheme:@"telnet" forPopUpButton:_telnetPopUpButton];
    [self setupMenuOfURLScheme:@"ssh" forPopUpButton:_sshPopUpButton];
}

- (instancetype)initWithWindow:(NSWindow *)window
// -initWithWindow: is the designated initializer for NSWindowController.
{
    self = [super initWithWindow:nil];
    if (self != nil) {
        // Set up an array and some dictionaries to keep track
        // of the views we'll be displaying.
        toolbarIdentifiers = [[NSMutableArray alloc] init];
        toolbarViews = [[NSMutableDictionary alloc] init];
        toolbarItems = [[NSMutableDictionary alloc] init];
        
        // Set up an NSViewAnimation to animate the transitions.
        viewAnimation = [[NSViewAnimation alloc] init];
        viewAnimation.animationBlockingMode = NSAnimationNonblocking;
        viewAnimation.animationCurve = NSAnimationEaseInOut;
        viewAnimation.delegate = self;
    }
    return self;
}




- (void)windowDidLoad
{
    // Create a new window to display the preference views.
    // If the developer attached a window to this controller
    // in Interface Builder, it gets replaced with this one.
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1000,1000)
                                                   styleMask:(NSTitledWindowMask |
                                                              NSClosableWindowMask |
                                                              NSMiniaturizableWindowMask)
                                                     backing:NSBackingStoreBuffered
                                                       defer:YES];
    self.window = window;
    contentSubview = [[NSView alloc] initWithFrame:self.window.contentView.frame];
    contentSubview.autoresizingMask = (NSViewMinYMargin | NSViewWidthSizable);
    [self.window.contentView addSubview:contentSubview];
    [self.window setShowsToolbarButton:NO];
    if (@available(macOS 10.16, *)) {
        [self.window setToolbarStyle:NSWindowToolbarStylePreference];
    }
}






#pragma mark -
#pragma mark Actions


- (IBAction) setChineseFont: (id) sender {
    [NSFontManager sharedFontManager].action = @selector(changeChineseFont:);
    [[sender window] makeFirstResponder: [sender window]];
    NSFontPanel *fp = [NSFontPanel sharedFontPanel];
    [fp setPanelFont: [NSFont fontWithName: [WLGlobalConfig sharedInstance].chineseFontName size: [WLGlobalConfig sharedInstance].chineseFontSize] isMultiple: NO];
    [fp orderFront: self];
}

- (IBAction) setEnglishFont: (id) sender {
    [NSFontManager sharedFontManager].action = @selector(changeEnglishFont:);
    [[sender window] makeFirstResponder: [sender window]];
    NSFontPanel *fp = [NSFontPanel sharedFontPanel];
    [fp setPanelFont: [NSFont fontWithName: [WLGlobalConfig sharedInstance].englishFontName size: [WLGlobalConfig sharedInstance].englishFontSize] isMultiple: NO];
    [fp orderFront: self];
}

- (void) changeChineseFont: (id) sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *selectedFont = fontManager.selectedFont;
    
    if (selectedFont == nil) {
        selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    }
    
    NSFont *panelFont = [fontManager convertFont:selectedFont];
    [WLGlobalConfig sharedInstance].chineseFontName = panelFont.fontName;
    [WLGlobalConfig sharedInstance].chineseFontSize = panelFont.pointSize;
}

- (void) changeEnglishFont: (id) sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *selectedFont = fontManager.selectedFont;
    
    if (selectedFont == nil) {
        selectedFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    }
    
    NSFont *panelFont = [fontManager convertFont:selectedFont];
    [WLGlobalConfig sharedInstance].englishFontName = panelFont.fontName;
    [WLGlobalConfig sharedInstance].englishFontSize = panelFont.pointSize;
    
}

- (IBAction) setDefaultTelnetClient: (id) sender {
    NSString *appId = [sender selectedItem].representedObject;
    if (appId) 
        LSSetDefaultHandlerForURLScheme(CFSTR("telnet"), (__bridge CFStringRef)appId);
}

- (IBAction) setDefaultSSHClient: (id) sender {
    NSString *appId = [sender selectedItem].representedObject;
    if (appId) 
        LSSetDefaultHandlerForURLScheme(CFSTR("ssh"), (__bridge CFStringRef)appId);    
}

#pragma mark -
#pragma mark Configuration


- (void)setupToolbar
{
    [self addView: _generalPrefView label: NSLocalizedString(@"General", @"Preferences") image: [NSImage imageNamed: @"NSPreferencesGeneral"]];
    [self addView: _connectionPrefView label: NSLocalizedString(@"Connection", @"Preferences") image: [NSImage imageNamed: @"NSApplicationIcon"]];
    [self addView: _fontsPrefView label: NSLocalizedString(@"Fonts", @"Preferences") image: [NSImage imageNamed: @"NSFontPanel"]];
    [self addView: _colorsPrefView label: NSLocalizedString(@"Colors", @"Preferences") image: [NSImage imageNamed: @"NSColorPanel"]];
}




- (void)addView:(NSView *)view label:(NSString *)label
{
    [self addView:view
            label:label
            image:[NSImage imageNamed:label]];
}


- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image
{
    NSAssert (view != nil,
              @"Attempted to add a nil view when calling -addView:label:image:.");
    
    NSString *identifier = [label copy];
    
    [toolbarIdentifiers addObject:identifier];
    toolbarViews[identifier] = view;
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    item.label = label;
    item.image = image;
    item.target = self;
    item.action = @selector(toggleActivePreferenceView:);
    
    toolbarItems[identifier] = item;
}


#pragma mark -
#pragma mark Accessor Methods


- (BOOL)crossFade
{
    return _crossFade;
}




- (void)setCrossFade:(BOOL)fade
{
    _crossFade = fade;
}




- (BOOL)shiftSlowsAnimation
{
    return _shiftSlowsAnimation;
}




- (void)setShiftSlowsAnimation:(BOOL)slows
{
    _shiftSlowsAnimation = slows;
}




#pragma mark -
#pragma mark Overriding Methods


- (IBAction)showWindow:(id)sender 
{
    // This forces the resources in the nib to load.
    (void)self.window;
    
    // Clear the last setup and get a fresh one.
    [toolbarIdentifiers removeAllObjects];
    [toolbarViews removeAllObjects];
    [toolbarItems removeAllObjects];
    [self setupToolbar];
    
    NSAssert (([toolbarIdentifiers count] > 0),
              @"No items were added to the toolbar in -setupToolbar.");
    
    if (self.window.toolbar == nil) {
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"DBPreferencesToolbar"];
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:NO];
        toolbar.sizeMode = NSToolbarSizeModeDefault;
        toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
        toolbar.delegate = self;
        self.window.toolbar = toolbar;
    }
    
    NSString *firstIdentifier = toolbarIdentifiers[0];
    self.window.toolbar.selectedItemIdentifier = firstIdentifier;
    [self displayViewForIdentifier:firstIdentifier animate:NO];
    
    [self.window center];
    
    [super showWindow:sender];
}




#pragma mark -
#pragma mark Toolbar


- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return toolbarIdentifiers;
}




- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar 
{
    return toolbarIdentifiers;
}




- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return toolbarIdentifiers;
}




- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted 
{
    return toolbarItems[identifier];
}




- (void)toggleActivePreferenceView:(NSToolbarItem *)toolbarItem
{
    [self displayViewForIdentifier:toolbarItem.itemIdentifier animate:YES];
}




- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate
{	
    // Find the view we want to display.
    NSView *newView = toolbarViews[identifier];
    
    // See if there are any visible views.
    NSView *oldView = nil;
    if (contentSubview.subviews.count > 0) {
        // Get a list of all of the views in the window. Usually at this
        // point there is just one visible view. But if the last fade
        // hasn't finished, we need to get rid of it now before we move on.
        NSEnumerator *subviewsEnum = [contentSubview.subviews reverseObjectEnumerator];
        
        // The first one (last one added) is our visible view.
        oldView = [subviewsEnum nextObject];
        
        // Remove any others.
        NSView *reallyOldView = nil;
        while ((reallyOldView = [subviewsEnum nextObject]) != nil) {
            [reallyOldView removeFromSuperviewWithoutNeedingDisplay];
        }
    }
    
    if (![newView isEqualTo:oldView]) {		
        NSRect frame = newView.bounds;
        frame.origin.y = NSHeight(contentSubview.frame) - NSHeight(newView.bounds);
        newView.frame = frame;
        [contentSubview addSubview:newView];
        self.window.initialFirstResponder = newView;
        
        if (animate && self.crossFade)
            [self crossFadeView:oldView withView:newView];
        else {
            [oldView removeFromSuperviewWithoutNeedingDisplay];
            [newView setHidden:NO];
            [self.window setFrame:[self frameForView:newView] display:YES animate:animate];
        }
        
        self.window.title = [toolbarItems[identifier] label];
    }
}




#pragma mark -
#pragma mark Cross-Fading Methods


- (void)crossFadeView:(NSView *)oldView withView:(NSView *)newView
{
    [viewAnimation stopAnimation];
    
    if (self.shiftSlowsAnimation && self.window.currentEvent.modifierFlags & NSShiftKeyMask)
        viewAnimation.duration = 1.25;
    else
        viewAnimation.duration = 0.25;
    
    NSDictionary *fadeOutDictionary = @{NSViewAnimationTargetKey: oldView,
                                        NSViewAnimationEffectKey: NSViewAnimationFadeOutEffect};
    
    NSDictionary *fadeInDictionary = @{NSViewAnimationTargetKey: newView,
                                       NSViewAnimationEffectKey: NSViewAnimationFadeInEffect};
    
    NSDictionary *resizeDictionary = @{NSViewAnimationTargetKey: self.window,
                                       NSViewAnimationStartFrameKey: [NSValue valueWithRect:self.window.frame],
                                       NSViewAnimationEndFrameKey: [NSValue valueWithRect:[self frameForView:newView]]};
    
    NSArray *animationArray = @[fadeOutDictionary,
                                fadeInDictionary,
                                resizeDictionary];
    
    viewAnimation.viewAnimations = animationArray;
    [viewAnimation startAnimation];
}




- (void)animationDidEnd:(NSAnimation *)animation
{
    NSView *subview;
    
    // Get a list of all of the views in the window. Hopefully
    // at this point there are two. One is visible and one is hidden.
    NSEnumerator *subviewsEnum = [contentSubview.subviews reverseObjectEnumerator];
    
    // This is our visible view. Just get past it.
    //subview = [subviewsEnum nextObject];
    [subviewsEnum nextObject];
    
    // Remove everything else. There should be just one, but
    // if the user does a lot of fast clicking, we might have
    // more than one to remove.
    while ((subview = [subviewsEnum nextObject]) != nil) {
        [subview removeFromSuperviewWithoutNeedingDisplay];
    }
    
    // This is a work-around that prevents the first
    // toolbar icon from becoming highlighted.
    [self.window makeFirstResponder:nil];
    
    (void)animation;
}




- (NSRect)frameForView:(NSView *)view
// Calculate the window size for the new view.
{
    NSRect windowFrame = self.window.frame;
    NSRect contentRect = [self.window contentRectForFrameRect:windowFrame];
    float windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
    
    windowFrame.size.height = NSHeight(view.frame) + windowTitleAndToolbarHeight;
    windowFrame.size.width = NSWidth(view.frame);
    windowFrame.origin.y = NSMaxY(self.window.frame) - NSHeight(windowFrame);
    
    return windowFrame;
}




@end

//
//  WLTabView.m
//  Welly
//
//  Created by K.O.ed on 10-4-20.
//  Copyright 2010 Welly Group. All rights reserved.
//

#import "WLTabView.h"
#import "WLConnection.h"
#import "WLTerminalView.h"
#import "WLMainFrameController.h"
#import "WLTabBarControl.h"

#import "WLTabBarDummyItem.h"

#import "WLGlobalConfig.h"

@implementation WLTabView

- (void)awakeFromNib {
    self.tabViewType = NSNoTabsNoBorder;
    
    // Register KVO
    NSArray *observeKeys = @[@"cellWidth", @"cellHeight", @"cellSize"];
    for (NSString *key in observeKeys)
        [[WLGlobalConfig sharedInstance] addObserver:self
                                          forKeyPath:key
                                             options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) 
                                             context:nil];
    
    // Set frame position and size
    [self setFrameOrigin:NSZeroPoint];
    [self setFrameSize:[WLGlobalConfig sharedInstance].contentSize];
}

#pragma mark -
#pragma mark Drawing
- (void)drawRect:(NSRect)rect {
    // Drawing the background.
    [[WLGlobalConfig sharedInstance].colorBG set];
    NSRectFill(rect);
}

#pragma mark -
#pragma mark Accessor
- (NSView *)frontMostView {
    return self.selectedTabViewItem.view;
}

- (WLConnection *)frontMostConnection {
    if ([self.selectedTabViewItem.identifier isKindOfClass:[WLConnection class]]) {
        return self.selectedTabViewItem.identifier;
    }
    
    return nil;
}

- (WLTerminal *)frontMostTerminal {
    return self.frontMostConnection.terminal;
}

- (BOOL)isSelectedTabEmpty {
    return self.frontMostConnection && (self.frontMostTerminal == nil);
}

#pragma mark -
#pragma mark Adding and removing a tab
- (NSTabViewItem *)emptyTab {
    NSTabViewItem *tabViewItem;
    if ([self isSelectedTabEmpty]) {
        // reuse the empty tab
        tabViewItem = self.selectedTabViewItem;
    } else {	
        // open a new tab
        WLTabBarDummyItem *newItem = [[WLTabBarDummyItem alloc] init];
        tabViewItem = [[NSTabViewItem alloc] initWithIdentifier:newItem];
        // this will invoke tabView:didSelectTabViewItem for the first tab
        [self addTabViewItem:tabViewItem];
    }
    return tabViewItem;
}

- (void)newTabWithConnection:(WLConnection *)theConnection 
                       label:(NSString *)theLabel {	
    NSTabViewItem *tabViewItem = [self emptyTab];
    
    [tabViewItem setIdentifier:theConnection];
    
    // set appropriate label
    if (theLabel) {
        tabViewItem.label = theLabel;
    }
    
    // set the view
    tabViewItem.view = _terminalView;
    
    if (!(theConnection.site).dummy) {
        // Create a new terminal for receiving connection's content, and forward to view
        WLTerminal *terminal = [[WLTerminal alloc] init];
        [terminal addObserver:_terminalView];
        theConnection.terminal = terminal;
    }
    
    // select the tab
    [self selectTabViewItem:nil];
    [self selectTabViewItem:tabViewItem];
}

#pragma mark -
#pragma mark Override
- (void)selectTabViewItem:(NSTabViewItem *)tabViewItem {
    NSView *oldView = self.selectedTabViewItem.view;
    [super selectTabViewItem:tabViewItem];
    
    NSView *currentView = self.selectedTabViewItem.view;
    [self.window makeFirstResponder:currentView];
    [self.window makeKeyWindow];
    
    if ([currentView conformsToProtocol:@protocol(WLTabItemContentObserver)]) {
        [(id <WLTabItemContentObserver>)currentView didChangeContent:self.selectedTabViewItem.identifier];
    }
    
    if ((oldView != currentView) && [oldView conformsToProtocol:@protocol(WLTabItemContentObserver)]) {
        [(id <WLTabItemContentObserver>)oldView didChangeContent:nil];
    }
}

- (void)removeTabViewItem:(NSTabViewItem *)tabViewItem {
    NSView *oldView = tabViewItem.view;
    [super removeTabViewItem:tabViewItem];
    
    if (self.numberOfTabViewItems == 0) {
        if ([oldView conformsToProtocol:@protocol(WLTabItemContentObserver)]) {
            [(id <WLTabItemContentObserver>)oldView didChangeContent:nil];
        }
    }
}

- (void)selectNextTabViewItem:(NSTabViewItem *)tabViewItem {
    if([self indexOfTabViewItem:self.selectedTabViewItem] == self.numberOfTabViewItems - 1)
        [self selectFirstTabViewItem:self];
    else
        [super selectNextTabViewItem:self];
}

- (void)selectPreviousTabViewItem:(NSTabViewItem *)tabViewItem {
    if([self indexOfTabViewItem:self.selectedTabViewItem] == 0)
        [self selectLastTabViewItem:self];
    else
        [super selectPreviousTabViewItem:self];
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (BOOL)becomeFirstResponder {
    return [self.window makeFirstResponder:self.frontMostView];
}

#pragma mark -
#pragma mark Event Handling
// Respond to key equivalent: 
// Cmd+[0-9], Ctrl+Tab, Cmd+Shift+Left/Right (I don't know if we should keep this)
// Added by K.O.ed, 2009.02.02
- (BOOL)performKeyEquivalent:(NSEvent *)event {
    if (((event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask) && 
        ((event.modifierFlags & NSShiftKeyMask) == NSShiftKeyMask) &&
        ([event.charactersIgnoringModifiers isEqualToString:keyStringLeft] ||
         [event.charactersIgnoringModifiers isEqualToString:@"{"])) {
        [self selectPreviousTabViewItem:self];
        return YES;
    } else if (((event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask) && 
               ((event.modifierFlags & NSShiftKeyMask) == NSShiftKeyMask) &&
               ([event.charactersIgnoringModifiers isEqualToString:keyStringRight] ||
                [event.charactersIgnoringModifiers isEqualToString:@"}"])) {
        [self selectNextTabViewItem:self];
        return YES;
    } else if ((event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask && 
               (event.modifierFlags & NSAlternateKeyMask) == 0 && 
               (event.modifierFlags & NSControlKeyMask) == 0 && 
               (event.modifierFlags & NSShiftKeyMask) == 0 && 
               event.characters.intValue > 0 && 
               event.characters.intValue < 10) {
        // User may drag and re-order tabs using tabBarControl
        // These re-ordering will not reflect when calling
        // Update 2017.08.19: These re-ordering now will be correctly reflected
        NSInteger index = event.characters.integerValue;
        if (index <= [self numberOfTabViewItems]) {
            [self selectTabViewItemAtIndex:index - 1];
        }
        return YES;
    } else if ((event.modifierFlags & NSCommandKeyMask) == 0 && 
               (event.modifierFlags & NSAlternateKeyMask) == 0 && 
               (event.modifierFlags & NSControlKeyMask) && 
               (event.modifierFlags & NSShiftKeyMask) == 0 && 
               [event.characters characterAtIndex:0] == '\t') {
        [self selectNextTabViewItem:self];
        return YES;
    } else if ((event.modifierFlags & NSCommandKeyMask) == 0 && 
               (event.modifierFlags & NSAlternateKeyMask) == 0 && 
               (event.modifierFlags & NSControlKeyMask)  && 
               (event.modifierFlags & NSShiftKeyMask) && 
               (event.keyCode == 48)) {
        //keyCode 48: back-tab
        [self selectPreviousTabViewItem:self];
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath hasPrefix:@"cell"]) {
        [self setFrameSize:[WLGlobalConfig sharedInstance].contentSize];
    }
}

#pragma mark -
#pragma mark Trackpad Gesture Support
// Set and reset font size
- (void)setFontSizeRatio:(CGFloat)ratio {
    [[WLGlobalConfig sharedInstance] setFontSizeRatio:ratio];
    [self setNeedsDisplay:YES];
}

// Increase global font size setting by 5%
- (void)increaseFontSize:(id)sender {
    // Here we use some small trick to provide better user experimence...
    [self setFontSizeRatio:1.05f];
}

// Decrease global font size setting by 5%
- (void)decreaseFontSize:(id)sender {
    [self setFontSizeRatio:1.0f/1.05f];
}

//- (void)magnifyWithEvent:(NSEvent *)event {
//	[self setFontSizeRatio:[event magnification]+1.0];
//}

- (void)swipeWithEvent:(NSEvent *)event {
    if (event.deltaX < 0) {
        // Swiping to right
        [self selectNextTabViewItem:event];
        return;
    } else if (event.deltaX > 0) {
        // Swiping to left
        [self selectPreviousTabViewItem:event];
        return;
    }
    [super swipeWithEvent:event];
}
@end

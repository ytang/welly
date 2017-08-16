//
//  XITabBarControl.m
//  Welly
//
//  Created by boost @ 9# on 7/14/08.
//  Copyright 2008 Xi Wang. All rights reserved.
//

#import "WLTabBarControl.h"
#import "WLMainFrameController.h"
#import "CommonType.h"

// suppress warnings
@interface PSMTabBarControl ()
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *cells;
- (id)cellForPoint:(NSPoint)mousePt 
		 cellFrame:(NSRect *)cellFrame;
- (void)closeTabClick:(id)sender;
@end

@implementation WLTabBarControl
- (void)mouseDown:(NSEvent *)theEvent {
    // double click
    if (theEvent.clickCount > 1) {
        // PSMTabBarControl: detect if on cells
        NSPoint mousePt = [self convertPoint:theEvent.locationInWindow fromView:nil];
        NSRect cellFrame;
        id cell = [self cellForPoint:mousePt cellFrame:&cellFrame];
        // not on any cell: new tab
        if (!cell) {
            NSButton *button = (NSButton *)[self addTabButton];
            [button performClick:button];
        }
    }
    [super mouseDown:theEvent];
}

- (void)selectTabViewItemAtIndex:(NSInteger)index {
    NSTabViewItem *tabViewItem = [self.cells[index] representedObject];
    [[self tabView] selectTabViewItem:tabViewItem];
}

- (void)selectFirstTabViewItem:(id)sender {
    if (self.cells.count > 0)
        [self selectTabViewItemAtIndex:0];
}

- (void)selectLastTabViewItem:(id)sender {
    NSUInteger count = self.cells.count;
    if (count > 0)
        [self selectTabViewItemAtIndex:count-1];
}

- (NSInteger)indexOfTabViewItem:(NSTabViewItem *)tabViewItem {
    size_t count = self.cells.count;
    for (size_t i = 0; i < count; ++i) {
        if ([[self.cells[i] representedObject] isEqualTo:tabViewItem])
            return i;
    }
    return -1;
}

- (void)selectNextTabViewItem:(id)sender {
    NSTabViewItem *sel = [self tabView].selectedTabViewItem;
    if (sel == nil)
        return;
    NSInteger index = [self indexOfTabViewItem:sel] + 1;
    if (index == self.cells.count)
        index = 0;
    [self selectTabViewItemAtIndex:index];
}

- (void)selectPreviousTabViewItem:(id)sender {
    NSTabViewItem *sel = [self tabView].selectedTabViewItem;
    if (sel == nil)
        return;
    NSInteger index = [self indexOfTabViewItem:sel];
    if (index == 0)
        [self selectLastTabViewItem:sender];
    else
        [self selectTabViewItemAtIndex:index-1];
}

#pragma mark -
- (void)removeTabViewItem:(NSTabViewItem *)tabViewItem {
    NSInteger index = [self indexOfTabViewItem:tabViewItem];
    [self closeTabClick:self.cells[index]];
}

#pragma mark - Set main controller
- (void)setMainController:(WLMainFrameController *)controller {
	_currMainController = controller;
}
@end

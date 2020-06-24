//
//  WLPortal.h
//  Welly
//
//  Created by boost on 9/6/09.
//  Copyright 2009 Xi Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WLPortalItem;
@interface WLCoverFlowPortal : NSView <NSComboBoxDataSource> {
    NSArray *_portalItems;
    id _imageFlowView;
    WLPortalItem *_draggingItem;
}

//@property (readonly) NSView *view;
- (void)awakeFromNib;
- (void)setPortalItems:(NSArray *)portalItems;

- (void)keyDown:(NSEvent *)theEvent;
- (void)mouseDragged:(NSEvent *)theEvent;

@end

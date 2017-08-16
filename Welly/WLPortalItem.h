//
//  WLPortalItem.h
//  Welly
//
//  Created by K.O.ed on 10-4-17.
//  Copyright 2010 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol WLPortalSource

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSImage *image;
- (void)didSelect:(id)sender;

@end

@protocol WLDraggingSource

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL acceptsDragging;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSImage *draggingImage;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSPasteboard *draggingPasteboard;
- (void)draggedToRemove:(id)sender;

@end

@protocol WLPasteboardReceiver

- (BOOL)acceptsPBoard:(NSPasteboard *)pboard;
- (BOOL)didReceivePBoard:(NSPasteboard *)pboard;

@end



@interface WLPortalItem : NSObject <WLPortalSource> {
    NSString *_title;
    NSImage  *_image;
}

@property (readonly) NSString *imageTitle;
@property (readonly, copy) NSImage *image;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithImage:(NSImage *)theImage;
- (instancetype)initWithImage:(NSImage *)theImage title:(NSString *)title;

#pragma mark -
#pragma mark IKImageBrowserItem protocol
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *imageUID;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *imageRepresentationType;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id imageRepresentation;
- (NSString *)imageTitle;

#pragma mark -
#pragma mark WLPortalSource protocol
- (void)didSelect:(id)sender;
@end

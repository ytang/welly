//
//  XIQuickLookBridge.h
//  Preview via Quick Look
//
//  Created by boost @ 9# on 7/11/08.
//  Copyright 2008 Xi Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface WLQuickLookBridge : NSObject <QLPreviewPanelDataSource> {
    NSMutableArray *_URLs;
}

+ (void)orderFront;
+ (void)add:(NSURL *)URL;

@end

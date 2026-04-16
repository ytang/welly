//
//  XIQuickLookBridge.m
//  Preview via Quick Look
//
//  Created by boost @ 9# on 7/11/08.
//  Copyright 2008 Xi Wang. All rights reserved.
//

#import "WLQuickLookBridge.h"
#import "SynthesizeSingleton.h"

@implementation WLQuickLookBridge

SYNTHESIZE_SINGLETON_FOR_CLASS(WLQuickLookBridge)

- (instancetype)init {
    self = [super init];
    if (self) {
        _URLs = [[NSMutableArray alloc] init];
        _EXIFs = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (void)orderFront {
    [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
}

+ (void)add:(NSURL *)URL {
    [self add:URL withEXIF:@""];
}

+ (void)add:(NSURL *)URL withEXIF:(NSString *)EXIF {
    NSMutableArray *URLs = [self sharedInstance]->_URLs;
    // check if the url is already under preview
    NSUInteger index = [URLs indexOfObject:URL];
    if (index == NSNotFound) {
        index = URLs.count;
        [URLs addObject:URL];
        [[self sharedInstance]->_EXIFs addObject:EXIF];
    }
    // Install data source/delegate and set the index BEFORE orderFront so
    // the panel's first paint renders the correct item. Otherwise the panel
    // briefly shows the previous currentPreviewItemIndex (the last picture
    // the user viewed) before switching, producing a visible flash.
    QLPreviewPanel *panel = [QLPreviewPanel sharedPreviewPanel];
    panel.dataSource = [self sharedInstance];
    panel.delegate = [self sharedInstance];
    [panel setCurrentPreviewItemIndex:index];
    [self orderFront];
}

#pragma mark -
#pragma mark QLPreviewPanelDataSource protocol

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    return _URLs.count;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel
                previewItemAtIndex:(NSInteger)index {
    panel.contentView.toolTip = _EXIFs[panel.currentPreviewItemIndex];
    return _URLs[index];
}

@end

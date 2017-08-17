//
//  WLEmoticonDelegate.m
//  Welly
//
//  Created by K.O.ed on 09-9-27.
//  Copyright 2009 Welly Group. All rights reserved.
//

#import "WLEmoticonsPanelController.h"
#import "YLEmoticon.h"
#import "SynthesizeSingleton.h"

#define kEmoticonPanelNibFilename @"EmoticonsPanel"

@interface WLEmoticonsPanelController ()
- (void)loadNibFile;
- (void)loadEmoticons;
- (void)saveEmoticons;

// emoticons accessors
- (void)addEmoticon:(YLEmoticon *)emoticon;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger countOfEmoticons;
- (id)objectInEmoticonsAtIndex:(NSUInteger)theIndex;
- (void)getEmoticons:(id *)objsPtr 
			   range:(NSRange)range;
- (void)insertObject:(id)obj 
  inEmoticonsAtIndex:(NSUInteger)theIndex;
- (void)removeObjectFromEmoticonsAtIndex:(NSUInteger)theIndex;
- (void)replaceObjectInEmoticonsAtIndex:(NSUInteger)theIndex withObject:(id)obj;
@end

@implementation WLEmoticonsPanelController
@synthesize emoticons = _emoticons;

SYNTHESIZE_SINGLETON_FOR_CLASS(WLEmoticonsPanelController);

- (instancetype)init {
    if (self = [super init]) {
		@synchronized(self) {
			if (!_emoticons)
				_emoticons = [[NSMutableArray alloc] init];
			[self loadNibFile];
		}
    }
    return self;
}

- (void)dealloc {
    [_emoticons release];
    [super dealloc];
}

- (void)loadNibFile {
	if (_emoticonsPanel) {
		// Already loaded, return quietly
		return;
	}
	
	// Load Nib file and load all emoticons in
    if ([[NSBundle mainBundle] loadNibNamed:kEmoticonPanelNibFilename owner:self topLevelObjects:nil]) {
        [self loadEmoticons];
    }
}

#pragma mark -
#pragma mark IBActions
- (void)openEmoticonsPanel {
	// Load Nib file if necessary
	[self loadNibFile];
    [_emoticonsPanel makeKeyAndOrderFront:self];
}

- (IBAction)closeEmoticonsPanel:(id)sender {
    [_emoticonsPanel endEditingFor:nil];
    [_emoticonsPanel makeFirstResponder:_emoticonsPanel];
    [_emoticonsPanel orderOut:self];
    [self saveEmoticons];
}

- (IBAction)inputSelectedEmoticon:(id)sender {
    [self closeEmoticonsPanel:sender];
	if ([NSApp.keyWindow.firstResponder conformsToProtocol:@protocol(NSTextInputClient)]) {
		id <NSTextInputClient> textInput = (id <NSTextInputClient>)NSApp.keyWindow.firstResponder;
		NSArray *a = _emoticonsController.selectedObjects;
		
		if (a.count == 1) {
			YLEmoticon *e = a[0];
			[textInput insertText:e.content replacementRange:NSMakeRange(0, 0)];
		}		
	}
}

#pragma mark -
#pragma mark Save/Load Emoticons
- (void)loadEmoticons {
    NSArray *a = [[NSUserDefaults standardUserDefaults] arrayForKey:@"Emoticons"];
    for (NSDictionary *d in a)
        [self addEmoticon:[YLEmoticon emoticonWithDictionary:d]];
}

- (void)saveEmoticons {
    NSMutableArray *a = [NSMutableArray array];
    for (YLEmoticon *e in _emoticons) 
        [a addObject:[e dictionaryOfEmoticon]];
    [[NSUserDefaults standardUserDefaults] setObject:a forKey:@"Emoticons"];    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Emoticons Accessors
- (NSUInteger)countOfEmoticons {
    return _emoticons.count;
}

- (id)objectInEmoticonsAtIndex:(NSUInteger)theIndex {
    return _emoticons[theIndex];
}

- (void)getEmoticons:(id *)objsPtr 
			   range:(NSRange)range {
    [_emoticons getObjects:objsPtr range:range];
}

- (void)insertObject:(id)obj 
  inEmoticonsAtIndex:(NSUInteger)theIndex {
    [_emoticons insertObject:obj atIndex:theIndex];
}

- (void)removeObjectFromEmoticonsAtIndex:(NSUInteger)theIndex {
    [_emoticons removeObjectAtIndex:theIndex];
}

- (void)replaceObjectInEmoticonsAtIndex:(NSUInteger)theIndex withObject:(id)obj {
    _emoticons[theIndex] = obj;
}

- (void)addEmoticon:(YLEmoticon *)emoticon {
	[self insertObject:emoticon inEmoticonsAtIndex:self.countOfEmoticons];
}

- (void)addEmoticonFromString:(NSString *)string {
	YLEmoticon *emoticon = [YLEmoticon emoticonWithString:string];
	[self addEmoticon:emoticon];
}

@end

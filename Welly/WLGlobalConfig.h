//
//  WLGlobalConfig.h
//  Welly
//
//  YLLGlobalConfig.h
//  MacBlueTelnet
//
//  Created by Yung-Luen Lan on 2006/11/12.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"
#import "WLEncoder.h"

#define NUM_COLOR 10

NSString *const WLRestoreConnectionKeyName;
NSString *const WLCommandRHotkeyEnabledKeyName;
NSString *const WLConfirmOnCloseEnabledKeyName;
NSString *const WLSafePasteEnabledKeyName;
NSString *const WLCoverFlowModeEnabledKeyName;

NSString *const WLCellWidthKeyName;
NSString *const WLCellHeightKeyName;
NSString *const WLChineseFontSizeKeyName;
NSString *const WLEnglishFontSizeKeyName;

@interface WLGlobalConfig : NSObject {
@public
    NSColor *_colorTable[2][NUM_COLOR];
    
    CFDictionaryRef _cCTAttribute[2][NUM_COLOR];
    CFDictionaryRef _eCTAttribute[2][NUM_COLOR];
}

@property (readwrite, assign) NSInteger messageCount;
@property (readwrite, assign) NSInteger row;
@property (readwrite, assign) NSInteger column;
@property (readwrite, assign) CGFloat cellWidth;
@property (readwrite, assign) CGFloat cellHeight;
@property (readwrite, assign, nonatomic) BOOL showsHiddenText;
@property (readwrite, assign, nonatomic) BOOL shouldSmoothFonts;
@property (readwrite, assign, nonatomic) BOOL shouldDetectDoubleByte;
@property (readwrite, assign, nonatomic) BOOL shouldEnableMouse;
@property (readwrite, assign, nonatomic) BOOL shouldRepeatBounce;
@property (readwrite, assign, nonatomic) WLEncoding defaultEncoding;
@property (readwrite, assign, nonatomic) YLANSIColorKey defaultANSIColorKey;
@property (readwrite, assign) BOOL blinkTicker;
@property (readwrite, assign, nonatomic) CGFloat chineseFontSize;
@property (readwrite, assign, nonatomic) CGFloat englishFontSize;
@property (readwrite, assign, nonatomic) CGFloat chineseFontPaddingLeft;
@property (readwrite, assign, nonatomic) CGFloat englishFontPaddingLeft;
@property (readwrite, assign, nonatomic) CGFloat chineseFontPaddingBottom;
@property (readwrite, assign, nonatomic) CGFloat englishFontPaddingBottom;
@property (readwrite, copy, nonatomic) NSString *chineseFontName;
@property (readwrite, copy, nonatomic) NSString *englishFontName;

@property (readonly, nonatomic) int bgColorIndex;
@property (readonly, nonatomic) int fgColorIndex;
@property (readonly, nonatomic) CTFontRef cCTFont;
@property (readonly, nonatomic) CTFontRef eCTFont;
@property (readonly, nonatomic) CGFontRef cCGFont;
@property (readonly, nonatomic) CGFontRef eCGFont;

+ (WLGlobalConfig *)sharedInstance;

- (void)refreshFont;

- (NSColor *)colorAtIndex:(int)i 
				   hilite:(BOOL)h;
- (NSColor *)bgColorAtIndex:(int)i 
					 hilite:(BOOL)h;
- (void)setColor:(NSColor *)c 
		  hilite:(BOOL)h 
		 atIndex:(int)i;

- (void)updateBlinkTicker;

@property (NS_NONATOMIC_IOSONLY, readonly) NSSize contentSize;

/* Set font size */
- (void)setFontSizeRatio:(CGFloat)ratio;

/* Color */
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorBlack;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorBlackHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorRed;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorRedHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorGreen;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorGreenHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorYellow;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorYellowHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorBlue;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorBlueHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorMagenta;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorMagentaHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorCyan;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorCyanHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorWhite;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorWhiteHilite;

@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorBG;
@property (NS_NONATOMIC_IOSONLY, copy) NSColor *colorBGHilite;

+ (void)initializeCache;
+ (NSString *)cacheDirectory;

+ (BOOL)shouldEnableCoverFlow;

- (void)restoreSettings;
@property (NS_NONATOMIC_IOSONLY, copy) NSDictionary *sizeParameters;
@end

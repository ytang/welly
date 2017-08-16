//
//  WLGlobalConfig.h
//  Welly
//
//  YLLGlobalConfig.m
//  MacBlueTelnet
//
//  Created by Yung-Luen Lan on 2006/11/12.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import "WLGlobalConfig.h"
#import "SynthesizeSingleton.h"

#pragma mark -
#pragma mark Constants
NSString *const WLRestoreConnectionKeyName = @"RestoreConnection";
NSString *const WLCommandRHotkeyEnabledKeyName = @"CommandRHotkey";
NSString *const WLConfirmOnCloseEnabledKeyName = @"ConfirmOnClose";
NSString *const WLSafePasteEnabledKeyName = @"SafePaste";
NSString *const WLCoverFlowModeEnabledKeyName = @"Portal";

const CGFloat WLDefaultCellWidth = 12;
const CGFloat WLDefaultCellHeight = 24;
const CGFloat WLDefaultChineseFontSize = 22;
const CGFloat WLDefaultEnglishFontSize = 18;
NSString *const WLDefaultChineseFontName = @"STHeiti";
NSString *const WLDefaultEnglishFontName = @"Monaco";

NSString *const WLCellWidthKeyName = @"CellWidth";
NSString *const WLCellHeightKeyName = @"CellHeight";
NSString *const WLChineseFontSizeKeyName = @"ChineseFontSize";
NSString *const WLEnglishFontSizeKeyName = @"EnglishFontSize";

#pragma mark -
#pragma mark Class Define

@interface NSUserDefaults(myColorSupport)
- (void)setMyColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)myColorForKey:(NSString *)aKey;
@end

@implementation NSUserDefaults(myColorSupport)
- (void)setMyColor:(NSColor *)aColor 
			forKey:(NSString *)aKey {
    NSData *theData=[NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)myColorForKey:(NSString *)aKey {
    NSColor *theColor=nil;
    NSData *theData=[self dataForKey:aKey];
    if (theData != nil)
        theColor=(NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}
@end

@implementation WLGlobalConfig
@synthesize messageCount = _messageCount;
@synthesize row = _row;
@synthesize column = _column;
@synthesize cellWidth = _cellWidth;
@synthesize cellHeight = _cellHeight;
@synthesize showsHiddenText = _showsHiddenText;
@synthesize shouldSmoothFonts = _shouldSmoothFonts;
@synthesize shouldDetectDoubleByte = _shouldDetectDoubleByte;
@synthesize shouldEnableMouse = _shouldEnableMouse;
@synthesize shouldRepeatBounce = _shouldRepeatBounce;
@synthesize defaultEncoding = _defaultEncoding;
@synthesize defaultANSIColorKey = _defaultANSIColorKey;
@synthesize blinkTicker = _blinkTicker;
@synthesize chineseFontSize = _chineseFontSize;
@synthesize englishFontSize = _englishFontSize;
@synthesize chineseFontPaddingLeft = _chineseFontPaddingLeft;
@synthesize englishFontPaddingLeft = _englishFontPaddingLeft;
@synthesize chineseFontPaddingBottom = _chineseFontPaddingBottom;
@synthesize englishFontPaddingBottom = _englishFontPaddingBottom;
@synthesize chineseFontName = _chineseFontName;
@synthesize englishFontName = _englishFontName;

SYNTHESIZE_SINGLETON_FOR_CLASS(WLGlobalConfig);

- (instancetype)init {
	self = [super init];
	if (self) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		self.showsHiddenText = [defaults boolForKey:@"ShowHiddenText"];
		self.shouldSmoothFonts = [defaults boolForKey:@"ShouldSmoothFonts"];
		self.shouldDetectDoubleByte = [defaults boolForKey:@"DetectDoubleByte"];
		self.shouldEnableMouse = [defaults boolForKey:@"EnableMouse"];
		self.defaultEncoding = (WLEncoding) [defaults integerForKey:@"DefaultEncoding"];
		self.defaultANSIColorKey = (YLANSIColorKey) [defaults integerForKey:@"DefaultANSIColorKey"];
		self.shouldRepeatBounce = [defaults boolForKey:@"RepeatBounce"];
		
		// init code
		_row = 24;
		_column = 80;
		self.cellWidth = [defaults floatForKey:@"CellWidth"];
		self.cellHeight = [defaults floatForKey:@"CellHeight"];
		
		self.chineseFontName = [defaults stringForKey:@"ChineseFontName"];
		self.englishFontName = [defaults stringForKey:@"EnglishFontName"];
		self.chineseFontSize = [defaults floatForKey:@"ChineseFontSize"];
		self.englishFontSize = [defaults floatForKey:@"EnglishFontSize"];
		
		// If it is too small, we shall restore settings
		if (self.cellWidth < 4 || self.cellHeight < 4 || self.chineseFontSize < 6 || self.englishFontSize < 4) {
			[self restoreSettings];
		}
		
		// Too large, restore it
		if (self.contentSize.width > [NSScreen mainScreen].frame.size.width ||
			self.contentSize.height > [NSScreen mainScreen].frame.size.height) {
			[self restoreSettings];
		}
        
		if ([defaults objectForKey:@"ChinesePaddingLeft"])
			self.chineseFontPaddingLeft = [defaults floatForKey:@"ChinesePaddingLeft"];
		else
			self.chineseFontPaddingLeft = 1.0;
		
		if ([defaults objectForKey:@"EnglishPaddingLeft"])
			self.englishFontPaddingLeft = [defaults floatForKey:@"EnglishPaddingLeft"];
		else
			self.englishFontPaddingLeft = 1.0;
        
		if ([defaults objectForKey:@"ChinesePaddingBottom"])
			self.chineseFontPaddingBottom = [defaults floatForKey:@"ChinesePaddingBottom"];
		else
			self.chineseFontPaddingBottom = 1.0;
        
		if ([defaults objectForKey:@"EnglishPaddingBottom"])
			self.englishFontPaddingBottom = [defaults floatForKey:@"EnglishPaddingBottom"];
		else
			self.englishFontPaddingBottom = 2.0;
        
		self.colorBlack = [defaults myColorForKey:@"ColorBlack"];
		self.colorBlackHilite = [defaults myColorForKey:@"ColorBlackHilite"];
		self.colorRed = [defaults myColorForKey:@"ColorRed"];
		self.colorRedHilite = [defaults myColorForKey:@"ColorRedHilite"];
		self.colorBlack = [defaults myColorForKey:@"ColorBlack"];
		self.colorBlackHilite = [defaults myColorForKey:@"ColorBlackHilite"];
		self.colorGreen = [defaults myColorForKey:@"ColorGreen"];
		self.colorGreenHilite = [defaults myColorForKey:@"ColorGreenHilite"];
		self.colorYellow = [defaults myColorForKey:@"ColorYellow"];
		self.colorYellowHilite = [defaults myColorForKey:@"ColorYellowHilite"];
		self.colorBlue = [defaults myColorForKey:@"ColorBlue"];
		self.colorBlueHilite = [defaults myColorForKey:@"ColorBlueHilite"];
		self.colorMagenta = [defaults myColorForKey:@"ColorMagenta"];
		self.colorMagentaHilite = [defaults myColorForKey:@"ColorMagentaHilite"];
		self.colorCyan = [defaults myColorForKey:@"ColorCyan"];
		self.colorCyanHilite = [defaults myColorForKey:@"ColorCyanHilite"];
		self.colorWhite = [defaults myColorForKey:@"ColorWhite"];
		self.colorWhiteHilite = [defaults myColorForKey:@"ColorWhiteHilite"]; // Foreground Color
		self.colorBG = [defaults myColorForKey:@"ColorBG"];
		self.colorBGHilite = [defaults myColorForKey:@"ColorBGHilite"];
		//_colorTable[0][8] = [[NSColor colorWithDeviceRed:0.75 green:0.75 blue:0.75 alpha:1.0] retain];
		//_colorTable[1][8] = [[NSColor colorWithDeviceRed:1.00 green:1.00 blue:1.00 alpha:1.0] retain];
		_colorTable[0][8] = [NSColor colorWithDeviceRed:0.75 green:0.75 blue:0.75 alpha:1.0];
		_colorTable[1][8] = [NSColor colorWithDeviceRed:1.00 green:1.00 blue:1.00 alpha:1.0];
		
		
		_bgColorIndex = 9;
		_fgColorIndex = 7;
		
		[defaults synchronize];
		[self refreshFont];
        
		// aqua: why not enable these settings by default?
		if ([defaults objectForKey:WLRestoreConnectionKeyName] == nil)
			[defaults setBool:YES forKey:WLRestoreConnectionKeyName];
		if ([defaults objectForKey:WLCommandRHotkeyEnabledKeyName] == nil)
			[defaults setBool:YES forKey:WLCommandRHotkeyEnabledKeyName];
		if ([defaults objectForKey:WLConfirmOnCloseEnabledKeyName] == nil)
			[defaults setBool:YES forKey:WLConfirmOnCloseEnabledKeyName];
		if ([defaults objectForKey:WLSafePasteEnabledKeyName] == nil)
			[defaults setBool:YES forKey:WLSafePasteEnabledKeyName];
		if ([defaults objectForKey:WLCoverFlowModeEnabledKeyName] == nil)
			[defaults setBool:YES forKey:WLCoverFlowModeEnabledKeyName];
		
		// Initialize Cache
		[WLGlobalConfig initializeCache];
	}
    return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)setFontSizeRatio:(CGFloat)ratio {
	self.englishFontSize = _englishFontSize * ratio;
	self.chineseFontSize = _chineseFontSize * ratio;
	self.cellWidth = _cellWidth * ratio;
	self.cellHeight = _cellHeight * ratio;
}

- (void)refreshFont {
    int i, j;
    
    if (_cCTFont) 
		CFRelease(_cCTFont);
    _cCTFont = CTFontCreateWithName((CFStringRef)_chineseFontName, _chineseFontSize, NULL);
    if (_eCTFont)
		CFRelease(_eCTFont);
    _eCTFont = CTFontCreateWithName((CFStringRef)_englishFontName, _englishFontSize, NULL);
    if (_cCGFont)
		CFRelease(_cCGFont);
    _cCGFont = CTFontCopyGraphicsFont(_cCTFont, NULL);
    if (_eCGFont)
		CFRelease(_eCGFont);
    _eCGFont = CTFontCopyGraphicsFont(_eCTFont, NULL);
    
    for (i = 0; i < NUM_COLOR; i++) 
        for (j = 0; j < 2; j++) {
            int zero = 0;
            CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &zero);
            CFStringRef cfKeys[] = {kCTFontAttributeName, kCTForegroundColorAttributeName, kCTLigatureAttributeName};
            
            CFTypeRef cfValues[] = {_cCTFont, _colorTable[j][i], number};
            if (_cCTAttribute[j][i])CFRelease(_cCTAttribute[j][i]);
            _cCTAttribute[j][i] = CFDictionaryCreate(kCFAllocatorDefault, 
                                                     (const void **)cfKeys, 
                                                     (const void **)cfValues, 
                                                     3, 
                                                     &kCFTypeDictionaryKeyCallBacks, 
                                                     &kCFTypeDictionaryValueCallBacks);

            cfValues[0] = _eCTFont;
            if (_eCTAttribute[j][i])CFRelease(_eCTAttribute[j][i]);
            _eCTAttribute[j][i] = CFDictionaryCreate(kCFAllocatorDefault, 
                                                     (const void **)cfKeys, 
                                                     (const void **)cfValues, 
                                                     3, 
                                                     &kCFTypeDictionaryKeyCallBacks, 
                                                     &kCFTypeDictionaryValueCallBacks);
            CFRelease(number);
        }
    
}

#pragma mark -
#pragma mark Accessor
- (CGFloat)cellWidth {
	return (CGFloat)((int)(_cellWidth + 0.5));
}

- (void)setCellWidth:(CGFloat)value {
    if (value == 0) 
		value = WLDefaultCellWidth;
    _cellWidth = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"CellWidth"];
}

- (CGFloat)cellHeight {
	return (CGFloat)((int)(_cellHeight + 0.5));
}


- (void)setCellHeight:(CGFloat)value {
    if (value == 0) 
		value = WLDefaultCellHeight;
    _cellHeight = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"CellHeight"];
}

- (NSColor *)colorAtIndex:(int)i 
				   hilite:(BOOL)h {
	if (i >= 0 && i < NUM_COLOR) 
		return _colorTable[h][i];
	return _colorTable[0][NUM_COLOR - 1];
}

- (NSColor *)bgColorAtIndex:(int)i 
					 hilite:(BOOL)h {
	return [[self colorAtIndex:i hilite:h] colorWithAlphaComponent:self.colorBG.alphaComponent];
}

- (void)setColor:(NSColor *)c 
		  hilite:(BOOL)h 
		 atIndex:(int)i {
	if (i >= 0 && i < NUM_COLOR) {
		[_colorTable[h][i] autorelease];
		_colorTable[h][i] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
	}
}

- (void)setShowsHiddenText:(BOOL)value {
    _showsHiddenText = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"ShowHiddenText"];
}

- (void)setShouldSmoothFonts:(BOOL)value {
    _shouldSmoothFonts = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"ShouldSmoothFonts"];
}

- (void)setShouldRepeatBounce:(BOOL)value {
    _shouldRepeatBounce = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"RepeatBounce"];
}

- (void)setShouldDetectDoubleByte:(BOOL)value {
    _shouldDetectDoubleByte = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"DetectDoubleByte"];
}

- (void)setShouldEnableMouse:(BOOL)value {
    _shouldEnableMouse = value;
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"EnableMouse"];
}

- (void)setDefaultEncoding:(WLEncoding)value {
    _defaultEncoding = value;
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)value forKey:@"DefaultEncoding"];
}

- (void)setDefaultANSIColorKey:(YLANSIColorKey)value {
    _defaultANSIColorKey = value;
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)value forKey:@"DefaultANSIColorKey"];
}

- (void)updateBlinkTicker {
    self.blinkTicker = !_blinkTicker;
}

- (CGFloat)chineseFontSize {
	return (CGFloat)((int)(_chineseFontSize + 0.5));
}

- (void)setChineseFontSize:(CGFloat)value {
    if (value == 0) 
		value = WLDefaultChineseFontSize;
    _chineseFontSize = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"ChineseFontSize"];
}

- (CGFloat)englishFontSize {
	return (CGFloat)((int)(_englishFontSize + 0.5));
}

- (void)setEnglishFontSize:(CGFloat)value {
    if (value == 0) 
		value = WLDefaultEnglishFontSize;
    _englishFontSize = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"EnglishFontSize"];
}

- (void)setChineseFontPaddingLeft:(CGFloat)value {
    _chineseFontPaddingLeft = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"ChinesePaddingLeft"];
}

- (void)setEnglishFontPaddingLeft:(CGFloat)value {
    _englishFontPaddingLeft = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"EnglishPaddingLeft"];
}

- (void)setChineseFontPaddingBottom:(CGFloat)value {
    _chineseFontPaddingBottom = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"ChinesePaddingBottom"];
}

- (void)setEnglishFontPaddingBottom:(CGFloat)value {
    _englishFontPaddingBottom = value;
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"EnglishPaddingBottom"];
}

//- (NSString *)chineseFontName { return [[_chineseFontName copy] autorelease]; }
- (void)setChineseFontName:(NSString *)value {
    if (!value) value = WLDefaultChineseFontName;
    if (_chineseFontName != value) {
        [_chineseFontName release];
        _chineseFontName = [value copy];
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"ChineseFontName"];
    }
}

//- (NSString *)englishFontName { return [[_englishFontName copy] autorelease]; }
- (void)setEnglishFontName:(NSString *)value {
    if (!value) value = WLDefaultEnglishFontName;
    if (_englishFontName != value) {
        [_englishFontName release];
        _englishFontName = [value copy];
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"EnglishFontName"];
    }
}

#pragma mark -
#pragma mark Colors
- (NSColor *)colorBlack { return _colorTable[0][0]; }
- (void)setColorBlack:(NSColor *)c {
    if (!c)
		c = [NSColor colorWithDeviceRed:0.00 green:0.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[0][0]) {
        [_colorTable[0][0] release];
        _colorTable[0][0] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorBlack"];
}
- (NSColor *)colorBlackHilite { return _colorTable[1][0]; }
- (void)setColorBlackHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.25 green:0.25 blue:0.25 alpha:1.0];
    if (c != _colorTable[1][0]) {
        [_colorTable[1][0] release];
        _colorTable[1][0] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorBlackHilite"];
}

- (NSColor *)colorRed { return _colorTable[0][1]; }
- (void)setColorRed:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.50 green:0.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[0][1]) {
        [_colorTable[0][1] release];
        _colorTable[0][1] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorRed"];
}
- (NSColor *)colorRedHilite { return _colorTable[1][1]; }
- (void)setColorRedHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:1.00 green:0.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[1][1]) {
        [_colorTable[1][1] release];
        _colorTable[1][1] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorRedHilite"];
}

- (NSColor *)colorGreen { return _colorTable[0][2]; }
- (void)setColorGreen:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:0.50 blue:0.00 alpha:1.0];
    if (c != _colorTable[0][2]) {
        [_colorTable[0][2] release];
        _colorTable[0][2] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorGreen"];
}
- (NSColor *)colorGreenHilite { return _colorTable[1][2]; }
- (void)setColorGreenHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:1.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[1][2]) {
        [_colorTable[1][2] release];
        _colorTable[1][2] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorGreenHilite"];
}

- (NSColor *)colorYellow { return _colorTable[0][3]; }
- (void)setColorYellow:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.50 green:0.50 blue:0.00 alpha:1.0];
    if (c != _colorTable[0][3]) {
        [_colorTable[0][3] release];
        _colorTable[0][3] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorYellow"];
}
- (NSColor *)colorYellowHilite { return _colorTable[1][3]; }
- (void)setColorYellowHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:1.00 green:1.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[1][3]) {
        [_colorTable[1][3] release];
        _colorTable[1][3] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorYellowHilite"];
}

- (NSColor *)colorBlue { return _colorTable[0][4]; }
- (void)setColorBlue:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:0.00 blue:0.50 alpha:1.0];
    if (c != _colorTable[0][4]) {
        [_colorTable[0][4] release];
        _colorTable[0][4] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorBlue"];
}
- (NSColor *)colorBlueHilite { return _colorTable[1][4]; }
- (void)setColorBlueHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:0.00 blue:1.00 alpha:1.0];
    if (c != _colorTable[1][4]) {
        [_colorTable[1][4] release];
        _colorTable[1][4] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorBlueHilite"];
}

- (NSColor *)colorMagenta { return _colorTable[0][5]; }
- (void)setColorMagenta:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.50 green:0.00 blue:0.50 alpha:1.0];
    if (c != _colorTable[0][5]) {
        [_colorTable[0][5] release];
        _colorTable[0][5] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorMagenta"];
}
- (NSColor *)colorMagentaHilite { return _colorTable[1][5]; }
- (void)setColorMagentaHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:1.00 green:0.00 blue:1.00 alpha:1.0];
    if (c != _colorTable[1][5]) {
        [_colorTable[1][5] release];
        _colorTable[1][5] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorMagentaHilite"];
}

- (NSColor *)colorCyan { return _colorTable[0][6]; }
- (void)setColorCyan:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:0.50 blue:0.50 alpha:1.0];
    if (c != _colorTable[0][6]) {
        [_colorTable[0][6] release];
        _colorTable[0][6] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorCyan"];
}
- (NSColor *)colorCyanHilite { return _colorTable[1][6]; }
- (void)setColorCyanHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:1.00 blue:1.00 alpha:1.0];
    if (c != _colorTable[1][6]) {
        [_colorTable[1][6] release];
        _colorTable[1][6] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorCyanHilite"];
}

- (NSColor *)colorWhite { return _colorTable[0][7]; }
- (void)setColorWhite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.50 green:0.50 blue:0.50 alpha:1.0];
    if (c != _colorTable[0][7]) {
        [_colorTable[0][7] release];
        _colorTable[0][7] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorWhite"];
}
- (NSColor *)colorWhiteHilite { return _colorTable[1][7]; }
- (void)setColorWhiteHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:1.00 green:1.00 blue:1.00 alpha:1.0];
    if (c != _colorTable[1][7]) {
        [_colorTable[1][7] release];
        _colorTable[1][7] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorWhiteHilite"];
}

- (NSColor *)colorBG { return _colorTable[0][9]; }
- (void)setColorBG:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:0.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[0][9]) {
        [_colorTable[0][9] release];
        _colorTable[0][9] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
//        if ([self colorBGHilite] != c) [self setColorBGHilite: c];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorBG"];
}

- (NSColor *)colorBGHilite { return _colorTable[1][9]; }
- (void)setColorBGHilite:(NSColor *)c {
    if (!c)c = [NSColor colorWithDeviceRed:0.00 green:0.00 blue:0.00 alpha:1.0];
    if (c != _colorTable[1][9]) {
        [_colorTable[1][9] release];
        _colorTable[1][9] = [[c colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];
//        if ([self colorBG] != c) [self setColorBG: c];
    }
    [[NSUserDefaults standardUserDefaults] setMyColor:c forKey:@"ColorBGHilite"];
}

+ (NSString *)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSAssert([paths count] > 0, @"~/Library/Caches");
    NSString *cacheDir = [paths[0] stringByAppendingPathComponent:@"Welly"];
    return cacheDir;
}

+ (void)initializeCache {
    // clean cache at startup
    NSString *cacheDir = [WLGlobalConfig cacheDirectory];
    BOOL flag = NO;
    int pid = [NSProcessInfo processInfo].processIdentifier;
    // detect if another Welly exists
    for (NSDictionary *dict in [NSWorkspace sharedWorkspace].runningApplications) {
        if ([[dict valueForKey:@"localizedName"] isEqualToString:@"Welly"] &&
            [[dict valueForKey:@"processIdentifier"] intValue] != pid) {
            flag = YES;
            break;
        }
    }
    // no other Welly
    if (!flag)
        [[NSFileManager defaultManager] removeItemAtPath:cacheDir error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:NULL];
}

#pragma mark -
#pragma mark Query Global Config
+ (BOOL)shouldEnableCoverFlow {
	return [[NSUserDefaults standardUserDefaults] boolForKey:WLCoverFlowModeEnabledKeyName];
}

- (NSSize)contentSize {
	// Return the proper size of all the content
	return NSMakeSize(_column * self.cellWidth, _row * self.cellHeight);
}

#pragma mark -
#pragma mark Restoring Settrings
- (void)restoreSettings {
	self.cellWidth = 12;
	self.cellHeight = 24;
	self.chineseFontName = @"STHeiti";
	self.englishFontName = @"Monaco";
	self.chineseFontSize = 22;
	self.englishFontSize = 18;
}

- (NSDictionary *)sizeParameters {
	return @{WLCellWidthKeyName:@(_cellWidth), WLCellHeightKeyName:@(_cellHeight), WLChineseFontSizeKeyName:@(_chineseFontSize), WLEnglishFontSizeKeyName:@(_englishFontSize)};
}

- (void)setSizeParameters:(NSDictionary *)sizeParameters {
	if (sizeParameters[WLCellWidthKeyName])
		self.cellWidth = [sizeParameters[WLCellWidthKeyName] floatValue];
	if (sizeParameters[WLCellHeightKeyName])
		self.cellHeight = [sizeParameters[WLCellHeightKeyName] floatValue];
	if (sizeParameters[WLChineseFontSizeKeyName])
		self.chineseFontSize = [sizeParameters[WLChineseFontSizeKeyName] floatValue];
	if (sizeParameters[WLEnglishFontSizeKeyName])
		self.englishFontSize = [sizeParameters[WLEnglishFontSizeKeyName] floatValue];
}
@end

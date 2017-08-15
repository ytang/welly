//
//  WLTerminal.h
//  Welly
//
//  YLTerminal.h
//  MacBlueTelnet
//
//  Created by Yung-Luen Lan on 2006/9/10.
//  Copyright 2006 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"

@class WLConnection, WLMessageDelegate, WLIntegerArray;
@class WLTerminal;

@protocol WLTerminalObserver

- (void)terminalDidUpdate:(WLTerminal *)terminal;

@end

@interface WLTerminal : NSObject {	
	WLBBSType _bbsType;
	
    NSInteger _maxRow;
    NSInteger _maxColumn;
    NSInteger _cursorColumn;
    NSInteger _cursorRow;
    NSInteger _offset;
	
    cell **_grid;
    BOOL **_dirty;

	NSMutableSet *_observers;

    WLConnection *_connection;
	
	BBSState _bbsState;
	
	unichar *_textBuf;
}
@property NSInteger maxRow;
@property NSInteger maxColumn;
@property NSInteger cursorColumn;
@property NSInteger cursorRow;
@property cell **grid;
@property (assign, setter=setConnection:, nonatomic) WLConnection *connection;
@property (assign, readwrite) WLBBSType bbsType;
@property (readonly) BBSState bbsState;

/* Clear */
- (void)clearAll;

/* Dirty */
- (BOOL)isDirtyAtRow:(NSInteger)r
			  column:(NSInteger)c;
- (void)setAllDirty;
- (void)setDirty:(BOOL)d 
		   atRow:(NSInteger)r
		  column:(NSInteger)c;
- (void)setDirtyForRow:(NSInteger)r;
- (void)removeAllDirtyMarks;

/* Access Data */
- (attribute)attrAtRow:(NSInteger)r
				column:(NSInteger)c ;
- (NSString *)stringAtIndex:(NSInteger)begin
					 length:(NSInteger)length;
- (NSAttributedString *)attributedStringAtIndex:(NSInteger)location
										 length:(NSInteger)length;
- (cell *)cellsOfRow:(NSInteger)r;
- (cell)cellAtIndex:(NSInteger)index;

/* Update State */
- (void)updateDoubleByteStateForRow:(NSInteger)r;
- (void)updateBBSState;

/* Accessor */
- (WLEncoding)encoding;
- (void)setEncoding:(WLEncoding)encoding;

/* Input Interface */
- (void)feedGrid:(cell **)grid;
- (void)setCursorX:(NSInteger)cursorX
				 Y:(NSInteger)cursorY;

/* Observer Interface */
- (void)addObserver:(id <WLTerminalObserver>)observer;
@end

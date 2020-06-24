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

@interface WLTerminal : NSObject

@property (assign, nonatomic) NSInteger maxRow;
@property (assign, nonatomic) NSInteger maxColumn;
@property (assign, nonatomic) NSInteger cursorColumn;
@property (assign, nonatomic) NSInteger cursorRow;
@property (readonly, nonatomic) cell **grid;
@property (weak, nonatomic) WLConnection *connection;
@property (assign, nonatomic) WLBBSType bbsType;
@property (readonly, nonatomic) BBSState bbsState;

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
- (cell *)cellsOfRow:(NSInteger)r NS_RETURNS_INNER_POINTER;
- (cell)cellAtIndex:(NSInteger)index;

/* Update State */
- (void)updateDoubleByteStateForRow:(NSInteger)r;
- (void)updateBBSState;

/* Accessor */
@property (assign, nonatomic) WLEncoding encoding;

/* Input Interface */
- (void)feedGrid:(cell **)grid;
- (void)setCursorX:(NSInteger)cursorX
                 Y:(NSInteger)cursorY;

/* Observer Interface */
- (void)addObserver:(id <WLTerminalObserver>)observer;
@end

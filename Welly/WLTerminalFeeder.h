//
//  WLTerminalFeeder.h
//  Welly
//
//  Created by K.O.ed on 08-8-11.
//  Copyright 2008 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"

@class WLIntegerArray, WLTerminal;

@interface WLTerminalFeeder : NSObject {
    NSInteger  _row;
    NSInteger _column;
    NSInteger _cursorX;
    NSInteger _cursorY;
    NSInteger _offset;
    
    NSInteger _savedCursorX;
    NSInteger _savedCursorY;
    
    NSInteger _fgColor;
    NSInteger _bgColor;
    BOOL _bold;
    BOOL _underline;
    BOOL _blink;
    BOOL _reverse;
    
    cell **_grid;
    
    enum { TP_NORMAL, TP_ESCAPE, TP_CONTROL, TP_SCS } _state;
    
    WLIntegerArray *_csBuf;
    WLIntegerArray *_csArg;
    NSInteger _csTemp;
    
    NSInteger _scrollBeginRow;
    NSInteger _scrollEndRow;
    
    WLTerminal *_terminal;
    
    BOOL _hasNewMessage;	// to determine if a user notification is needed
    
    enum { VT100, VT102 } _emustd;
    
    BOOL _modeScreenReverse;  // reverse (true), not reverse (false, default)
    BOOL _modeOriginRelative; // relative origin (true), absolute origin (false, default)
    BOOL _modeWraptext;       // autowrap (true, default), wrap disabled (false)
    BOOL _modeLNM;            // line feed (true, default), new line (false)
    BOOL _modeIRM;            // insert (true), replace (false, default)
}
@property NSInteger cursorX;
@property NSInteger cursorY;
@property cell **grid;

- (instancetype)init;
- (void)dealloc;

/* Input Interface */
- (void)feedData:(NSData *)data connection:(id)connection;
- (void)feedBytes:(const unsigned char*)bytes 
           length:(NSUInteger)len 
       connection:(id)connection;

- (void)setTerminal:(WLTerminal *)terminal;

/* Clear */
- (void)clearAll;

- (cell *)cellsOfRow:(NSInteger)r NS_RETURNS_INNER_POINTER;
@end

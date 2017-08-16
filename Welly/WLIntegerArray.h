//
//  XIIntegerArray.h
//  Welly
//
//  Created by boost @ 9# on 7/28/08.
//  Copyright 2008 Xi Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// simulate std::deque for legacy code
@interface WLIntegerArray : NSObject {
    NSPointerArray *_array;
}

+ (instancetype) integerArray;

- (void)push_back:(NSInteger)integer;
- (void)pop_front;
- (NSInteger)at:(NSUInteger)index;
- (void)set:(NSInteger)value at:(NSUInteger)index;
@property (NS_NONATOMIC_IOSONLY, readonly) NSInteger front;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL empty;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger size;
- (void)clear;

@end

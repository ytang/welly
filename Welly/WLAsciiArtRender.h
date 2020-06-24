//
//  WLAsciiArtRender.h
//  Welly
//
//  Created by K.O.ed on 10-6-25.
//  Copyright 2010 Welly Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"

@interface WLAsciiArtRender : NSObject

+ (BOOL)isAsciiArtSymbol:(unichar)ch;

- (void)drawSpecialSymbol:(unichar)ch 
                   forRow:(NSInteger)r
                   column:(NSInteger)c 
            leftAttribute:(attribute)attr1 
           rightAttribute:(attribute)attr2;

- (void)configure;

@end

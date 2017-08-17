//
//  WLEncoder.h
//  Welly
//
//  Created by boost on 9/26/09.
//  Copyright 2009 Welly Group. All rights reserved.
//

/*
 *  encoding.h
 *  MacBlueTelnet
 *
 *  Created by Yung-Luen Lan on 9/11/07.
 *  Copyright 2007 yllan.org. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, WLEncoding) {
    WLGBKEncoding = 0,
    WLBig5Encoding = 1,
};

@interface WLEncoder : NSObject

+ (unichar)fromUnicode:(unichar)c encoding:(WLEncoding)encoding;
+ (unichar)toUnicode:(unichar)c encoding:(WLEncoding)encoding;

@end

//
//  WLSite.h
//  Welly
//
//  YLSite.h
//  MacBlueTelnet
//
//  Created by Lan Yung-Luen on 11/20/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommonType.h"

@interface WLSite : NSObject

@property (readwrite, copy) NSString *name;
@property (readwrite, copy) NSString *address;
@property (readwrite, assign) WLEncoding encoding;
@property (readwrite, assign) YLANSIColorKey ansiColorKey;
@property (readwrite, assign) BOOL shouldDetectDoubleByte;
@property (readwrite, assign) BOOL shouldAutoReply;
@property (readwrite, copy) NSString *autoReplyString;
@property (readwrite, assign) BOOL shouldEnableMouse;
@property (readwrite, assign) WLProxyType proxyType;
@property (readwrite, copy) NSString *proxyAddress;

+ (WLSite *)site;
+ (WLSite *)siteWithName:(NSString *)name address:(NSString *)address encoding:(WLEncoding)encoding;
+ (WLSite *)siteWithDictionary:(NSDictionary *)d;
- (NSDictionary *)dictionaryOfSite;

@property (NS_NONATOMIC_IOSONLY, getter=isDummy, readonly) BOOL dummy;
@end

//
//  WLSite.h
//  Welly
//
//  YLSite.m
//  MacBlueTelnet
//
//  Created by Lan Yung-Luen on 11/20/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "WLSite.h"
#import "WLGlobalConfig.h"

NSString *const YLSiteNameAttributeName = @"name";
NSString *const YLSiteAddressAttributeName = @"address";
NSString *const YLSiteEncodingAttributeName = @"encoding";
NSString *const YLSiteAnsiColorKeyAttributeName = @"ansicolorkey";
NSString *const YLSiteDetectDoubleByteAttributeName = @"detectdoublebyte";
NSString *const YLSiteEnableMouseAttributeName = @"enablemouse";
NSString *const YLSiteAutoReplyStringAttributeName = @"autoreplystring";
NSString *const WLSiteProxyTypeAttributeName = @"proxytype";
NSString *const WLSiteProxyAddressAttributeName = @"proxyaddress";

NSString *const WLDefaultAutoReplyString = @"DefaultAutoReplyString";
NSString *const WLDefaultSiteName = @"DefaultSiteName";

@implementation WLSite

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setName:NSLocalizedString(WLDefaultSiteName, @"Site")];
        
        self.address = @"";
        
        self.encoding = [WLGlobalConfig sharedInstance].defaultEncoding;
        self.shouldDetectDoubleByte = [WLGlobalConfig sharedInstance].shouldDetectDoubleByte;
        self.shouldEnableMouse = [WLGlobalConfig sharedInstance].shouldEnableMouse;
        self.ansiColorKey = [WLGlobalConfig sharedInstance].defaultANSIColorKey;
        [self setShouldAutoReply:NO];
        [self setAutoReplyString:NSLocalizedString(WLDefaultAutoReplyString, @"Site")];
        self.proxyType = 0;
        self.proxyAddress = @"";
    }
    return self;
}

+ (WLSite *)site {
    return [WLSite new];
}

+ (WLSite *)siteWithName:(NSString *)name
                 address:(NSString *)address
                encoding:(WLEncoding)encoding
            ansiColorKey:(YLANSIColorKey)ansiColorKey {
    WLSite *s = [WLSite site];
    s.name = name;
    s.address = address;
    s.encoding = encoding;
    s.ansiColorKey = ansiColorKey;
    return s;
}

+ (WLSite *)siteWithDictionary:(NSDictionary *)d {
    WLSite *s = [WLSite site];
    s.name = [d valueForKey:YLSiteNameAttributeName] ?: @"";
    s.address = [d valueForKey:YLSiteAddressAttributeName] ?: @"";
    s.encoding = (WLEncoding)[[d valueForKey:YLSiteEncodingAttributeName] unsignedShortValue];
    s.ansiColorKey = (YLANSIColorKey)[[d valueForKey:YLSiteAnsiColorKeyAttributeName] unsignedShortValue];
    s.shouldDetectDoubleByte = [[d valueForKey:YLSiteDetectDoubleByteAttributeName] boolValue];
    s.shouldEnableMouse = [[d valueForKey:YLSiteEnableMouseAttributeName] boolValue];
    [s setShouldAutoReply:NO];
    s.autoReplyString = [d valueForKey:YLSiteAutoReplyStringAttributeName] ?: NSLocalizedString(WLDefaultAutoReplyString, @"Site");
    s.proxyType = [[d valueForKey:WLSiteProxyTypeAttributeName] unsignedShortValue];
    s.proxyAddress = [d valueForKey:WLSiteProxyAddressAttributeName] ?: @"";
    return s;
}

- (NSDictionary *)dictionaryOfSite {
    return @{YLSiteNameAttributeName: self.name ?: @"", YLSiteAddressAttributeName: self.address,
             YLSiteEncodingAttributeName: [NSNumber numberWithUnsignedShort:self.encoding], 
             YLSiteAnsiColorKeyAttributeName: [NSNumber numberWithUnsignedShort:self.ansiColorKey], 
             YLSiteDetectDoubleByteAttributeName: @(self.shouldDetectDoubleByte),
             YLSiteEnableMouseAttributeName: @(self.shouldEnableMouse),
             YLSiteAutoReplyStringAttributeName: self.autoReplyString ?: @"",
             WLSiteProxyTypeAttributeName: [NSNumber numberWithUnsignedShort:self.proxyType],
             WLSiteProxyAddressAttributeName: self.proxyAddress ?: @""};
}

- (BOOL)isDummy {
    return _address.length == 0;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%@", self.name, self.address];
}

- (id)copyWithZone:(NSZone *)zone {
    WLSite *s = [[WLSite allocWithZone:zone] init];
    s.name = self.name;
    s.address = self.address;
    s.encoding = self.encoding;
    s.ansiColorKey = self.ansiColorKey;
    s.shouldDetectDoubleByte = self.shouldDetectDoubleByte;
    [s setShouldAutoReply:NO];
    s.autoReplyString = self.autoReplyString;
    s.shouldEnableMouse = self.shouldEnableMouse;
    s.proxyType = self.proxyType;
    s.proxyAddress = self.proxyAddress;
    return s;
}

@end

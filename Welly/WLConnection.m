//
//  WLConnection.h
//  Welly
//
//  YLConnection.mm
//  MacBlueTelnet
//
//  Created by Lan Yung-Luen on 12/7/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "WLConnection.h"
#import "WLTerminal.h"
#import "WLTerminalFeeder.h"
#import "WLEncoder.h"
#import "WLGlobalConfig.h"
#import "WLMessageDelegate.h"
#import "WLSite.h"
#import "WLPTY.h"

@implementation WLConnection {
    NSData *_password;
    NSString *_identityFile;
}

@synthesize terminalFeeder = _feeder;

- (instancetype)initWithSite:(WLSite *)site {
    self = [self init];
    if (self) {
        // Create a feeder to parse content from the connection
        _feeder = [[WLTerminalFeeder alloc] init];
        
        self.site = site;
        if (!site.dummy) {
            [self findPassword];

            // WLPTY as the default protocol (a proxy)
            WLPTY *protocol = [WLPTY new];
            self.protocol = protocol;
            protocol.delegate = self;
            protocol.proxyType = site.proxyType;
            protocol.proxyAddress = site.proxyAddress;
            [self connect];
        }
        
        // Setup the message delegate
        _messageDelegate = [[WLMessageDelegate alloc] initWithConnection:self];
    }
    return self;
}


#pragma mark -
#pragma mark Accessor
- (void)setTerminal:(WLTerminal *)value {
    if (_terminal != value) {
        _terminal = value;
        _terminal.connection = self;
        [_feeder setTerminal:_terminal];
    }
}

- (void)setConnected:(BOOL)value {
    _connected = value;
    if (_connected) 
        self.icon = [NSImage imageNamed:NSImageNameStatusAvailable];
    else {
        [self resetMessageCount];
        self.icon = [NSImage imageNamed:NSImageNameStatusUnavailable];
    }
}

- (void)setLastTouchDate {
    _lastTouchDate = [NSDate date];
}

#pragma mark -
#pragma mark WLProtocol delegate methods
- (void)protocolWillConnect:(id)protocol {
    [self setIsProcessing:YES];
    [self setConnected:NO];
    self.icon = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
}

- (void)protocolDidConnect:(id)protocol {
    [self setIsProcessing:NO];
    [self setConnected:YES];
    if ([self hasPrivateKey]) {
        // [self removeIdentityFile];
        [NSThread detachNewThreadSelector:@selector(removeIdentityFile)
                                 toTarget:self
                               withObject:nil];
    } else if (![_site.address hasPrefix:@"ssh"]) {
        // [self login];
        [NSThread detachNewThreadSelector:@selector(login)
                                 toTarget:self
                               withObject:nil];
    }
}

- (void)protocolDidRecv:(id)protocol 
                   data:(NSData*)data {
    [_feeder feedData:data connection:self];
}

- (void)protocolWillSend:(id)protocol 
                    data:(NSData*)data {
    [self setLastTouchDate];
}

- (void)protocolDidClose:(id)protocol {
    [self setIsProcessing:NO];
    [self setConnected:NO];
    [_feeder clearAll];
    [_terminal clearAll];
}

#pragma mark -
#pragma mark Network
- (void)close {
    [_protocol close];
}

- (void)reconnect {
    [_protocol close];
    [self connect];
    [self resetMessageCount];
}

- (void)connect {
    if ([self hasPrivateKey]) {
        [self generateIdentityFile];
        [_protocol connect:_site.address withIdentityFile:_identityFile];
    } else {
        [_protocol connect:_site.address withPassword:_password];
    }
}

- (void)sendMessage:(NSData *)msg {
    [_protocol send:msg];
}

- (void)sendBytes:(const void *)buf 
           length:(NSInteger)length {
    NSData *data = [[NSData alloc] initWithBytes:buf length:length];
    [self sendMessage:data];
}

- (void)sendText:(NSString *)s {
    [self sendText:s withDelay:0];
}

- (void)sendText:(NSString *)text 
       withDelay:(int)microsecond {
    @autoreleasepool {
        
        // replace all '\n' with '\r' 
        NSString *s = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\r"];
        
        // translate into proper encoding of the site
        NSMutableData *data = [NSMutableData data];
        WLEncoding encoding = _site.encoding;
        for (int i = 0; i < s.length; i++) {
            unichar ch = [s characterAtIndex:i];
            char buf[2];
            if (ch < 0x007F) {
                buf[0] = ch;
                [data appendBytes:buf length:1];
            } else {
                unichar code = [WLEncoder fromUnicode:ch encoding:encoding];
                if (code != 0) {
                    buf[0] = code >> 8;
                    buf[1] = code & 0xFF;
                } else {
                    if (ch == 8943 && encoding == WLGBKEncoding) {
                        // hard code for the ellipsis
                        buf[0] = '\xa1';
                        buf[1] = '\xad';
                    } else if (ch != 0) {
                        buf[0] = ' ';
                        buf[1] = ' ';
                    }
                }
                [data appendBytes:buf length:2];
            }
        }
        
        // Now send the message
        if (microsecond == 0) {
            // send immediately
            [self sendMessage:data];
        } else {
            // send with delay
            const char *buf = (const char *)data.bytes;
            for (int i = 0; i < data.length; i++) {
                [self sendBytes:buf+i length:1];
                usleep(microsecond);
            }
        }
        
    }
}

#pragma mark -
#pragma mark Auto login
- (void)findPassword {
    const char *service = "Welly";
    const char *account = _site.address.UTF8String;
    UInt32 len = 0;
    void *pass = 0;
    
    OSStatus status = SecKeychainFindGenericPassword(nil,
                                                     (UInt32)strlen(service), service,
                                                     (UInt32)strlen(account), account,
                                                     &len, &pass,
                                                     nil);
    
    if (status == noErr) {
        _password = [NSData dataWithBytes:pass length:len];
        SecKeychainItemFreeContent(nil, pass);
    } else {
        _password = nil;
    }
}

- (BOOL)hasPrivateKey {
    // heuristic: assuming the length of a password is <= 60 bytes
    return _password.length > 60;
}

- (NSString *)identityFile {
    if (!_identityFile) {
        _identityFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    }
    return _identityFile;
}

- (void)generateIdentityFile {
    NSString *path = [self identityFile];
    [_password writeToFile:path atomically:YES];
    [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions:@0600} ofItemAtPath:path error:nil];
}

- (void)removeIdentityFile {
    @autoreleasepool {
        while (_feeder.cursorY <= 3) {
            sleep(1);
        }
        [[NSFileManager defaultManager] removeItemAtPath:[self identityFile] error:nil];
    }
}

- (void)login {
    @autoreleasepool {
        
        const char *account = _site.address.UTF8String;
        // telnet; send username
        char *pe = strchr(account, '@');
        if (pe) {
            char *ps = pe;
            for (; ps >= account; --ps)
            if (*ps == ' ' || *ps == '/')
                break;
            if (ps != pe) {
                while (_feeder.cursorY <= 3)
                    sleep(1);
                [self sendBytes:ps+1 length:pe-ps-1];
                [self sendBytes:"\r" length:1];
            }
        }
        if (_password) {
            // send password
            [self sendMessage:_password];
            [self sendBytes:"\r" length:1];
        }
        
    }
}

#pragma mark -
#pragma mark Message
- (void)increaseMessageCount:(NSInteger)value {
    // increase the '_messageCount' by 'value'
    if (value <= 0)
        return;
    
    WLGlobalConfig *config = [WLGlobalConfig sharedInstance];
    
    // we should let the icon on the deck bounce
    [NSApp requestUserAttention: (config.shouldRepeatBounce ? NSCriticalRequest : NSInformationalRequest)];
    config.messageCount = config.messageCount + value;
    _messageCount += value;
    self.objectCount = _messageCount;
}

// reset '_messageCount' to zero
- (void)resetMessageCount {
    if (_messageCount <= 0)
        return;
    
    WLGlobalConfig *config = [WLGlobalConfig sharedInstance];
    config.messageCount = config.messageCount - _messageCount;
    _messageCount = 0;
    self.objectCount = _messageCount;
}

- (void)didReceiveNewMessage:(NSString *)message
                  fromCaller:(NSString *)caller {
    // If there is a new message, we should notify the auto-reply delegate.
    [_messageDelegate connectionDidReceiveNewMessage:message
                                          fromCaller:caller];
}

- (BOOL)hasCloseButton {
    return YES;
}

- (void)setHasCloseButton:(BOOL)hasCloseButton {
    return;
}

@end

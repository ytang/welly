//
//  WLPTY.m
//  Welly
//
//  Created by boost @ 9# on 7/13/08.
//  Copyright 2008 Xi Wang. All rights reserved.

//  YLSSH.m
//  MacBlueTelnet
//
//  Created by Lan Yung-Luen on 12/7/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

/* Code from iTerm : PTYTask.m */

#include <util.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <termios.h>
#import "WLGlobalConfig.h"
#import "WLPTY.h"
#import "WLProxy.h"

#define CTRLKEY(c)   ((c)-'A'+1)

@implementation WLPTY {
    pid_t _pid;
    int _fd;
    BOOL _connecting;
}

+ (NSString *)parse:(NSString *)addr withIdentityFile:(NSString *)identityFile {
    // trim whitespaces
    addr = [addr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    // no longer support raw commands; convert to URL-style addr + options
    NSMutableString *options = [NSMutableString string];
    NSRange range = [addr rangeOfString:@" "];
    if (range.length > 0) {
        NSArray<NSString *> *components = [addr componentsSeparatedByString:@" "];
        for (NSUInteger i = 1; i < [components count]; ++i) {
            NSString *component = [components objectAtIndex:i];
            // heuristic: if a component has ".", then it's an address, otherwise it's an option
            if ([component rangeOfString:@"."].length > 0) {
                addr = [NSString stringWithFormat:@"%@://%@", [components objectAtIndex:0], component];
            } else if (component.length > 0) {
                [options appendFormat:@" %@", component];
            }
        }
    }
    // check protocol
    BOOL ssh;
    int version = 0;
    NSString *port = nil;
    if ([addr.lowercaseString hasPrefix: @"ssh://"]) {
        ssh = YES;
        version = 2;
        addr = [addr substringFromIndex:6];
    } else if ([addr.lowercaseString hasPrefix: @"ssh1://"]) {
        ssh = YES;
        version = 1;
        addr = [addr substringFromIndex:7];
    } else if ([addr.lowercaseString hasPrefix: @"ssh2://"]) {
        ssh = YES;
        version = 2;
        addr = [addr substringFromIndex:7];
    } else {
        ssh = NO;
        range = [addr rangeOfString:@"://"];
        if (range.length > 0)
            addr = [addr substringFromIndex:range.location + range.length];
    }
    // check port
    range = [addr rangeOfString:@":"];
    if (range.length > 0) {
        port = [addr substringFromIndex:range.location + range.length];
        addr = [addr substringToIndex:range.location];
    }
    // make the command
    NSString *path;
    NSString *fmt;
    if (ssh) {
        if (port == nil)
            port = @"22";
        if (identityFile) {
            path = [NSString stringWithFormat:@"/usr/bin/ssh -i %@ -o StrictHostKeyChecking=no -o UserKnownHostsFile=%@",
                    identityFile,
                    [NSTemporaryDirectory() stringByAppendingPathComponent:@"known_hosts"]];
            fmt = @"%@%@ -p %4$@ -x %3$@";
        } else {
            path = [NSString stringWithFormat:@"%@ -%d",
                    [[NSBundle mainBundle] pathForResource:@"plink" ofType:@""],
                    version];
            fmt = @"%@ -P %4$@ -x -no-antispoof%2$@ %3$@";
        }
    } else {
        path = @"/usr/bin/nc";
        if (port == nil)
            port = @"23";
        range = [addr rangeOfString:@"@"];
        // remove username for telnet
        if (range.length > 0)
            addr = [addr substringFromIndex:range.location + range.length];
        // "-" before the port number forces the initial option negotiation
        fmt = @"%@%@ %@ %@";
    }
    NSString *r = [NSString stringWithFormat:fmt, path, options, addr, port];
    return r;
} 

- (instancetype)init {
    self = [super init];
    if (self) {
        _pid = 0;
        _fd = -1;
    }
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)close {
    if (_pid > 0) {
        kill(_pid, SIGKILL);
        waitpid(_pid, NULL, WNOHANG);
        _pid = 0;
    }
    if (_fd >= 0) {
        close(_fd);
        _fd = -1;
        [_delegate protocolDidClose:self];
    }
}

- (BOOL)connect:(NSString *)addr withIdentityFile:(NSString *)identityFile {
    return [self connect:addr withIdentityFile:identityFile password:nil];
}

- (BOOL)connect:(NSString *)addr withPassword:(NSData *)password {
    return [self connect:addr withIdentityFile:nil password:password];
}

- (BOOL)connect:(NSString *)addr withIdentityFile:(NSString *)identityFile password:(NSData *)password {
    char slaveName[PATH_MAX];
    struct termios term;
    struct winsize size;
    
    term.c_iflag = ICRNL | IXON | IXANY | IMAXBEL | BRKINT;
    term.c_oflag = OPOST | ONLCR;
    term.c_cflag = CREAD | CS8 | HUPCL;
    term.c_lflag = ICANON | ISIG | IEXTEN | ECHO | ECHOE | ECHOK | ECHOKE | ECHOCTL;
    
    term.c_cc[VEOF]      = CTRLKEY('D');
    term.c_cc[VEOL]      = -1;
    term.c_cc[VEOL2]     = -1;
    term.c_cc[VERASE]    = 0x7f;	// DEL
    term.c_cc[VWERASE]   = CTRLKEY('W');
    term.c_cc[VKILL]     = CTRLKEY('U');
    term.c_cc[VREPRINT]  = CTRLKEY('R');
    term.c_cc[VINTR]     = CTRLKEY('C');
    term.c_cc[VQUIT]     = 0x1c;	// Control+backslash
    term.c_cc[VSUSP]     = CTRLKEY('Z');
    term.c_cc[VDSUSP]    = CTRLKEY('Y');
    term.c_cc[VSTART]    = CTRLKEY('Q');
    term.c_cc[VSTOP]     = CTRLKEY('S');
    term.c_cc[VLNEXT]    = -1;
    term.c_cc[VDISCARD]  = -1;
    term.c_cc[VMIN]      = 1;
    term.c_cc[VTIME]     = 0;
    term.c_cc[VSTATUS]   = -1;
    
    term.c_ispeed = B38400;
    term.c_ospeed = B38400;
    size.ws_col = [WLGlobalConfig sharedInstance].column;
    size.ws_row = [WLGlobalConfig sharedInstance].row;
    size.ws_xpixel = 0;
    size.ws_ypixel = 0;
    
    _pid = forkpty(&_fd, slaveName, &term, &size);
    if (_pid == 0) { /* child */
        NSArray *a = [[WLPTY parse:addr withIdentityFile:identityFile] componentsSeparatedByString:@" "];
        if ([(NSString *)a[0] hasSuffix:@"ssh"]) {
            NSString *proxyCommand = [WLProxy proxyCommandWithAddress:_proxyAddress type:_proxyType];
            if (proxyCommand) {
                proxyCommand = [@"ProxyCommand=" stringByAppendingString:proxyCommand];
                a = [[a arrayByAddingObject:@"-o"] arrayByAddingObject:proxyCommand];
            }
        } else if ([(NSString *)a[0] hasSuffix:@"plink"]) {
            NSString *proxyCommand = [WLProxy proxyCommandWithAddress:_proxyAddress type:_proxyType];
            if (proxyCommand) {
                NSString *addr = [a lastObject];
                NSRange range = [addr rangeOfString:@"@"];
                if (range.length > 0) {
                    addr = [addr substringFromIndex:range.location + range.length];
                }
                NSIndexSet *indexes = [a indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return [obj isEqual:@"-P"];
                }];
                NSString *port = [a objectAtIndex:[indexes lastIndex] + 1];
                proxyCommand = [proxyCommand stringByReplacingOccurrencesOfString:@"%h" withString:addr];
                proxyCommand = [proxyCommand stringByReplacingOccurrencesOfString:@"%p" withString:port];
                a = [[a arrayByAddingObject:@"-proxycmd"] arrayByAddingObject:proxyCommand];
            }
            if (password) {
                a = [[a arrayByAddingObject:@"-pw"]
                     arrayByAddingObject:[[NSString alloc] initWithData:password
                                                               encoding:NSUTF8StringEncoding]];
            }
        }
        NSInteger n = a.count;
        char *argv[n+1];
        for (int i = 0; i < n; ++i)
        argv[i] = (char *)[a[i] UTF8String];
        argv[n] = NULL;
        char *envp[2];
        envp[0] = (char *)[@"PUTTYDIR=" stringByAppendingString:NSTemporaryDirectory()].UTF8String;
        envp[1] = NULL;
        execve(argv[0], argv, envp);
        perror(argv[0]);
        sleep(-1); // don't bother
    } else { /* parent */
        int one = 1;
        ioctl(_fd, TIOCPKT, &one);
        cfmakeraw(&term);
        tcsetattr(_fd, TCSANOW, &term);
        [NSThread detachNewThreadSelector:@selector(readLoop:) toTarget:[self class] withObject:self];
    }
    
    _connecting = YES;
    [_delegate protocolWillConnect:self];
    return YES;
}

- (void)recv:(NSData *)data {
    if (_connecting) {
        _connecting = NO;
        [_delegate protocolDidConnect:self];
    }
    [_delegate protocolDidRecv:self data:data];
}

- (void)send:(NSData *)data {
    fd_set writefds, errorfds;
    struct timeval timeout;
    NSInteger chunkSize;
    
    if (_fd < 0 || _connecting) // disable input when connecting
        return;
    
    [_delegate protocolWillSend:self data:data];
    
    const char *msg = data.bytes;
    NSInteger length = data.length;
    while (length > 0) {
        FD_ZERO(&writefds);
        FD_ZERO(&errorfds);
        FD_SET(_fd, &writefds);
        FD_SET(_fd, &errorfds);
        
        timeout.tv_sec = 0;
        timeout.tv_usec = 100000;
        
        int result = select(_fd + 1, NULL, &writefds, &errorfds, &timeout);
        
        if (result == 0) {
            NSLog(@"timeout!");
            break;
        } else if (result < 0) { // error
            [self close];    
            break;
        }
        
        if (length > 4096) chunkSize = 4096;
        else chunkSize = length;
        
        NSInteger size = write(_fd, msg, chunkSize);
        if (size < 0)
            break;
        
        msg += size;
        length -= size;
    }
}

// NOTE: retain pty before starting the thread
+ (void)readLoop:(WLPTY *)pty {
    fd_set readfds, errorfds;
    BOOL exit = NO;
    unsigned char buf[4096];
    NSInteger iterationCount = 0;
    NSInteger result = 0;
    
    while (!exit) {
        iterationCount = 1;
        
        @autoreleasepool {
            while (!exit && iterationCount % 5000 != 0) {
                FD_ZERO(&readfds);
                FD_ZERO(&errorfds);
                
                FD_SET(pty->_fd, &readfds);
                FD_SET(pty->_fd, &errorfds);
                
                result = select(pty->_fd + 1, &readfds, NULL, &errorfds, NULL);
                
                if (result < 0) {       // error
                    exit = YES;
                    break;
                } else if (FD_ISSET(pty->_fd, &errorfds)) {
                    result = read(pty->_fd, buf, 1);
                    if (result == 0) {  // session close
                        exit = YES;
                    }
                } else if (FD_ISSET(pty->_fd, &readfds)) {
                    result = read(pty->_fd, buf, sizeof(buf));
                    if (result > 1) {
                        [pty performSelectorOnMainThread:@selector(recv:)
                                              withObject:[[NSData alloc] initWithBytes:buf+1 length:result-1]
                                           waitUntilDone:NO];
                    }
                    if (result == 0) {
                        exit = YES;
                    }
                }
                
                iterationCount++;
            }
        }
    }
    
    if (result >= 0) {
        [pty performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:NO];
    }
    
    [NSThread exit];
}
@end

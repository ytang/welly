//
//  XIPreviewController.m
//  Welly
//
//  Created by boost @ 9# on 7/15/08.
//  Copyright 2008 Xi Wang. All rights reserved.
//

#import "WLPreviewController.h"
#import "WLQuickLookBridge.h"
#import "WLGlobalConfig.h"

NSString *const WLGIFToHTMLFormat = @"<html><body bgcolor='Black'><center><img scalefit='1' style='position: absolute; top: 0; right: 0; bottom: 0; left: 0; height:100%%; margin: auto;' src='%@'></img></center></body></html>";

@interface WLDownloadDelegate : NSObject <NSWindowDelegate, NSURLDownloadDelegate> {
    // This progress bar is restored by gtCarrera
    // boost: don't put it in XIPreviewController
    NSProgressIndicator *_indicator;
    NSPanel         *_window;
    long long _contentLength;
    NSString *_filename, *_path;
    NSURLDownload *__weak _download;
}
@property(readwrite, weak) NSURLDownload *download;
- (void)showLoadingWindow;
@end

@implementation WLPreviewController

// current downloading URLs
static NSMutableSet *sURLs;
// current downloaded URLs
static NSMutableDictionary *sDownloadedURLInfo;
// Current init info
static BOOL sHasCacheDir = NO;

+ (void)initialize {
    sURLs = [[NSMutableSet alloc] initWithCapacity:10];
    // Check whether now the default Welly cache dir has been created
    // If not, create it
    if (!sHasCacheDir) {
        // Mark it as created
        sHasCacheDir = YES;
        // Get default cache dir
        NSString *cacheDir = [WLGlobalConfig cacheDirectory];
        // Create the dir
        NSFileManager *dirCheckerFileManager = [NSFileManager defaultManager];
        BOOL isDir;
        if(![dirCheckerFileManager fileExistsAtPath:cacheDir isDirectory:&isDir]) {
            if(![dirCheckerFileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:NULL]) {
                // If error, report in console and roll back the flag
                NSLog(@"Error: Create folder failed %@", cacheDir);
                sHasCacheDir = NO;
            }
        }
    }
    sDownloadedURLInfo = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (IBAction)openPreview:(id)sender {
    [WLQuickLookBridge orderFront];
}

+ (NSURLDownload *)downloadWithURL:(NSURL *)URL {
    // already downloading
    if ([sURLs containsObject:URL])
        return nil;
    // check validity
    NSURLDownload *download;
    NSString *s = URL.absoluteString;
    NSString *suffix = [s componentsSeparatedByString:@"."].lastObject;
    NSArray *suffixes = @[@"htm", @"html", @"shtml", @"com", @"net", @"org"];
    if ([s hasSuffix:@"/"] || [suffixes containsObject:suffix])
        download = nil;
    else {
        // Here, if a download is necessary, show the download window
        [sURLs addObject:URL];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL
                                                 cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                             timeoutInterval:30.0];
        WLDownloadDelegate *delegate = [[WLDownloadDelegate alloc] init];
        download = [[NSURLDownload alloc] initWithRequest:request delegate:delegate];
        delegate.download = download;
    }
    if (download == nil)
        [[NSWorkspace sharedWorkspace] openURL:URL];
    return download;
}

@end

#pragma mark -
#pragma mark WLDownloadDelegate

@implementation WLDownloadDelegate
@synthesize download = _download;

- (instancetype) init {
    if ((self = [super init])) {
        [self showLoadingWindow];
    }
    return self;
}

- (void)dealloc {
    // close window
    [_window close];
    
}

- (void)showLoadingWindow {
    unsigned int style = NSTitledWindowMask
    | NSMiniaturizableWindowMask | NSClosableWindowMask
    | NSDocModalWindowMask;
    
    // init
    _window = [[NSPanel alloc] initWithContentRect:NSMakeRect(0, 0, 400, 30)
                                         styleMask:style
                                           backing:NSBackingStoreBuffered 
                                             defer:NO];
    [_window setFloatingPanel:YES];
    _window.delegate = self;
    [_window setOpaque:YES];
    [_window center];
    _window.title = @"Loading...";
    [_window setViewsNeedDisplay:NO];
    [_window makeKeyAndOrderFront:nil];
    _window.delegate = self;
    
    // Init progress bar
    _indicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(10, 10, 380, 10)];
    [_window.contentView addSubview:_indicator];
    [_indicator startAnimation:self];
}

#pragma mark -
#pragma mark NSWindowDelegate protocol

// Window delegate for _window, finallize the download 
- (BOOL)windowShouldClose:(id)window {
    NSURL *URL = _download.request.URL;
    // Remove current url from the url list
    [sURLs removeObject:URL];
    // Cancel the download
    [_download cancel];
    
    // Commented out by K.O.ed: Don't release here, release when the delegate dealloc.
    // Otherwise this would crash when cancelling a download
    // Release if necessary
    //[_download release];
    return YES;
}

#pragma mark -
#pragma mark NSURLDownloadDelegate protocol

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response {
    _contentLength = response.expectedContentLength;
    
    // extract & fix incorrectly encoded filename (GB18030 only)
    @autoreleasepool {
        _filename = response.suggestedFilename;
        NSData *data = [_filename dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        _filename = [[NSString alloc] initWithData:data encoding:encoding];
    }
    
    // set local path
    NSString *cacheDir = [WLGlobalConfig cacheDirectory];
    _path = [cacheDir stringByAppendingPathComponent:_filename];
    if(sDownloadedURLInfo[download.request.URL.absoluteString]) { // URL in cache
        // Get local file size
        NSString * tempPath = [sDownloadedURLInfo valueForKey:download.request.URL.absoluteString];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil];
        long long fileSizeOnDisk = -1;
        if (fileAttributes != nil)
            fileSizeOnDisk = [fileAttributes[NSFileSize] longLongValue];
        if(fileSizeOnDisk == _contentLength) { // If of the same size, use current cache
            [download cancel];
            [self downloadDidFinish:download];
            return;
        }
    }
    [download setDestination:_path allowOverwrite:YES];
    
    // dectect file type to avoid useless download
    // by gtCarrera @ 9#
    NSString *fileType = _filename.pathExtension.lowercaseString;
    NSArray *allowedTypes = @[@"avif", @"bmp", @"gif", @"heic", @"jpeg", @"jpg", @"pdf", @"png", @"svg", @"tif", @"tiff", @"webp"];
    Boolean canView = [allowedTypes containsObject:fileType];
    if (!canView) {
        // Close the progress bar window
        [_window close];
        
        [download cancel];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
        [self download:download didFailWithError:error];
        return; // or next may crash
    }
    
    // Or, set the window to show the download progress
    _window.title = [NSString stringWithFormat:@"Loading %@...", _filename];
    [_indicator setIndeterminate:NO];
    _indicator.maxValue = (double)_contentLength;
    _indicator.doubleValue = 0;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length { 
    [_indicator incrementBy:(double)length];
}

static void formatProps(NSMutableString *s, id *fmt, id *val) {
    for (; *fmt; ++fmt, ++val) {
        id obj = *val;
        if (obj == nil)
            continue;
        [s appendFormat:NSLocalizedString(*fmt, nil), obj];
    }
}

- (void)downloadDidFinish:(NSURLDownload *)download {
    [sURLs removeObject:download.request.URL];
    [sDownloadedURLInfo setValue:_path forKey:download.request.URL.absoluteString];
    NSURL *url;
    if ([_path.pathExtension isEqualToString:@"gif"]) {
        url = [NSURL fileURLWithPath:[_path.stringByDeletingPathExtension stringByAppendingPathExtension:@"html"]];
        [[NSString stringWithFormat:WLGIFToHTMLFormat, [NSURL fileURLWithPath:_path]] writeToURL:url atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    } else {
        url = [NSURL fileURLWithPath:_path];
    }
    
    // For read exif info by gtCarrera
    // boost: pool (leaks), check nil (crash), readable values
    CGImageSourceRef exifSource = CGImageSourceCreateWithURL((CFURLRef)([NSURL fileURLWithPath:_path]), nil);
    if (exifSource) {
        @autoreleasepool {
            NSDictionary *metaData = (NSDictionary*) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(exifSource, 0, nil));
            NSMutableString *props = [NSMutableString string];
            NSDictionary *exifData = metaData[(NSString *)kCGImagePropertyExifDictionary];
            if (exifData) {
                NSString *dateTime = exifData[(NSString *)kCGImagePropertyExifDateTimeOriginal];
                NSNumber *eTime = exifData[(NSString *)kCGImagePropertyExifExposureTime];
                NSNumber *fLength = exifData[(NSString *)kCGImagePropertyExifFocalLength];
                NSNumber *fNumber = exifData[(NSString *)kCGImagePropertyExifFNumber];
                NSArray *isoArray = exifData[(NSString *)kCGImagePropertyExifISOSpeedRatings];
                // readable exposure time
                NSString *eTimeStr = nil;
                if (eTime) {
                    double eTimeVal = eTime.doubleValue;
                    // zero exposure time...
                    if (eTimeVal < 1 && eTimeVal != 0) {
                        eTimeStr = [NSString stringWithFormat:@"1/%g", 1/eTimeVal];
                    } else
                        eTimeStr = eTime.stringValue;
                }
                // iso
                NSNumber *iso = nil;
                if (isoArray && isoArray.count)
                    iso = isoArray[0];
                // format
                __autoreleasing id keys[] = {@"Original Date Time", @"Exposure Time", @"Focal Length", @"F Number", @"ISO", nil};
                __autoreleasing id vals[] = {dateTime, eTimeStr, fLength, fNumber, iso};
                formatProps(props, keys, vals);
            }
            
            NSDictionary *tiffData = metaData[(NSString *)kCGImagePropertyTIFFDictionary];
            if (tiffData) {
                NSString *makeName = tiffData[(NSString *)kCGImagePropertyTIFFMake];
                NSString *modelName = tiffData[(NSString *)kCGImagePropertyTIFFModel];
                // some photos give null names
                if (makeName || modelName)
                    [props appendFormat:NSLocalizedString(@"tiffStringFormat", "\nManufacturer and Model: \n%@ %@"), makeName, modelName];
            }
            
            [WLQuickLookBridge add:url withEXIF:props];
            // release
        }
        CFRelease(exifSource);
    } else {
        [WLQuickLookBridge add:url];
    }
    
    // Commented out by K.O.ed: Don't release here, release when the delegate dealloc.
    //[download release];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error {
    NSURL *URL = download.request.URL;
    [sURLs removeObject:URL];
    [[NSWorkspace sharedWorkspace] openURL:URL];
    // Commented out by K.O.ed: Don't release here, release when the delegate dealloc.
    //[download release];
}

@end

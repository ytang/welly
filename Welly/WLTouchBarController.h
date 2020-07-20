//
//  WLTouchBarController.h
//  Welly
//
//  Created by Yang Tang on 7/18/20.
//  Copyright © 2020 ytang.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLTouchBarController : NSObject {
    IBOutlet NSTextField *_siteNameTouchBarField;
    IBOutlet NSTextField *_urlModeTouchBarField;
}

+ (WLTouchBarController *)sharedInstance;

@end

NS_ASSUME_NONNULL_END

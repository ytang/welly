//
//  WLGrowlBridge.m
//  Welly
//
//  Created by aqua9 on 20/3/2008.
//  Copyright 2008 TANG Yang. All rights reserved.
//
//  Modified by boost @ 9#
//  Extend for convenience.

#import "WLGrowlBridge.h"

NSString *const WLGrowlNotificationNameFileTransfer = @"File Transfer";
NSString *const WLGrowlNotificationNameEXIFInformation = @"EXIF Information";
NSString *const WLGrowlNotificationNameNewMessageReceived = @"New Message Received";

NSString *const WLGrowlClickTargetKeyName = @"ClickTarget";
NSString *const WLGrowlClickSelectorKeyName = @"ClickSelector";
NSString *const WLGrowlClickObjectKeyName = @"ClickRepresentedObject";

@implementation WLGrowlBridge

+ (void)initialize {
    static WLGrowlBridge *sTYGrowlBridge = nil;
    if (sTYGrowlBridge == nil) {
        sTYGrowlBridge = [[WLGrowlBridge alloc] init];
        [GrowlApplicationBridge setGrowlDelegate:sTYGrowlBridge];
    }
}

- (NSDictionary *)registrationDictionaryForGrowl {
	NSArray *notifications = @[kGrowlNotificationNameFileTransfer, kGrowlNotificationNameEXIFInformation, kGrowlNotificationNameNewMessageReceived];
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict[GROWL_NOTIFICATIONS_ALL] = notifications;
	dict[GROWL_NOTIFICATIONS_DEFAULT] = notifications;
	return dict;
}

+ (BOOL)isMistEnabled {
	return [GrowlApplicationBridge isMistEnabled];
}

+ (void)notifyWithTitle:(NSString *)title
			description:(NSString *)description
	   notificationName:(NSString *)notifName {
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:notifName
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:nil];
}

+ (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
       notificationName:(NSString *)notifName
               isSticky:(BOOL)isSticky
             identifier:(id)identifier {
	if ([GrowlApplicationBridge isMistEnabled]) {
		NSLog(@"isMistEnabled");
	} else {
		NSLog(@"no");
	}
	
    // hack identifier that must be a string
    NSString *stringId = @((long)identifier).stringValue;
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:notifName
                                   iconData:nil
                                   priority:0
                                   isSticky:isSticky
                               clickContext:nil
                                 identifier:stringId];
}

+ (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
       notificationName:(NSString *)notifName
               isSticky:(BOOL)isSticky
            clickTarget:(id)target
          clickSelector:(SEL)selector
             identifier:(id)identifier {
	// capsulate target, selector and object.
	// Note: Growl only accepts pure p-list contents as click context
	//   i.e. only occurs NSDictionary, NSString, NSNumber, NSArray
    NSDictionary *clickContext = @{WLGrowlClickTargetKeyName:@((unsigned long)target), WLGrowlClickSelectorKeyName:NSStringFromSelector(selector), WLGrowlClickObjectKeyName:@((unsigned long)identifier)};
	
    // hack identifier that must be a string
    NSString *stringId = @((long)identifier).stringValue;
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:notifName
                                   iconData:nil
                                   priority:0
                                   isSticky:isSticky
                               clickContext:clickContext
                                 identifier:stringId];
}

//- (void)growlNotificationWasClicked:(id)contextId {
//	NSDictionary *context = (NSDictionary *)contextId;
//	// encapsulate target/selector/object
//	id target = (id)[context[WLGrowlClickTargetKeyName] unsignedLongValue];
//	SEL selector = NSSelectorFromString(context[WLGrowlClickSelectorKeyName]);
//	id object = (id)[context[WLGrowlClickObjectKeyName] unsignedLongValue];
//	// perform action
//	[target performSelector:selector withObject:object];
//}

- (void)growlNotificationTimedOut:(id)contextId {
    // deal with the event that the notification disappear
	// Just do nothing
}

@end

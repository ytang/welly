/*****************************************************************************
 * RemoteControlWrapper.m
 * RemoteControlWrapper
 *
 * Created by Martin Kahr on 11.03.06 under a MIT-style license. 
 * Copyright (c) 2006 martinkahr.com. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a 
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *****************************************************************************/

#import "AppleRemote.h"

#import <mach/mach.h>
#import <mach/mach_error.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDKeys.h>

const char* AppleRemoteDeviceName = "AppleIRController";

// the WWDC 07 Leopard Build is missing the constant
#ifndef NSAppKitVersionNumber10_4
	#define NSAppKitVersionNumber10_4 824
#endif

@implementation AppleRemote

+ (const char*) remoteControlDeviceName {
	return AppleRemoteDeviceName;
}

- (void) setCookieMappingInDictionary: (NSMutableDictionary*) _cookieToButtonMapping	{	
	if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_4) {
		// 10.4.x Tiger
		_cookieToButtonMapping[@"14_12_11_6_"] = @(kRemoteButtonPlus);
		_cookieToButtonMapping[@"14_13_11_6_"] = @(kRemoteButtonMinus);		
		_cookieToButtonMapping[@"14_7_6_14_7_6_"] = @(kRemoteButtonMenu);			
		_cookieToButtonMapping[@"14_8_6_14_8_6_"] = @(kRemoteButtonPlay);
		_cookieToButtonMapping[@"14_9_6_14_9_6_"] = @(kRemoteButtonRight);
		_cookieToButtonMapping[@"14_10_6_14_10_6_"] = @(kRemoteButtonLeft);
		_cookieToButtonMapping[@"14_6_4_2_"] = @(kRemoteButtonRight_Hold);
		_cookieToButtonMapping[@"14_6_3_2_"] = @(kRemoteButtonLeft_Hold);
		_cookieToButtonMapping[@"14_6_14_6_"] = @(kRemoteButtonMenu_Hold);
		_cookieToButtonMapping[@"18_14_6_18_14_6_"] = @(kRemoteButtonPlay_Hold);
		_cookieToButtonMapping[@"19_"] = @(kRemoteControl_Switched);			
	} else if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_5){
		// 10.5.x Leopard
		_cookieToButtonMapping[@"31_29_28_19_18_"] = @(kRemoteButtonPlus);
		_cookieToButtonMapping[@"31_30_28_19_18_"] = @(kRemoteButtonMinus);	
		_cookieToButtonMapping[@"31_20_19_18_31_20_19_18_"] = @(kRemoteButtonMenu);
		_cookieToButtonMapping[@"31_21_19_18_31_21_19_18_"] = @(kRemoteButtonPlay);
		_cookieToButtonMapping[@"31_22_19_18_31_22_19_18_"] = @(kRemoteButtonRight);
		_cookieToButtonMapping[@"31_23_19_18_31_23_19_18_"] = @(kRemoteButtonLeft);
		_cookieToButtonMapping[@"31_19_18_4_2_"] = @(kRemoteButtonRight_Hold);
		_cookieToButtonMapping[@"31_19_18_3_2_"] = @(kRemoteButtonLeft_Hold);
		_cookieToButtonMapping[@"31_19_18_31_19_18_"] = @(kRemoteButtonMenu_Hold);
		_cookieToButtonMapping[@"35_31_19_18_35_31_19_18_"] = @(kRemoteButtonPlay_Hold);
		_cookieToButtonMapping[@"19_"] = @(kRemoteControl_Switched);			
	} else {
		// 10.6.x Snow Leopard
		_cookieToButtonMapping[@"33_31_30_21_20_2_"] = @(kRemoteButtonPlus);
		_cookieToButtonMapping[@"33_32_30_21_20_2_"] = @(kRemoteButtonMinus);	
		_cookieToButtonMapping[@"33_22_21_20_2_33_22_21_20_2_"] = @(kRemoteButtonMenu);
		_cookieToButtonMapping[@"33_21_20_3_2_33_21_20_3_2_"] = @(kRemoteButtonPlay);
		_cookieToButtonMapping[@"33_24_21_20_2_33_24_21_20_2_"] = @(kRemoteButtonRight);
		_cookieToButtonMapping[@"33_25_21_20_2_33_25_21_20_2_"] = @(kRemoteButtonLeft);
		_cookieToButtonMapping[@"33_21_20_14_12_2_"] = @(kRemoteButtonRight_Hold);
		_cookieToButtonMapping[@"33_21_20_13_12_2_"] = @(kRemoteButtonLeft_Hold);
		_cookieToButtonMapping[@"33_21_20_2_33_21_20_2_"] = @(kRemoteButtonMenu_Hold);
		_cookieToButtonMapping[@"33_21_20_11_2_33_21_20_11_2_"] = @(kRemoteButtonPlay_Hold);
		_cookieToButtonMapping[@"19_"] = @(kRemoteControl_Switched);
		// Old model of remote control (the play and next functions are on the same key)
		_cookieToButtonMapping[@"33_23_21_20_2_33_23_21_20_2_"] = @(kRemoteButtonPlay);
		// For the new remote control - Al version, a new button is added
		// Here this button acts as the play key
		_cookieToButtonMapping[@"33_21_20_8_2_33_21_20_8_2_"] = @(kRemoteButtonPlay);

	}

}

- (void) sendRemoteButtonEvent: (RemoteControlEventIdentifier) event pressedDown: (BOOL) pressedDown {
	if (pressedDown == NO && event == kRemoteButtonMenu_Hold) {
		// There is no seperate event for pressed down on menu hold. We are simulating that event here
		[super sendRemoteButtonEvent:event pressedDown:YES];
	}	
	
	[super sendRemoteButtonEvent:event pressedDown:pressedDown];
	
	if (pressedDown && (event == kRemoteButtonRight || event == kRemoteButtonLeft || event == kRemoteButtonPlay || event == kRemoteButtonMenu || event == kRemoteButtonPlay_Hold)) {
		// There is no seperate event when the button is being released. We are simulating that event here
		[super sendRemoteButtonEvent:event pressedDown:NO];
	}
}

@end

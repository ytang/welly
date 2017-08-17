//
//  YLEmoticon.m
//  MacBlueTelnet
//
//  Created by Lan Yung-Luen on 12/4/07.
//  Copyright 2007 yllan.org. All rights reserved.
//

#import "YLEmoticon.h"


@implementation YLEmoticon

#pragma mark -
#pragma mark init and dealloc
- (instancetype)init {
    if (self = [super init]) {
        self.content = @":)";
		//        [self setName: @"smile"];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
                     content:(NSString *)content {
	if (self = [self init]) {
		_name = name;
		_content = content;
	}
	return self;
}

#pragma mark -
#pragma mark Create Emoticons
+ (YLEmoticon *)emoticonWithDictionary:(NSDictionary *)d {
    YLEmoticon *e = [[YLEmoticon alloc] init];
//    [e setName: [d valueForKey: @"name"]];
    e.content = [d valueForKey:@"content"];
    return e;    
}

+ (YLEmoticon *)emoticonWithName:(NSString *)n 
						 content:(NSString *)c {
    return [[YLEmoticon alloc] initWithName:n content:c];
}

+ (YLEmoticon *)emoticonWithString:(NSString *)string {
	return [[YLEmoticon alloc] initWithName:string content:string];
}

#pragma mark -
#pragma mark Access Emoticons
+ (NSSet *)keyPathsForValuesAffectingDescription {
    return [NSSet setWithObjects:@"content", nil];
}

- (NSDictionary *)dictionaryOfEmoticon {
    return @{@"content": self.content};
}
     
- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [[self.content componentsSeparatedByString:@"\n"] componentsJoinedByString:@""]];
}

- (void)setDescription:(NSString *)d { }

@end

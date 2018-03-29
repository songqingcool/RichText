//
//  TNEmoji.m
//  Pods
//
//  Created by  on 27/07/2017.
//
//

#import "TNEmoji.h"

@implementation TNEmoji

- (instancetype)initWithInfo:(NSDictionary *)info{
    
    self = [super init];
    if (self) {
        self.chs = info[@"chs"];
        self.cht = info[@"cht"];
        self.gif = info[@"gif"];
        self.png = info[@"png"];
        self.type = [info[@"type"] integerValue];
    }
    return self;
}
@end

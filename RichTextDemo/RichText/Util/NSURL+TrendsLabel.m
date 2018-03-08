//
//  NSURL+TrendsLabel.m
//  TNTrendsLibrary
//
//  Created by 宋庆功 on 2018/3/6.
//  Copyright © 2018年 思源. All rights reserved.
//

#import "NSURL+TrendsLabel.h"
#import <objc/runtime.h>

@implementation NSURL (TrendsLabel)

- (void)setUserInfo:(NSDictionary *)userInfo
{
    objc_setAssociatedObject(self, @selector(userInfo), userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)userInfo
{
    return objc_getAssociatedObject(self, @selector(userInfo));
}

@end

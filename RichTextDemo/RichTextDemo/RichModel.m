//
//  RichModel.m
//  RichTextDemo
//
//  Created by SONGQG on 2018/3/8.
//  Copyright © 2018年 . All rights reserved.
//

#import "RichModel.h"
#import <UIKit/UIKit.h>

@implementation RichModel

- (NSAttributedString *)displayString
{
    if (!_displayString) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"1234567 😄" attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = [UIImage imageNamed:@"trends_location"];
        attach.bounds = CGRectMake(0, -3, 18, 14);
        NSAttributedString *s1 = [NSAttributedString attributedStringWithAttachment:attach];
        [string appendAttributedString:s1];
        
        NSAttributedString *s = [[NSAttributedString alloc] initWithString:@"17600332013" attributes:@{NSLinkAttributeName:@"www.baidu.com",NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14.0],NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}];
        [string appendAttributedString:s];
        
         NSMutableAttributedString *string2 = [[NSMutableAttributedString alloc] initWithString:@"\n\n" attributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
        [string appendAttributedString:string2];
        
        NSTextAttachment *attach1 = [[NSTextAttachment alloc] init];
        attach1.image = [UIImage imageNamed:@"trends_location"];
        attach1.bounds = CGRectMake(0, -3, 18, 14);
        NSAttributedString *s2 = [NSAttributedString attributedStringWithAttachment:attach1];
        [string appendAttributedString:s2];
        _displayString = string;
    }
    return _displayString;
}

- (CGFloat)displayHeight
{
    if (_displayHeight == 0.0) {
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds)-20.0;
        CGRect rect = [self.displayString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingUsesDeviceMetrics context:nil];
        _displayHeight = ceil(CGRectGetHeight(rect));
    }
    return _displayHeight;
}

@end

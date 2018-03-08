//
//  TNRichTextLabel.h
//  TNContentBaseView
//
//  Created by 宋庆功 on 2018/3/8.
//  Copyright © 2018年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
    用UIView展示label,可以实现超链接富文本等,未实现全选或者选择部分复制
    
 
    NSLinkAttributeName设置超链接，属性对应的值就是超链接点击传递出来的参数。
    其他均依照系统API进行设置
 */

@interface TNRichTextLabel : UIView

@property (nonatomic, copy) NSAttributedString *attributedText;

// 超链接回调
@property (nonatomic, copy) void (^linkBlock)(NSURL *url);

@end

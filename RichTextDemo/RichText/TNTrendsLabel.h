//
//  TNTrendsLabel.h
//  TNContentBaseView
//
//  Created by 宋庆功 on 2018/3/6.
//  Copyright © 2018年 思源. All rights reserved.
//

#import <UIKit/UIKit.h>

// 用UITextView展示label,可以实现超链接富文本等,额外可以全选或者选择部分复制

@interface TNTrendsLabel : UITextView

// 超链接回调
@property (nonatomic, copy) void (^linkBlock)(NSURL *url);

@end

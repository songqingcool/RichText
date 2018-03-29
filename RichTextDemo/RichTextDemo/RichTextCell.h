//
//  RichTextCell.h
//  RichTextDemo
//
//  Created by SONGQG on 2018/3/8.
//  Copyright © 2018年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@class RichModel;

@interface RichTextCell : UITableViewCell

@property (nonatomic, strong) RichModel *model;

+ (CGFloat)cellHeightWithModel:(RichModel *)model;

@end

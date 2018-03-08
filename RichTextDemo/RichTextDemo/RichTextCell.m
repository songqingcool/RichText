//
//  RichTextCell.m
//  RichTextDemo
//
//  Created by SONGQG on 2018/3/8.
//  Copyright © 2018年 思源. All rights reserved.
//

#import "RichTextCell.h"
#import "RichModel.h"
#import "TNRichTextLabel.h"

@interface RichTextCell ()

@property (nonatomic, strong) TNRichTextLabel *label;

@end

@implementation RichTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    // 内容文本
    [self.contentView addSubview:self.label];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = CGRectMake(10, 10, CGRectGetWidth(self.contentView.bounds)-20, CGRectGetHeight(self.contentView.bounds)-20);
}

- (TNRichTextLabel *)label
{
    if (!_label) {
        _label = [[TNRichTextLabel alloc] init];
        _label.backgroundColor = [UIColor greenColor];
    }
    return _label;
}

- (void)setModel:(RichModel *)model
{
    _model = model;
    self.label.attributedText = model.displayString;
}

+ (CGFloat)cellHeightWithModel:(RichModel *)model
{
    return 20 + model.displayHeight;
}

@end

//
//  RichModel.h
//  RichTextDemo
//
//  Created by SONGQG on 2018/3/8.
//  Copyright © 2018年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface RichModel : NSObject

@property (nonatomic, copy) NSAttributedString *displayString;
@property (nonatomic) CGFloat displayHeight;

@property (nonatomic) CGFloat cellHeight;

@end

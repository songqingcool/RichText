//
//  TNRichTextLabel.m
//  TNContentBaseView
//
//  Created by 宋庆功 on 2018/3/8.
//  Copyright © 2018年 思源. All rights reserved.
//

#import "TNRichTextLabel.h"

@interface TNRichTextLabel ()

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

// 超链接的<rangString:value>
@property (nonatomic, strong) NSMutableDictionary *linksDict;

@end

@implementation TNRichTextLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.textStorage addLayoutManager:self.layoutManager];
        [self.layoutManager addTextContainer:self.textContainer];
        self.layoutManager.allowsNonContiguousLayout = NO;
        self.textContainer.lineFragmentPadding = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textContainer.size = self.bounds.size;
    [self.layoutManager textContainerChangedGeometry:self.textContainer];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
     NSAttributedString *contentString = [self dealLinkWithAttributedString:attributedText];
    _attributedText = contentString;
    [self.textStorage setAttributedString:contentString];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSRange range = NSMakeRange(0, self.textStorage.length);
    [self.layoutManager drawBackgroundForGlyphRange:range atPoint:CGPointZero];
    [self.layoutManager drawGlyphsForGlyphRange:range atPoint:CGPointZero];
}

- (NSAttributedString *)dealLinkWithAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *tempString = [attributedString mutableCopy];
    __weak TNRichTextLabel *weakSelf = self;
    [attributedString enumerateAttribute:NSLinkAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        __strong TNRichTextLabel *strongSelf = weakSelf;
        if (value) {
            [tempString removeAttribute:NSLinkAttributeName range:range];
            NSString *rangeString = NSStringFromRange(range);
            [strongSelf.linksDict setValue:value forKey:rangeString];
        }
    }];
    return tempString;
}

#pragma mark - touch events
//// 点击事件在链接上才触发touch事件
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    NSRange stringRange = NSMakeRange(0, self.textStorage.length);
//    CGRect rect = [self.layoutManager boundingRectForGlyphRange:stringRange inTextContainer:self.textContainer];
//    BOOL isPointOnGlyph = CGRectContainsPoint(rect, point);
//    if (!isPointOnGlyph) {
//        return NO;
//    }
//
//    NSUInteger index = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer];
//    for (NSString *rangeString in self.linksDict) {
//        NSRange range = NSRangeFromString(rangeString);
//        if (NSLocationInRange(index, range)) {
//            return YES;
//            break;
//        }
//    }
//    return NO;
//}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.linksDict.count) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    UITouch *touch = touches.anyObject;
    CGPoint location = [touch locationInView:self];
    
    NSUInteger index = [self.layoutManager glyphIndexForPoint:location inTextContainer:self.textContainer];
    id value = nil;
    BOOL swallowTouch = NO;
    for (NSString *rangeString in self.linksDict) {
        NSRange range = NSRangeFromString(rangeString);
        BOOL flag = NSLocationInRange(index, range);
        if (flag) {
            swallowTouch = YES;
            value = [self.linksDict objectForKey:rangeString];
            break;
        }
    }
    
    if (swallowTouch) {
        if (self.linkBlock) {
            self.linkBlock(value);
        }
    }else {
        [super touchesEnded:touches withEvent:event];
    }
}

#pragma mark - getter/setter
- (NSTextStorage *)textStorage
{
    if (!_textStorage) {
        _textStorage = [[NSTextStorage alloc] init];
    }
    return _textStorage;
}

- (NSLayoutManager *)layoutManager
{
    if (!_layoutManager) {
        _layoutManager = [[NSLayoutManager alloc] init];
    }
    return _layoutManager;
}

- (NSTextContainer *)textContainer
{
    if (!_textContainer) {
        _textContainer = [[NSTextContainer alloc] init];
    }
    return _textContainer;
}

- (NSMutableDictionary *)linksDict
{
    if (!_linksDict) {
        _linksDict = [NSMutableDictionary dictionary];
    }
    return _linksDict;
}

@end

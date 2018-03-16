//
//  TNTrendsLabel.m
//  TNContentBaseView
//
//  Created by 宋庆功 on 2018/3/6.
//  Copyright © 2018年 思源. All rights reserved.
//

#import "TNTrendsLabel.h"
#import "TNEmojiUtility.h"

@interface TNTrendsLabel ()<UITextViewDelegate,UITextDragDelegate>

@end

@implementation TNTrendsLabel

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        self.editable = NO;
        self.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.textDragDelegate = self;
        }
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollEnabled = NO;
        self.layoutManager.allowsNonContiguousLayout = NO;
        self.textContainer.lineFragmentPadding = 0;
        self.textContainerInset = UIEdgeInsetsZero;
    }
    return self;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL canPerform = NO;
    if(action == @selector(copy:) ||
       action == @selector(selectAll:)) {
        canPerform = YES;
    }
    return canPerform;
}

- (void)copy:(id)sender
{
    NSAttributedString *selectString = [self.attributedText attributedSubstringFromRange:self.selectedRange];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = [[TNEmojiUtility sharedInstance] originEmojiStringDealWithAttributedString:selectString];
    pasteboard.string = string;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0)
{
    if (self.linkBlock) {
        self.linkBlock(URL);
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0)
{
    [textView select:textView];
    [textView setSelectedRange:characterRange];
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithURL:inRange:forInteractionType: instead")
{
    if (self.linkBlock) {
        self.linkBlock(URL);
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_DEPRECATED_IOS(7_0, 10_0, "Use textView:shouldInteractWithTextAttachment:inRange:forInteractionType: instead")
{
    [textView select:textView];
    [textView setSelectedRange:characterRange];
    return NO;
}

#pragma mark - UITextDragDelegate
- (NSArray<UIDragItem *> *)textDraggableView:(UIView<UITextDraggable> *)textDraggableView itemsForDrag:(id<UITextDragRequest>)dragRequest API_AVAILABLE(ios(11.0))
{
    return nil;
}

- (UITargetedDragPreview *)textDraggableView:(UIView<UITextDraggable> *)textDraggableView dragPreviewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session API_AVAILABLE(ios(11.0))
{
    return nil;
}

@end

//
//  TNEmojiUtility.h
//  Pods
//
//  Created by  on 24/07/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TNEmoji;

@interface TNEmojiUtility : NSObject
// 手机号检测
@property (nonatomic, strong) NSRegularExpression *phoneNumberRegular;
// 链接检测
@property (nonatomic, strong) NSRegularExpression *linkRegular;
// 表情正则
@property (nonatomic, strong) NSRegularExpression *emojiRegular;

// toon自定义表情资源列表缓存
@property (nonatomic, strong, readonly) NSMutableArray *emojiArray;

+ (instancetype)sharedInstance;

#pragma mark - 获取Emoji对象
- (TNEmoji *)getEmojiFromOriginText:(NSString *)originText NS_DEPRECATED_IOS(2_0, 2_0, "Don't Use");

#pragma mark - 适用于TNTrendsLabel
// 将字符串中的 [微笑] 转为 😁
- (NSAttributedString *)emotionDealWithAttributedString:(NSAttributedString *)content
                                             attributes:(NSDictionary *)attributes;

/*
 * 该方法将[微笑]转为😁支持自配置NSTextAttachment
 *
 * 在使用该方法的时候，需要设置image的setAccessibilityIdentifier
 * 使用方式：[image setAccessibilityIdentifier:emoji.chs];
 * 如果不按照上面规则，originEmojiStringDealWithAttributedString:方法从NSAttributedString反向转
 * NSString的时候无法将😁转为[微笑]
 */
- (NSAttributedString *)emotionDealWithAttributedString:(NSAttributedString *)content
                     configEmojiReplaceAttributedString:(NSAttributedString *(^)(TNEmoji *))configBlock;

#pragma mark - 😁 转为 [微笑]
- (NSString *)originEmojiStringDealWithAttributedString:(NSAttributedString *)attributedString;

#pragma mark - 网址手机号检测
- (NSAttributedString *)linkAndPhoneDealWithAttributedString:(NSAttributedString *)attributedString;

#pragma mark - 指定行数截取
/**
 最多显示多少行，尾部截断并添加truncateString
 
 @param string 原富媒体字符串
 @param maxRow 最多显示多少行
 @param width 文本展示宽度约束
 @param truncateString 截断字符串(如:"...")
 @return 截断之后要显示的富媒体字符串
 */
- (NSAttributedString *)clipsStringWithAttributedString:(NSAttributedString *)string
                                                 maxRow:(NSInteger)maxRow
                                                  width:(CGFloat)width
                                         truncateString:(NSAttributedString *)truncateString;

/**
 根据宽度和label显示的属性得到按行分隔好的字符串数组
 
 @param string 原富媒体字符串
 @param width 指定的宽度
 @return 分隔后的字符串数组
 */
- (NSArray<NSAttributedString *> *)separatedLinesDealWithAttributedString:(NSAttributedString *)string width:(CGFloat)width;

/**
 截取当前字符串的子串，使子串加上holder小于width宽度。返回值为子串
 
 @param string 原富媒体字符串
 @param width 指定宽度
 @param holder 要添加的holder
 @param forceAdd 是否必须添加
 @return 经过处理的子串
 */
- (NSAttributedString *)truncateDealWithAttributedString:(NSAttributedString *)string
                                                maxWidth:(CGFloat)width
                                             placeHolder:(NSAttributedString *)holder
                                                forceAdd:(BOOL)forceAdd;

@end

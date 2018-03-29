//
//  TNEmojiUtility.h
//  Pods
//
//  Created by  on 24/07/2017.
//
//

#import <Foundation/Foundation.h>

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
// 根据字符串"[微笑]"获取emoji对象
- (TNEmoji *)getEmojiFromOriginText:(NSString *)originText;

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

@end

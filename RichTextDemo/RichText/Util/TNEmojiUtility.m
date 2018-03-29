//
//  TNEmojiUtility.m
//  Pods
//
//  Created by  on 24/07/2017.
//
//

#import "TNEmojiUtility.h"
#import "TNEmoji.h"
#import "NSURL+TrendsLabel.h"
#import <UIKit/UIKit.h>

//自定义表情的图片路径
#define TNRESOURCEEMOJI_BUNDLE_PATH(_FILE_NAME_) [NSString stringWithFormat:@"ResourceEmoji.bundle/com.toon.default/%@",_FILE_NAME_]

// 手机号正则表达式匹配规则
#define kPHONE_REGULAR_RULE  @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|\\d{7,15}|(4|8)[0-9]{2,9}[-][0-9]{3,9}[-][0-9]{1,9}|(4|8)[0-9]{2,9}[-][0-9]{3,9}"
// 链接正则表达式匹配规则
#define kLINK_REGULAR_RULE  @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(http[s]{0,1}|ftp)://\\d+\\.\\d+\\.\\d+\\.\\d+[^\\s]*"
// 自定义表情正则表达式匹配规则
#define kEMOJI_REGULAR_RULE  @"(\\[[^\\]]*\\])"

@interface TNEmojiUtility ()

// 表情资源列表缓存
@property (nonatomic, strong) NSMutableDictionary *emojiDict;

@end

@implementation TNEmojiUtility

@synthesize emojiArray=_emojiArray;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static TNEmojiUtility *sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadToonCustomEmoji];
    }
    return self;
}

- (NSRegularExpression *)phoneNumberRegular
{
    if (!_phoneNumberRegular) {
        _phoneNumberRegular = [NSRegularExpression regularExpressionWithPattern:kPHONE_REGULAR_RULE options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return _phoneNumberRegular;
}

- (NSRegularExpression *)linkRegular
{
    if (!_linkRegular) {
        _linkRegular = [NSRegularExpression regularExpressionWithPattern:kLINK_REGULAR_RULE options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return _linkRegular;
}

- (NSRegularExpression *)emojiRegular
{
    if (!_emojiRegular) {
        _emojiRegular = [NSRegularExpression regularExpressionWithPattern:kEMOJI_REGULAR_RULE options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return _emojiRegular;
}

- (NSMutableDictionary *)emojiDict
{
    if (!_emojiDict) {
        _emojiDict = [NSMutableDictionary dictionary];
    }
    return _emojiDict;
}

- (NSMutableArray *)emojiArray
{
    if (!_emojiArray) {
        _emojiArray = [NSMutableArray array];
    }
    return _emojiArray;
}

- (void)loadToonCustomEmoji
{
    NSString *emojiBundlePath = [[NSBundle mainBundle] pathForResource:@"ResourceEmoji" ofType:@"bundle"];
    // 表情和表情Info.plist 在bundle 的路径
    NSString *plistPath = [emojiBundlePath stringByAppendingPathComponent:@"com.toon.default/Emoji.plist"];
    NSDictionary *emotions = [NSDictionary dictionaryWithContentsOfFile:plistPath][@"emotions"];
    for (NSDictionary *info in emotions) {
        TNEmoji *emoji = [[TNEmoji alloc] initWithInfo:info];
        [self.emojiDict setObject:emoji forKey:emoji.chs];
        [self.emojiArray addObject:emoji];
    }
}

#pragma mark - 获取Emoji对象
- (TNEmoji *)getEmojiFromOriginText:(NSString *)originText
{
    TNEmoji *emoji = [self.emojiDict objectForKey:originText];
    return emoji;
}

#pragma mark - 适用于TNTrendsLabel
- (NSAttributedString *)emotionDealWithAttributedString:(NSAttributedString *)content
                                             attributes:(NSDictionary *)attributes
{
    UIFont *font = [attributes objectForKey:NSFontAttributeName];
    if (!font) {
        font = [UIFont systemFontOfSize:15.0];
    }
    NSParagraphStyle *style = [attributes objectForKey:NSParagraphStyleAttributeName];
    if (!style) {
        style = [NSParagraphStyle defaultParagraphStyle];
    }
    NSAttributedString *attributedString = [self emotionDealWithAttributedString:content configEmojiReplaceAttributedString:^NSAttributedString *(TNEmoji *emoji) {
        // 将Emoji表情转为Attributed String
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
        UIImage *pngImage = [UIImage imageNamed:TNRESOURCEEMOJI_BUNDLE_PATH(emoji.png)];
        pngImage.accessibilityIdentifier = emoji.chs;
        textAttachment.image = pngImage;
        NSMutableAttributedString *replacement = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
        [replacement addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, replacement.length)];
        return replacement;
    }];
    return attributedString;
}

- (NSAttributedString *)emotionDealWithAttributedString:(NSAttributedString *)content
                     configEmojiReplaceAttributedString:(NSAttributedString *(^)(TNEmoji *))configBlock
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:content];
    // 通过正则表达式，匹配[微笑]等表情
    NSArray *matchResults = [self.emojiRegular matchesInString:content.string options:kNilOptions range:NSMakeRange(0, content.length)];
    // 匹配结果中如果在本地有对应的图片资源，则替换[微笑]为😁；否则不予处理。
    __weak TNEmojiUtility *weakSelf = self;
    [matchResults enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong TNEmojiUtility *strongSelf = weakSelf;
        NSTextCheckingResult *result = (NSTextCheckingResult *)obj;
        NSString *match = [strongSelf.emojiRegular replacementStringForResult:result
                                                                     inString:content.string
                                                                       offset:0
                                                                     template:@"$0"];
        TNEmoji *emoji = [strongSelf.emojiDict objectForKey:match];
        if (emoji && configBlock) {
            //将Emoji表情转为Attributed String
            NSAttributedString *replacement = configBlock(emoji);
            //用转换后的Emoji表情替换[微笑]等字符
            [attributedString replaceCharactersInRange:result.range withAttributedString:replacement];
        }
    }];
    return attributedString;
}

#pragma mark - 😁 转为 [微笑]
- (NSString *)originEmojiStringDealWithAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *retString = [attributedString mutableCopy];
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        //将🙂转换为[微笑]
        NSTextAttachment *attachment = (NSTextAttachment *)value;
        NSString *imageName = attachment.image.accessibilityIdentifier;
        if (imageName) {
            [retString replaceCharactersInRange:range withString:imageName];
        }
    }];
    return retString.string;
}

#pragma mark - 网址手机号检测
/**
 网址手机号检测
 
 @param attributedString 被检测字符串
 @return 添加完链接的富媒体字符串
 */
- (NSAttributedString *)linkAndPhoneDealWithAttributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *retString = [attributedString mutableCopy];
    // 通过正则表达式，匹配手机号
    NSArray *phoneResults = [self.phoneNumberRegular matchesInString:retString.string options:kNilOptions range:NSMakeRange(0, retString.length)];
    __weak TNEmojiUtility *weakSelf = self;
    [phoneResults enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong TNEmojiUtility *strongSelf = weakSelf;
        NSTextCheckingResult *result = (NSTextCheckingResult *)obj;
        NSString *matchString = [strongSelf.phoneNumberRegular replacementStringForResult:result
                                                                           inString:attributedString.string
                                                                             offset:0
                                                                           template:@"$0"];
        NSURL *url = [[NSURL alloc] init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:matchString forKey:@"url"];
        [dict setValue:@(NSTextCheckingTypePhoneNumber) forKey:@"type"];
        url.userInfo = dict;
        [retString addAttribute:NSLinkAttributeName value:url range:result.range];
    }];
    // 通过正则表达式，匹配链接
    NSArray *linkResults = [self.linkRegular matchesInString:retString.string options:kNilOptions range:NSMakeRange(0, retString.length)];
    [linkResults enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        __strong TNEmojiUtility *strongSelf = weakSelf;
        NSTextCheckingResult *result = (NSTextCheckingResult *)obj;
        NSString *matchString = [strongSelf.linkRegular replacementStringForResult:result
                                                                                 inString:attributedString.string
                                                                                   offset:0
                                                                                 template:@"$0"];
        NSURL *url = [[NSURL alloc] init];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:matchString forKey:@"url"];
        [dict setValue:@(NSTextCheckingTypeLink) forKey:@"type"];
        url.userInfo = dict;
        [retString addAttribute:NSLinkAttributeName value:url range:result.range];
    }];
    return retString;
}

@end

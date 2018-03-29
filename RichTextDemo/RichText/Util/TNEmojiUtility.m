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
#import "TNTrendsTextRunDelegate.h"

//自定义表情的图片路径
#define TNRESOURCEEMOJI_BUNDLE_PATH(_FILE_NAME_) [NSString stringWithFormat:@"ResourceEmoji.bundle/com.toon.default/%@",_FILE_NAME_]

// 手机号正则表达式匹配规则
#define kPHONE_REGULAR_RULE  @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|\\d{7,15}|(4|8)[0-9]{2,9}[-][0-9]{3,9}[-][0-9]{1,9}|(4|8)[0-9]{2,9}[-][0-9]{3,9}"
// 链接正则表达式匹配规则
#define kLINK_REGULAR_RULE  @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(http[s]{0,1}|ftp)://\\d+\\.\\d+\\.\\d+\\.\\d+[^\\s]*"
// 自定义表情正则表达式匹配规则
#define kEMOJI_REGULAR_RULE  @"(\\[[^\\]]*\\])"

// 行末截断留余量
static const CGFloat kRightMargin = 5.0;
// 默认行高
static const CGFloat kDefaultLineHeight = 30.0;

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
        if (value) {
            //将🙂转换为[微笑]
            NSTextAttachment *attachment = (NSTextAttachment *)value;
            NSString *imageName = attachment.image.accessibilityIdentifier;
            if (imageName) {
                [retString replaceCharactersInRange:range withString:imageName];
            }
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
        NSURL *url = [[NSURL alloc] initWithString:@""];
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
        NSURL *url = [[NSURL alloc] initWithString:@""];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:matchString forKey:@"url"];
        [dict setValue:@(NSTextCheckingTypeLink) forKey:@"type"];
        url.userInfo = dict;
        [retString addAttribute:NSLinkAttributeName value:url range:result.range];
    }];
    return retString;
}

#pragma mark - 指定行数截取
/**
 最多显示多少行，尾部截断并添加truncateString
 
 @param maxRow 最多显示多少行
 @param width 文本展示宽度约束
 @param truncateString 截断字符串(如:"...")
 @return 截断之后要显示的富媒体字符串
 */
- (NSAttributedString *)clipsStringWithAttributedString:(NSAttributedString *)string
                                                 maxRow:(NSInteger)maxRow
                                                  width:(CGFloat)width
                                         truncateString:(NSAttributedString *)truncateString
{
    //
    NSAttributedString *tempString = [string copy];
    // 五行处理
    NSArray *linesArray = [self separatedLinesDealWithAttributedString:tempString width:width];
    NSMutableAttributedString *retString = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < linesArray.count; i++) {
        NSAttributedString *string = [linesArray objectAtIndex:i];
        if (i == maxRow-1) {
            NSAttributedString *truncatedString = [self truncateDealWithAttributedString:string maxWidth:width placeHolder:truncateString forceAdd:linesArray.count>maxRow];
            [retString appendAttributedString:truncatedString];
            break;
        }
        [retString appendAttributedString:string];
    }
    return retString;
}

// 根据宽度和label显示的属性得到按行分隔好的字符串数组
- (NSArray<NSAttributedString *> *)separatedLinesDealWithAttributedString:(NSAttributedString *)string width:(CGFloat)width
{
    //
    NSAttributedString *tempString = [self addRunDelegateDealWithAttributedString:string];
    // 多行处理
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)tempString);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.0,0.0,width,CGFLOAT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    CFIndex lineCount = CFArrayGetCount(lines);
    for (CFIndex idx = 0; idx < lineCount; idx++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSAttributedString *lineString = [tempString attributedSubstringFromRange:range];
        NSAttributedString *resultString = [self deleteRunDelegateDealWithAttributedString:lineString];
        [linesArray addObject:resultString];
    }
    
    CFRelease(frameSetter);
    CFRelease(path);
    CFRelease(frame);
    return linesArray;
}

// 截取当前字符串的子串，使子串加上holder小于width宽度。返回值为子串
- (NSAttributedString *)truncateDealWithAttributedString:(NSAttributedString *)string
                                                maxWidth:(CGFloat)width
                                             placeHolder:(NSAttributedString *)holder
                                                forceAdd:(BOOL)forceAdd
{
    NSAttributedString *addedString = [self addRunDelegateDealWithAttributedString:string];
    NSAttributedString *addedHolder = [self addRunDelegateDealWithAttributedString:holder];
    // 按照宽度截取并按需要添加上holder
    NSMutableAttributedString *retString = [addedString mutableCopy];
    BOOL isClipped = NO;
    while (true) {
        NSMutableAttributedString *tempString = [retString mutableCopy];
        [tempString appendAttributedString:addedHolder];
        // 计算行宽
        CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)tempString);
        CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, tempString.length), NULL, CGSizeMake(CGFLOAT_MAX, kDefaultLineHeight), NULL);
        CFRelease(frameSetter);
        if (suggestedSize.width <= width-kRightMargin) {
            break;
        }
        __block NSRange range = NSMakeRange(0, 0);
        [retString.string enumerateSubstringsInRange:NSMakeRange(0, retString.length) options:NSStringEnumerationByComposedCharacterSequences|NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            range = substringRange;
            *stop = YES;
        }];
        if (!isClipped) {
            isClipped = YES;
        }
        [retString deleteCharactersInRange:range];
    }
    if (isClipped || forceAdd) {
        [retString appendAttributedString:addedHolder];
    }
    NSAttributedString *resultString = [self deleteRunDelegateDealWithAttributedString:retString];
    return resultString;
}

// 为NSAttachment添加runDelete
- (NSAttributedString *)addRunDelegateDealWithAttributedString:(NSAttributedString *)string
{
    NSMutableAttributedString *retString = [string mutableCopy];
    [string enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, string.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            NSTextAttachment *attachment = (NSTextAttachment *)value;
            TNTrendsTextRunDelegate *delegate = [[TNTrendsTextRunDelegate alloc] init];
            delegate.width = CGRectGetWidth(attachment.bounds);
            delegate.ascent = CGRectGetHeight(attachment.bounds)+CGRectGetMinY(attachment.bounds);
            delegate.descent = ABS(CGRectGetMinY(attachment.bounds));
            if (delegate.descent < 0) delegate.descent = 0;
            CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
            [retString addAttribute:(id)kCTRunDelegateAttributeName value:(__bridge id)delegateRef range:range];
            if (delegate) CFRelease(delegateRef);
        }
    }];
    return retString;
}

// 为NSAttachment移除runDelete
- (NSAttributedString *)deleteRunDelegateDealWithAttributedString:(NSAttributedString *)string
{
    NSMutableAttributedString *retString = [string mutableCopy];
    [retString removeAttribute:(id)kCTRunDelegateAttributeName range:NSMakeRange(0, retString.length)];
    return retString;
}

@end

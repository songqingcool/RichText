//
//  TNEmoji.h
//  Pods
//
//  Created by  on 27/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface TNEmoji : NSObject

@property (nonatomic, strong) NSString *chs;
@property (nonatomic, strong) NSString *cht;
@property (nonatomic, strong) NSString *gif;
@property (nonatomic, strong) NSString *png;
@property (nonatomic) NSInteger type;

- (instancetype)initWithInfo:(NSDictionary *)info;

@end


//
//  TNTrendsTextRunDelegate.h
//  TNTrendsTextRunDelegate
//
//  Created by 宋庆功 on 2018/3/27.
//  Copyright © 2018年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

/**
 Wrapper for CTRunDelegateRef.
 
 Example:
 
 TNTrendsTextRunDelegate *delegate = [TNTrendsTextRunDelegate new];
 delegate.ascent = 20;
 delegate.descent = 4;
 delegate.width = 20;
 CTRunDelegateRef ctRunDelegate = delegate.CTRunDelegate;
 if (ctRunDelegate) {
 /// add to attributed string
 CFRelease(ctRunDelegate);
 }
 
 */

@interface TNTrendsTextRunDelegate : NSObject <NSCopying, NSCoding>

/**
 Creates and returns the CTRunDelegate.
 
 @discussion You need call CFRelease() after used.
 The CTRunDelegateRef has a strong reference to this TNTrendsTextRunDelegate object.
 In CoreText, use CTRunDelegateGetRefCon() to get this TNTrendsTextRunDelegate object.
 
 @return The CTRunDelegate object.
 */
- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED;

/**
 Additional information about the the run delegate.
 */
@property (nonatomic, strong) NSDictionary *userInfo;

/**
 The typographic ascent of glyphs in the run.
 */
@property (nonatomic, assign) CGFloat ascent;

/**
 The typographic descent of glyphs in the run.
 */
@property (nonatomic, assign) CGFloat descent;

/**
 The typographic width of glyphs in the run.
 */
@property (nonatomic, assign) CGFloat width;

@end

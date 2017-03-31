//
//  NSString+CalculateSize.h
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (CalculateSize)
#pragma mark 根据显示文字内容匹配文字size
+ (CGSize)contentAutoSizeWithText:(NSString *)text boundSize:(CGSize)boundSize font:(UIFont *)font NS_AVAILABLE(10_11, 7_0);

/**
 *  根据显示内容匹配宽度
 *
 *  @param text     显示内容
 *  @param height   内容高度
 *  @param fontSize    字体
 *
 *  @return 内容实际大小
 */
+ (CGSize)contentAutoWidhttWithText:(NSString *)text textHeight:(NSUInteger)height fontSize:(CGFloat)fontSize;

/**
 *  根据字体 宽度 算出换行后根据rate比例的子字符串
 *
 *  @param font        字体
 *  @param actualWidth 所占宽度
 *  @param text        输入字符串
 *  @param targetRate  宽度比例
 *
 *  @return 计算出最终字符串
 */
+ (NSString *)textWithFont:(UIFont *)font width:(CGFloat)actualWidth text:(NSString *)text rate:(CGFloat)targetRate;

+ (NSMutableString *)calculateFinalStrWithStr:(NSString *)contentStr tatgetWidth:(CGFloat )width targetHeight:(CGFloat)height font:(UIFont *)font;

@end

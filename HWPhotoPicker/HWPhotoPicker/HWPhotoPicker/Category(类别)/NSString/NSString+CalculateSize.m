//
//  NSString+CalculateSize.m
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import "NSString+CalculateSize.h"
#import "NSString+ECExtensions.h"
@implementation NSString (CalculateSize)
#pragma mark 根据显示文字内容匹配文字size
+ (CGSize)contentAutoSizeWithText:(NSString *)text boundSize:(CGSize)boundSize font:(UIFont *)font
{
    CGSize size = CGSizeZero;
    text = [NSString stringEmptyTransform:text];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        size = [text boundingRectWithSize:boundSize options: NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }
    return size;
}

+ (CGSize)contentAutoWidhttWithText:(NSString *)text textHeight:(NSUInteger)height fontSize:(CGFloat)fontSize
{
    CGSize Size;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7){
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        Size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        
        
    }
    else
    {
        Size = [text sizeWithFont:font
                constrainedToSize:CGSizeMake(MAXFLOAT, height)
                    lineBreakMode:NSLineBreakByWordWrapping];
    }
    return Size;
}


+ (NSString *)textWithFont:(UIFont *)font width:(CGFloat)actualWidth text:(NSString *)text rate:(CGFloat)targetRate
{
    if (!font) {
        font = [UIFont systemFontOfSize:15.0f];
    }
    if (!actualWidth ||actualWidth == 0) {
        actualWidth = 10;
    }
    if (!text||text.length == 0) {
        text = @"";
    }
    if (!targetRate||targetRate == 0) {
        targetRate = 1.0f;
    }
    
    CGFloat targetWidth = actualWidth * targetRate;
    targetWidth = floor(targetWidth);
    
    CGFloat index         = floorf(text.length / 2.0f);
    CGFloat currentLength = text.length;
    NSString *finalText   = [text substringToIndex:index];
    CGFloat width         = 0.0f;
    CGFloat lastIndex     = 0.0f;
    
    do {
        
        CGSize textSize = [finalText sizeWithAttributes:@{NSFontAttributeName :font}];
        
        width = ceil(textSize.width);
        
        currentLength = floorf(currentLength / 2.0f);
        
        if (width < targetWidth) {
            
            index = index + 0.5 * currentLength;
            finalText = [text substringToIndex:index];
            
        } else if (width > targetWidth) {
            
            index = index - 0.5f * currentLength;
            finalText = [text substringToIndex:index];
        }
        
        if (fabs(lastIndex - index) < 2) {
            
            break;
        }
        
        lastIndex = index;
        
    } while (width != targetWidth);
    
    if (finalText.length < text.length) {
        finalText = [finalText stringByAppendingString:@"..."];
    }
    
    return [finalText stringByAppendingString:@"\n "];
}

+ (NSMutableString *)calculateFinalStrWithStr:(NSString *)contentStr tatgetWidth:(CGFloat )width targetHeight:(CGFloat)height font:(UIFont *)font{
    if (!contentStr) {
        contentStr = @"";
    }
    if (!width&&width < 0) {
        width = 0;
    }
    if (!height&&height < 0) {
        height = 0;
    }
    if (!font) {
        font = [UIFont systemFontOfSize:14.0f];
    }
    NSMutableString *finalStr = [NSMutableString string];
    [finalStr appendString:contentStr];
    CGFloat actualWidth = 0;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    
    CGFloat strWidth = [contentStr boundingRectWithSize:CGSizeMake(999, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
    if (strWidth < width) {
        [finalStr appendString:@"\n "];
    }else if (strWidth <= 1.5*width) {
        [finalStr appendString:@"\n "];
        return finalStr;
    }else{
        actualWidth = strWidth*2;
        while (actualWidth > 1.5 * width) {
            [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length - 1, 1)];
            actualWidth = [finalStr boundingRectWithSize:CGSizeMake(999, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        }
        [finalStr deleteCharactersInRange:NSMakeRange(finalStr.length - 1, 1)];
        [finalStr appendString:@"..."];
        return finalStr;
    }
    
    return finalStr;
}
@end

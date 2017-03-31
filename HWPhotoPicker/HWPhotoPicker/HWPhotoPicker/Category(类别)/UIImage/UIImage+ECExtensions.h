//
//  UIImage+ECExtensions.h
//  ECDoctor
//
//  Created by linsen on 16/5/12.
//  Copyright © 2016年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage(ECExtensions)
- (UIColor *)colorAtPixel:(CGPoint)point;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
/**
 *	@brief	图片处理 (指定比例)
 *
 *	@param 	aImage 	原始图片
 *	@param 	scale 	比例
 *
 *	@return	<#return value description#>
 *
 *	Created by mac on 2015-09-23 17:25
 */
+(UIImage *)transformationImage:(UIImage *)aImage scale:(CGFloat)scale;

/**
 *	@brief	图片处理 (指定大小 )
 *
 *	@param 	aImage 	原始图片
 *	@param 	size 	  KB
 *
 *	@return	<#return value description#>
 *
 *	Created by mac on 2015-09-23 17:25
 */
+(NSData *)transformationImage:(UIImage *)aImage toMaxDataSizeKBytes:(CGFloat)size;

@end

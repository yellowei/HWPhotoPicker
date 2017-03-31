//
//  UIView+Extension.h
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;


/**
 指定圆角

 @param corners 指定圆角
 @param borderWidth 边框宽度
 @param borderColor 边框颜色
 @param size 圆角大小
 */
- (void)setRoundedCorners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor cornerSize:(CGSize)size;

@end

//
//  UIButton+Extension.h
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extension)
/**
 *  构建图片文字按钮
 *
 *  @param btnFrame      按钮frame
 *  @param image         <#image description#>
 *  @param imageSize     <#imageSize description#>
 *  @param title         <#title description#>
 *  @param titleFont     <#titleFont description#>
 *  @param imagePosition <#imagePosition description#>
 *
 *  @return <#return value description#>
 *
 *  Supplied explanation by linsen on 2016-05-26 18:23:19
 */
+ (UIButton *)imageTitleButtonWithFrame:(CGRect)btnFrame image:(UIImage *)image showImageSize:(CGSize)imageSize title:(NSString *)title titleFont:(UIFont *)titleFont imagePosition:(UIImageOrientation)imagePosition buttonType:(UIButtonType)buttonType;




- (void)setImageTitleButtonWithFrame:(CGRect)btnFrame image:(UIImage *)image showImageSize:(CGSize)imageSize title:(NSString *)title titleFont:(UIFont *)titleFont imagePosition:(UIImageOrientation)imagePosition;

/**
 自定义button

 @param target target
 @param action action
 @return button
 */
+ (UIButton *)customBackButtonWithTarget:(id)target action:(SEL)action;

@end

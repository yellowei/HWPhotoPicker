//
//  UIView+CommonMethods.h
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CommonMethods)
+ (UIView *)getTableViewHeaderNoDataView;
+ (UIView *)getTableViewHeaderLoadingView;
+ (UIView *)getTableViewHeaderNoNetworkView;
+ (UIImageView *)getCellAccessoryDisclosureIndicatorView;
+ (UIView *)customBackImage:(UIImage *)backImg title:(NSString *)title target:(id)target action:(SEL)action;

@end

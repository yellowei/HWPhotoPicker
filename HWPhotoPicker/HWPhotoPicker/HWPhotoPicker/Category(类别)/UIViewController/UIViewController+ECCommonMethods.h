//
//  UIViewController+ECCommonMethods.h
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ECBaseViewController;
@interface UIViewController (ECCommonMethods)

/**
 截屏
 @param view 要截屏的视图
 @return 图片
 */
- (UIImage*)screenView:(UIView *)view;

/**
 *  设置堆栈中当前控制器的前一个控制器
 */
@property(nonatomic,readonly)ECBaseViewController *precontroller;

/**
 当前控制器

 @return viewcontroller
 */
- (UIViewController *)getCurrentVC;


/**
 当前控制器是否显示

 @param viewController 控制器
 @return bool
 */
+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController;



#pragma mark - 导航栏相关

/**
 定制nav 左边视图

 @param leftViewArr @[view,...]
 */
-(void)customleftViews:(NSArray *)leftViewArr;


/**
 定制nav 右边视图

 @param rightViewArr @[view,...]
 */
-(void)customNavRightViews:(NSArray *)rightViewArr;


/**
 快速定制navigation返回

 @param backImg backimg
 @param title title
 */
-(void)customBackImage:(UIImage *)backImg title:(NSString *)title;


/**
 返回

 @param sender sender
 */
- (void)onBack:(id)sender;


-(void)enablePopGesture;
-(void)disablePopGesture;
/**
 *  收起键盘
 */
- (void)hideKeyBoard;

@end

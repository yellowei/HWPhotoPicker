//
//  UIViewController+ECCommonMethods.m
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import "UIViewController+ECCommonMethods.h"
#import "UIView+CommonMethods.h"

@implementation UIViewController (ECCommonMethods)

- (UIImage*)screenView:(UIView *)view
{
    CGRect rect = view.frame;
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    CGSize newSize = CGSizeMake(width , height);
    UIGraphicsBeginImageContextWithOptions(newSize, 0.0, 2.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


-(ECBaseViewController *)precontroller
{
    if (self.navigationController.viewControllers.count > 1)
    {
        NSInteger index  =  [self.navigationController.viewControllers indexOfObject:self];
        if (index - 1 >= 0) {
            return self.navigationController.viewControllers[index - 1];
        }
    }
    return nil;
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    return result;
}

+(BOOL)isCurrentViewControllerVisible:(UIViewController *)viewController
{
    return (viewController.isViewLoaded && viewController.view.window);
}

//导航左边视图
-(void)customleftViews:(NSArray *)leftViewArr
{
    if (leftViewArr.count > 0) {
        NSMutableArray *leftBarItemArr = [NSMutableArray arrayWithCapacity:leftViewArr.count];
        for (int i = 0; i< leftViewArr.count; i++) {
            UIView *subview = leftViewArr[i];
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:subview];
            [leftBarItemArr addObject:rightItem];
        }
        self.navigationItem.leftBarButtonItems = leftBarItemArr;
    }
}

//导航右边视图
-(void)customNavRightViews:(NSArray *)rightViewArr
{
    if (rightViewArr.count > 0) {
        NSMutableArray *rightBarItemArr = [NSMutableArray arrayWithCapacity:rightViewArr.count];
        for (int i = 0; i< rightViewArr.count; i++) {
            UIView *subview = rightViewArr[i];
            UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:subview];
            [rightBarItemArr addObject:rightItem];
        }
        self.navigationItem.rightBarButtonItems = rightBarItemArr;
    }
}


-(void)customBackImage:(UIImage *)backImg title:(NSString *)title
{
    UIView *baseView = [UIView customBackImage:backImg title:title target:self action:@selector(onBack:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:baseView];
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)enablePopGesture
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    }
}

-(void)disablePopGesture
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    }
}



@end

//
//  UIView+CommonMethods.m
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import "UIView+CommonMethods.h"
#import "NSString+CalculateSize.h"
#import "UIView+Extension.h"
#import "GlobalHeader.h"

#define kHolderHeight (kECScreenHeight - kNavHeight - kTabbarHeight)
#define kTopInsetGap 40.f
@implementation UIView (CommonMethods)
+ (UIView *)getTableViewHeaderNoDataView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kECScreenWidth, kHolderHeight)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kECScreenWidth - 110)/2,(kHolderHeight - 129)/2.0 - kTopInsetGap, 110, 129)];
    imageView.image = [UIImage imageNamed:@"bg_no_data_hint_new"];
    [view addSubview:imageView];
    view.backgroundColor = kECBackgroundColor;
    return view;
}

+ (UIView *)getTableViewHeaderNoNetworkView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kECScreenWidth, kHolderHeight)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kECScreenWidth -103)/2, (kHolderHeight - 106)/2.f - kTopInsetGap, 103, 106)];
    imageView.image = [UIImage imageNamed:@"bg_no_network_hint_"];
    [view addSubview:imageView];
    view.backgroundColor = kECBackgroundColor;
    return view;
}

+ (UIView *)getTableViewHeaderLoadingView
{
    //  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kECScreenWidth, 60)];
    //  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kECScreenWidth - 270)/2, 5, 270, 50)];
    //  imageView.image = [UIImage imageNamed:@"bg_loading_hint"];
    //  [view addSubview:imageView];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kECScreenWidth, 0.1)];
    return view;
}

+ (UIImageView *)getCellAccessoryDisclosureIndicatorView
{
    UIImageView *accessoryDisclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_user_next2"]];
    accessoryDisclosureIndicator.frame = CGRectMake(kECScreenWidth - 10 - 7.5, 15, 7.5, 14);
    return accessoryDisclosureIndicator;
}

+ (UIView *)customBackImage:(UIImage *)backImg title:(NSString *)title target:(id)target action:(SEL)action
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, 60, 44)];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = 0;
    if (kECScreenWidth > 376)
    {
        x = -5;
    }
    else if (kECScreenWidth > 321)
    {
        x = -2;
    }
    backBtn.frame = CGRectMake(x, 0, 60, 44);
    if (action)
    {
        [backBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (backImg == nil && title.length == 0)
    {
        backImg = [UIImage imageNamed:@"btn_navi_return_title"];
        CGSize size = backImg.size;
        CGFloat scale = size.height/16;
        size.width = size.width/scale;
        size.height = 16;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake((44-size.height)/2, 0, (44-size.height)/2, CGRectGetWidth(backBtn.frame)-size.width)];
    }
    else if (backImg == nil && title.length > 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kECWhiteColor;
        label.backgroundColor = kECClearColor;
        label.numberOfLines = 1;
        label.text = title;
        label.font = [UIFont systemFontOfSize:17];
        CGSize size = [NSString contentAutoSizeWithText:title boundSize:CGSizeMake(MAXFLOAT, 20) font:label.font];
        if (size.width > 80)
        {
            size.width = 80;
        }
        else if (size.width < 20)
        {
            size.width = 20;
        }
        label.width = size.width;
        [baseView addSubview:label];
    }
    else if (backImg && title.length == 0)
    {
        CGSize size = backImg.size;
        CGFloat scale = size.height/15;
        size.width = size.width/scale;
        size.height = 15;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake((44-size.height)/2, 0, (44-size.height)/2, CGRectGetWidth(backBtn.frame)-size.width)];
    }
    else
    {
        CGSize size = backImg.size;
        CGFloat scale = size.height/15;
        size.width = size.width/scale;
        size.height = 15;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake((44-size.height)/2, 0, (44-size.height)/2, CGRectGetWidth(backBtn.frame)-size.width)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(size.width + 5, 0, 48, 44)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kECWhiteColor;
        label.backgroundColor = kECClearColor;
        label.numberOfLines = 1;
        label.text = title;
        label.font = [UIFont systemFontOfSize:17];
        size = [NSString contentAutoSizeWithText:title boundSize:CGSizeMake(MAXFLOAT, 20) font:label.font];
        if (size.width > 80)
        {
            size.width = 80;
        }
        else if (size.width < 20)
        {
            size.width = 20;
        }
        label.width = size.width;
        [baseView addSubview:label];
    }
    if (backImg)
    {
        [backBtn setImage:backImg forState:UIControlStateNormal];
    }
    [baseView addSubview:backBtn];
    return baseView;
}

@end

//
//  HWScrollView.h
//  UIScrollView的循环滚动
//
//  Created by yellowei on 15/12/8.
//  Copyright (c) 2015年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWPageControl.h"

@interface HWAdsScrollView : UIView<UIScrollViewDelegate>


@property (nonatomic, strong) NSMutableArray * imagesArray;
@property (nonatomic, strong) NSMutableArray * urlStringArray;
@property (nonatomic, assign) BOOL repeats;

// 广告当前页index
@property (nonatomic, assign) int currentIndex;


/**
 *  直接加载ViewController上
 *
 *  @param vc             <#vc description#>
 *  @param imageViewArray <#imageViewArray description#>
 *  @param frame          <#frame description#>
 *
 *  @return <#return value description#>
 */
+ (id)hw_scrollViewWithViewController:(UIViewController *)vc andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame;

- (id)initWithViewController:(UIViewController *)vc andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame;

+ (id)hw_scrollViewWithViewController:(UIViewController *)vc andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame;

- (id)initWithViewController:(UIViewController *)vc andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame;

/**
 *  直接加载View上
 *
 *  @param view           <#view description#>
 *  @param imageViewArray <#imageViewArray description#>
 *  @param frame          <#frame description#>
 *
 *  @return <#return value description#>
 */
+ (id)hw_scrollViewWithView:(UIView *)view andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame;

- (id)initWithView:(UIView *)view andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame;

+ (id)hw_scrollViewWithView:(UIView *)view andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame;

- (id)initWithView:(UIView *)view andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame;

@end

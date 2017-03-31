//
//  HWScrollView.h
//  UIScrollView的循环滚动
//
//  Created by yellowei on 15/12/8.
//  Copyright (c) 2015年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HWScrollView;

@protocol HWScrollViewDelegate <NSObject>

@optional
- (void)scrollViewEndedHidden:(HWScrollView *)scrllView isHidden:(BOOL)hidden;

@optional
- (void)scrollviewPageWillChangeNextCurrentIndex:(int)currntIndex nextLeftIndex:(int)leftIndex nextRightIndex:(int)rightIndex;

@end


@interface HWScrollView : UIView<UIScrollViewDelegate>


@property (nonatomic, strong) NSMutableArray * imagesArray;
@property (nonatomic, strong) NSMutableArray * urlStringArray;
@property (nonatomic, strong) NSMutableArray * trueImagesArray;
@property (nonatomic, strong) NSMutableArray * imageDatasArray;
@property (nonatomic, assign) BOOL repeats;

@property (nonatomic, weak) id<HWScrollViewDelegate> delegate;

// 广告当前页index
@property (nonatomic, assign) int currentIndex;



- (void)startWithImageDatasArray:(NSMutableArray *)imageDatasArray andCurrentIndex:(int)currentIndex;
- (void)startWithImagesArray:(NSMutableArray *)imagesArray andCurrentIndex:(int)currentIndex;
- (void)startWithUrlStringArray:(NSMutableArray *)urlStringArray andCurrentIndex:(int)currentIndex;
- (void)startWithTrueImagesArray:(NSMutableArray *)trueImagesArray andCurrentIndex:(int)currentIndex;
/**
 *  直接加载ViewController上
 *
 *  @param vc             vc
 *  @param imageViewArray imageViewArray
 *  @param frame          frame
 *
 *  @return 返回
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

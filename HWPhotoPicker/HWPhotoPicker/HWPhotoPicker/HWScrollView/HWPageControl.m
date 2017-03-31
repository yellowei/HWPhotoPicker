//
//  HWPageControl.m
//  良仓
//
//  Created by yellowei on 15/12/17.
//  Copyright © 2015年 yellowei. All rights reserved.
//

#import "HWPageControl.h"

#define PAGECONTROL_SPACE 5.f
#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define PAGECONTROL_WIDTH (WIDTH-PAGECONTROL_SPACE*(pageCount-1))/pageCount
#define SLIDERWIDTH 25.f //滑块的宽度
#define HEIGHT_TO_BOTTOM 15 // pageControl距离scrollView 的下边距

@implementation HWPageControl

+ (id)hw_pageControlWithView:(UIView *)view andCount:(int)pageCount
{
    return [[self alloc]initWithView:view andCount:pageCount];
}

- (instancetype)initWithView:(UIView *)view andCount:(int)pageCount
{
    if (self = [super initWithFrame:CGRectMake((view.frame.size.width - SLIDERWIDTH * pageCount) / 2, view.frame.size.height - HEIGHT_TO_BOTTOM, SLIDERWIDTH * pageCount, 5)])
    {
        [view addSubview:self];
        
        [self createPageControlWithCount:pageCount];
        
        [view bringSubviewToFront:self];
    }
    return self;
}

- (void)createPageControlWithCount:(int)pageCount
{
    for(int i=0;i<pageCount;i++)
    {
        UIView *baseView = [[UIView alloc] init];
        baseView.frame = CGRectMake((PAGECONTROL_WIDTH+PAGECONTROL_SPACE)*i, 0, PAGECONTROL_WIDTH, HEIGHT);
        baseView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.6];
        baseView.tag = i;
        [self addSubview:baseView];
    }
    [self selectPageWithIndex:0];
}

- (void)selectPageWithIndex:(int)index
{
    for(UIView *baseView in self.subviews)
    {
        baseView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.6];
        if(baseView.tag == index)
        {
            baseView.backgroundColor = [UIColor whiteColor];
        }
    }
}
@end

//
//  HWPageControl.h
//  良仓
//
//  Created by yellowei on 15/12/17.
//  Copyright © 2015年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HWPageControl : UIView

+ (id)hw_pageControlWithView:(UIView *)view andCount:(int)pageCount;
- (void)selectPageWithIndex:(int)index;

@end

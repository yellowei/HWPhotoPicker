//
//  ECShowImageView.h
//  ECDoctor
//
//  Created by linsen on 15/9/11.
//  Copyright (c) 2015年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^saveResultBlock)(NSError *result);
typedef void(^SingleTap)(UITapGestureRecognizer *tap);
typedef void(^sendMessageBlock)(id imageData);
@interface ECShowImageView : UIScrollView<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    UIImageView *imageView;
}
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, strong)id imageData;
@property (nonatomic, copy)saveResultBlock saveResultBlock;
@property (nonatomic, copy)SingleTap singleTap;

- (void)saveImageData;
@end

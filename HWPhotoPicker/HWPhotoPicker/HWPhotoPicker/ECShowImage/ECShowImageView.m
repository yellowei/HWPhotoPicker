//
//  ECShowImageView.m
//  ECDoctor
//
//  Created by linsen on 15/9/11.
//  Copyright (c) 2015年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import "ECShowImageView.h"
#import "HWImageModel.h"
#import "SDWebImageManager.h"
#import "PhotoObj.h"
#import "ImageDataAPI.h"
#import "MBProgressHUD.h"
#import "GlobalHeader.h"
#import "NSString+ECExtensions.h"
#import "GlobalHeader.h"
#import "UIView+Extension.h"

#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)

@interface ECShowImageView()<SDWebImageManagerDelegate>
{
    MBProgressHUD *customerHUD;
}
@property (nonatomic, strong)UIImage *dataImage;
@property (nonatomic, strong)UIActivityIndicatorView *m_activityIndicatorView;
@property (nonatomic, strong)UITapGestureRecognizer *singleTaps;
@property (nonatomic, strong)UILabel *netLabel;

@end;
@implementation ECShowImageView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kECScreenWidth, frame.size.height)];
    //设置放大的倍数
    self.maximumZoomScale = 3.0;
    //设置缩小的倍数
    self.minimumZoomScale = 0.5;
    
    //设置滚动条隐藏
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled=NO;
    self.bouncesZoom=NO;
    //设置代理
    self.delegate = self;
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = YES;
    imageView.userInteractionEnabled = YES;
    [self setClipsToBounds:NO];
    [imageView setClipsToBounds:NO];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:imageView];
    
    
    //设置点击手势来放大和缩小图片
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    
    //   单击移除
    UITapGestureRecognizer * tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTouch:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture requireGestureRecognizerToFail:doubleTap];
    
    [self addGestureRecognizer:tapGesture];
    [imageView addGestureRecognizer: doubleTap];
    _singleTaps = tapGesture;
    self.zoomScale = 0.99f;
    
  }
  return self;
}

- (void)dealloc
{
    DLog(@"ECShowImageView Release!!!");
}

# pragma mark - Private Method

-(void)showCustomWaitingWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    CGFloat width = 180;
    CGFloat height = 120;
    NSString *lab1Text,*lab2Text;
    if (![title isValid]) {
        lab1Text = @"正在努力加载";
    }
    else
    {
        lab1Text = [NSString stringEmptyTransform:title];
    }
    if (![subTitle isValid]) {
        lab2Text = @"请等待...";
    }
    else
    {
        lab2Text = [NSString stringEmptyTransform:subTitle];
    }
    if (!customerHUD) {
        customerHUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
        customerHUD.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        customerHUD.color = [UIColor whiteColor];
        customerHUD.cornerRadius = 4.0f;
        customerHUD.mode = MBProgressHUDModeCustomView;
        customerHUD.removeFromSuperViewOnHide = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:customerHUD];
    }
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    customView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(width/2 - 20, 10, 40, 40)];
    imgView.image = [UIImage imageNamed:@"icon_common_waiting"];
    
    [customView addSubview:imgView];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    [imgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(width/2 - 80, 60, 160, 30)];
    label1.font = [UIFont systemFontOfSize:18.0f];
    label1.text = lab1Text;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = kECGreenColor2;
    [customView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(width/2 - 60, 90, 120, 20)];
    label2.font = [UIFont systemFontOfSize:14.0f];
    label2.text = lab2Text;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = kECBlackColor4;
    [customView addSubview:label2];
    
    customerHUD.customView = customView;
    
    
    [customerHUD show:YES];
}

-(void)showSimpleWaiting
{
    [self showCustomWaitingWithTitle:nil subTitle:nil];
}

//隐藏加载等待
-(void)hideWaiting
{
    if (customerHUD)
    {
        [customerHUD hide:YES];
        customerHUD = nil;
    }
}

# pragma mark - 触发方法

- (void)setImageData:(id)imageData
{
    _imageData = imageData;
    if ([self.imageData isKindOfClass:[NSDictionary class]])
    {
        NSData *data = imageData[@"data"];
        if (data)
        {
            UIImage *tempImage = [UIImage imageWithData:data];
            //tempImage = [tempImage stretchableImageWithLeftCapWidth:kECScreenWidth topCapHeight:kECScreenHeight];
            self.dataImage = tempImage;
            imageView.image = tempImage;
        }
    }
    else if ([self.imageData isKindOfClass:[HWImageModel class]])
    {
        HWImageModel *image = self.imageData;
        ECBlockSet
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[image getThumbnailImageUrlStr]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            ECBlockGet(strongSelf1)
            if (strongSelf1)
            {
                strongSelf1->imageView.image = image;
            }
        }];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[image getImageUrlStr]] options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            ECBlockGet(strongSelf2)
            if (strongSelf2)
            {
                if (image)
                {
                    weakSelf.dataImage = image;
                    strongSelf2->imageView.image = image;
                    [weakSelf setNeedsDisplay];
                    if (weakSelf.m_activityIndicatorView && [weakSelf.m_activityIndicatorView isAnimating])
                    {
                        [weakSelf saveImageData];
                    }
                }
            }
            
            
        }];

        
    }
    else if ([self.imageData isKindOfClass:[NSURL class]])
    {
        NSURL * url = self.imageData;
        if ([url.absoluteString containsString:@"/var/mobile/Containers/"])
        {
            url = [NSURL fileURLWithPath:url.absoluteString];
        }
        ECBlockSet
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            ECBlockGet(strongSelf2)
            if (strongSelf2)
            {
                if (image)
                {
                    weakSelf.dataImage = image;
                    strongSelf2->imageView.image = image;
                    [weakSelf setNeedsDisplay];
                    if (weakSelf.m_activityIndicatorView && [weakSelf.m_activityIndicatorView isAnimating])
                    {
                        [weakSelf saveImageData];
                    }
                }
            }
            
            
        }];
    }
    else if ([imageData isKindOfClass:[UIImage class]])
    {
        UIImage * image = imageData;
        if (image)
        {
            //tempImage = [tempImage stretchableImageWithLeftCapWidth:kECScreenWidth topCapHeight:kECScreenHeight];
            self.dataImage = image;
            imageView.image = image;
        }
    }
    else if ([imageData isKindOfClass:[PhotoObj class]])
    {
        ECBlockSet
        [[ImageDataAPI sharedInstance] getImageForPhotoObj:[imageData photoObj] withSize:(IS_IOS_8? PHImageManagerMaximumSize:CGSizeZero) completion:^(BOOL ret, UIImage *image) {
            
            ECBlockGet(strongSelf1)
            if (strongSelf1)
            {
                strongSelf1.dataImage = image;
                strongSelf1->imageView.image = image;
            }
        }];
        
    }

}

- (void)saveImageData
{
    if (self.dataImage)
    {
        UIImageWriteToSavedPhotosAlbum(self.dataImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        if (self.m_activityIndicatorView)
        {
            [self.m_activityIndicatorView stopAnimating];
            self.m_activityIndicatorView.hidden = YES;
        }
    }
    else
    {
        if (self.m_activityIndicatorView == nil)
        {
            self.m_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            CGSize size = self.m_activityIndicatorView.frame.size;
            self.m_activityIndicatorView.frame = CGRectMake((CGRectGetWidth(self.frame)-size.width)/2, (CGRectGetHeight(self.frame)-size.height)/2, size.width, size.height);
            self.m_activityIndicatorView.hidden = YES;
            [self addSubview:self.m_activityIndicatorView];
        }
        self.m_activityIndicatorView.hidden = NO;
        [self.m_activityIndicatorView startAnimating];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (_saveResultBlock)
    {
        _saveResultBlock(error);
    }
}
//该协议方法返回一个放大或者缩小之后的视图
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;

}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
//    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
//    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
//    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
//    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
//    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
//                                   scrollView.contentSize.height * 0.5 + offsetY);

    CGFloat Ws = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right;
    CGFloat Hs = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom;
    CGFloat W = imageView.frame.size.width;
    CGFloat H = imageView.frame.size.height;
    
    CGRect rct = imageView.frame;
    
    rct.origin.x = MAX((Ws-W)*0.5, 0);
    rct.origin.y = MAX((Hs-H)*0.5, 0);
    imageView.frame = rct;
    


}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGRect rct = imageView.frame;
    if (self.zoomScale == 1)
    {
        scrollView.zoomScale = 0.99f;
    }
    if (rct.size.width < kECScreenWidth - 8)
    {
        
        [UIView animateWithDuration:0.35f animations:^{
            scrollView.zoomScale = 0.99f;
        }];
    }
    else if (rct.size.height < kECScreenWidth - 8)
    {
        [UIView animateWithDuration:0.35f animations:^{
            scrollView.zoomScale = 0.99f;
        }];
    }
}

-(void)onTouch:(UITapGestureRecognizer *)tap
{
  if (_singleTap) {
    _singleTap(tap);
  }
}

//点击手势响应
-(void)tapAction:(UITapGestureRecognizer *)tap
{
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onTouch:) object:_singleTaps];
  
    CGPoint point = [tap locationInView:[tap view]];
    [self zoomToPoint:point];
}


//覆写设置器方法
-(void)setImage:(UIImage *)image{
    if (image !=_image) {
        _image = image;
    }
    imageView.image = image;
}

-(void)showToastWithMessage:(NSString *)message
{
    [self _loadNetViewWithText:message];
    if (_netLabel.alpha == 0.0) {
        _netLabel.alpha = 1.0;
        ECBlockSet
        [UIView animateWithDuration:2.0 animations:^{
          ECBlockGet(strongSelf)
          if (strongSelf)
          {
            strongSelf.netLabel.alpha = 0.0;
          }
        }];
    }
}

- (void)_loadNetViewWithText:(NSString *)text
{
    if (!text) {
        return;
    }
    if (!_netLabel) {
        _netLabel = [[UILabel alloc] initWithFrame:CGRectMake(kECScreenWidth/4.0, kECScreenHeight - 100, kECScreenWidth/2.0, 44)];
        _netLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        _netLabel.layer.cornerRadius = 4.0;
        _netLabel.layer.masksToBounds = YES;
        _netLabel.alpha = 0.0;
        _netLabel.textAlignment = NSTextAlignmentCenter;
        _netLabel.numberOfLines = 0;
        _netLabel.textColor = [UIColor whiteColor];
        _netLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_netLabel];
    }
     _netLabel.text = text;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:_netLabel.font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGFloat width =  [_netLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width+10;
    if (width > kECScreenWidth) {
        width = kECScreenWidth - 40;
    }
    _netLabel.width = width;
    _netLabel.center = CGPointMake(kECScreenWidth/2.0, _netLabel.center.y);
}
#pragma mark - SDWebImageManagerDelegate
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if (image)
    {
        self.dataImage = image;
        imageView.image = image;
        [self setNeedsDisplay];
        if (self.m_activityIndicatorView && [self.m_activityIndicatorView isAnimating])
        {
            [self saveImageData];
        }
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error
{
  [self showToastWithMessage:@"图片加载失败"];
}

- (void)zoomToPoint:(CGPoint)point
{
  
    CGRect zoomRect = self.isZoomed ? [self bounds] : [self zoomRectForScale:self.maximumZoomScale withCenter:point];
    
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
  CGRect zoomRect = self.frame;
  
  zoomRect.size.height /= scale;
  zoomRect.size.width /= scale;
  
  //the origin of a rect is it's top left corner,
  //so subtract half the width and height of the rect from it's center point to get to that x,y
  zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
  zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
  
  return zoomRect;
}

- (BOOL)isZoomed
{
  return ((self.zoomScale == 0.99f) ? NO : YES);
}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//  if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]&&[otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//    if (gestureRecognizer.numberOfTouches == 2) {
//      return NO;
//    }
//    return YES;
//  }
//  return NO;
//}

@end

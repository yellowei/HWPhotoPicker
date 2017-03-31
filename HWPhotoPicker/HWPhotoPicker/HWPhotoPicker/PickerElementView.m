//
//  PickerElementView.m
//  ThinkMail_iOS
//
//  Created by chen ling on 2/11/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import "PickerElementView.h"
#import "VedioElementInfoView.h"
#import "PhotoObj.h"
#import "ImageDataAPI.h"
#import "UIView+Extension.h"
#import "GlobalHeader.h"

@interface PickerElementView()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *overlayImageView;

@property (nonatomic, retain) VedioElementInfoView *videoInfoView;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *tintedThumbnailImage;


@end

@implementation PickerElementView
{
    
}
@synthesize delegate = _delegate;
@synthesize selected = _selected;
@synthesize videoInfoView = _videoInfoView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       // self.backgroundColor = [UIColor colorWithLongHex:0xFF];
         self.backgroundColor = [UIColor clearColor];
      
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:imageView];
        self.imageView = imageView;
        
        VedioElementInfoView *videoInfoView = [[VedioElementInfoView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 17, self.bounds.size.width, 17)];
        videoInfoView.hidden = YES;
        videoInfoView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:videoInfoView];
        self.videoInfoView = videoInfoView;
        
        
        // Overlay Image View
        UIButton *overlayImageView = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 25, 0, 25, 25)];
        overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [overlayImageView setBackgroundImage:[UIImage imageNamed:@"photopicker_nor"] forState:UIControlStateNormal];
        [overlayImageView setBackgroundImage:[UIImage imageNamed:@"photopicker_sel"] forState:UIControlStateSelected];
        overlayImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        overlayImageView.clipsToBounds = YES;
        [overlayImageView addTarget:self action:@selector(onSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:overlayImageView];
        self.overlayImageView = overlayImageView;
        
        UITapGestureRecognizer * selfTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelfClick:)];
        [self addGestureRecognizer:selfTap];

    }
    return self;
}

- (void)dealloc
{
    DLog(@"PickerElementView Release!!");
}

#pragma mark - getter and setter
- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    // mutil select
    if (self.allowsMultipleSelection)
    {
        self.overlayImageView.hidden = NO;
    }
    else
    {
        self.overlayImageView.hidden = YES;
    }
}

- (void)setElement:(PhotoObj *)element_//(ALAsset *)element_
{
    if (_element != element_) {
        _element = element_;
//      [self thumbnail];
    }
    _element = element_;
    [self thumbnail];
    /*
    if([_element valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo)
    {
        double duration = [[_element valueForProperty:ALAssetPropertyDuration] doubleValue];
        
        self.videoInfoView.hidden = NO;
        self.videoInfoView.duration = round(duration);
    }
    else
    {
        self.videoInfoView.hidden = YES;
    }
     */
}

- (void)setSelected:(BOOL)selected
{
    self.overlayImageView.selected = selected;
}

- (BOOL)selected
{
    return self.overlayImageView.selected;
}

#pragma mark - private method
- (void)thumbnail
{
  self.imageView.image = nil;
  self.imageView.backgroundColor = [UIColor grayColor];
//  if (self.thumbnailImage != nil)
//  {
//    self.imageView.image = self.thumbnailImage;
//  }
//  else
//  {
    ECBlockSet
    [[ImageDataAPI sharedInstance] getThumbnailForAssetObj:[self.element photoObj]  withSize:CGSizeMake(180, 180)  completion:^(BOOL ret, UIImage *image) {
        ECBlockGet(strongSelf1)
        if (strongSelf1)
        {
            strongSelf1.imageView.image = image;
            strongSelf1.thumbnailImage = image;
        }
      
    }];
//  }
}

- (UIImage *)tintedThumbnail
{
  if (self.tintedThumbnailImage)
  {
    return self.tintedThumbnailImage;
  }
  else
  {
    UIImage *thumbnail = self.thumbnailImage;
    
    UIGraphicsBeginImageContext(thumbnail.size);
    
    CGRect rect = CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height);
    [thumbnail drawInRect:rect];
    
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceAtop);
    
    UIImage *tintedThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.tintedThumbnailImage = tintedThumbnail;
    return tintedThumbnail;
  }
}


#pragma mark - touch event
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//  if(!self.allowsMultipleSelection)
//  {
//    self.imageView.image = [self tintedThumbnail];
//  }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//  if (!self.allowsMultipleSelection)
//  {
//    [self thumbnail];
//    [self.delegate elementView:self didChangeSeletionState:self.selected];
//  }
//    
////  else if (self.selected)
////  {
////    self.selected = NO;
////    [self.delegate elementView:self didChangeSeletionState:self.selected];
////  }
////  else
////  {
////    if([self.delegate elementViewCanBeSeleted:self])
////    {
////      self.selected = !self.selected;
////      [self.delegate elementView:self didChangeSeletionState:self.selected];
////    }
////  }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self thumbnail];
//}
- (void)onSelfClick:(UITapGestureRecognizer *)tap
{
    if (!self.allowsMultipleSelection)
    {
        self.imageView.image = [self tintedThumbnail];
        [self thumbnail];
        [self.delegate elementView:self didChangeSeletionState:self.selected];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(elementViewShowBigImage:)])
        {
            [self.delegate elementViewShowBigImage:self];
        }
    }
}

# pragma mark - 对勾手势
- (void)onSelectedClick:(UIButton *)btn
{
    if (self.selected)
    {
        self.selected = NO;
        [self.delegate elementView:self didChangeSeletionState:self.selected];
    }
    else
    {
        if([self.delegate elementViewCanBeSeleted:self])
        {
            self.selected = YES;
            [self.delegate elementView:self didChangeSeletionState:self.selected];
        }
    }
}



@end

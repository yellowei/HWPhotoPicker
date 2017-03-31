//
//  HWScrollView.m
//  UIScrollView的循环滚动
//
//  Created by yellowei on 15/12/8.
//  Copyright (c) 2015年 yellowei. All rights reserved.
//

#import "HWScrollView.h"
#import "UIImageView+WebCache.h"
#import "ECShowImageView.h"
#import "PhotoObj.h"
#import "GlobalHeader.h"

#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

#define SELFWIDTH self.bounds.size.width
#define SELFHEIGHT self.bounds.size.height
#define SELFX self.frame.origin.x
#define SELFY self.frame.origin.y

//#define SCALE [UIScreen mainScreen].bounds.size.width /
#define SCALE 1

@interface HWScrollView ()
{
    NSTimer * _timer;
    NSInteger _scrollCurrentIndex;
    
    int c_page;
    int l_page;
    int r_page;
}


@property (nonatomic, strong) UIImage * currentImage;
@property (nonatomic, strong) UIImage * leftImage;
@property (nonatomic, strong) UIImage * rightImage;

@end

@implementation HWScrollView
{
    UIScrollView *_mainScrollView;
     
    //
    int _count;
    
}


#pragma mark - 直接用于ViewController
+ (id)hw_scrollViewWithViewController:(UIViewController *)vc andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame
{
    
    return [[self alloc] initWithViewController:vc andImageNameArray:imageNameArray andFrame:frame];
}

- (id)initWithViewController:(UIViewController *)vc andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame
{
    
    if (vc)
    {
        if (!vc.navigationController)
        {
            self = [self initWithFrame:frame];
            
//            [self getImageNames];
            self.imagesArray = imageNameArray;
            
            
            
            [vc.view addSubview:self];
        }
        else
        {
            self = [self initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height - 64)];
            vc.automaticallyAdjustsScrollViewInsets = NO;
            
//            [self getImageNames];
            self.imagesArray = imageNameArray;
            
            [vc.view addSubview:self];
        }
        
    }
    return self;
}

+ (id)hw_scrollViewWithViewController:(UIViewController *)vc andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame
{
    
    return [[self alloc] initWithViewController:vc andUrlStringArray:urlStringArray andFrame:frame];
}

- (id)initWithViewController:(UIViewController *)vc andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame
{
    
    if (vc)
    {
        if (!vc.navigationController)
        {
            self = [self initWithFrame:frame];
            
            //            [self getImageNames];
            self.urlStringArray = urlStringArray;
            
            
            [vc.view addSubview:self];
        }
        else
        {
            self = [self initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height - 64)];
            vc.automaticallyAdjustsScrollViewInsets = NO;
            
            //            [self getImageNames];
            self.urlStringArray = urlStringArray;
            
            [vc.view addSubview:self];
        }
        
    }
    return self;
}


# pragma mark - 直接加在View上
+ (id)hw_scrollViewWithView:(UIView *)view andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame
{
    return [[self alloc] initWithView:view andImageNameArray:imageNameArray andFrame:frame];
}

- (id)initWithView:(UIView *)view andImageNameArray:(NSMutableArray *)imageNameArray andFrame:(CGRect)frame
{
    if (view)
    {
        self = [self initWithFrame:frame];
        
        self.imagesArray = (NSMutableArray *)imageNameArray;
        
        [view addSubview:self];
        
    }
    return self;
}


+ (id)hw_scrollViewWithView:(UIView *)view andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame
{
    return [[self alloc] initWithView:view andUrlStringArray:urlStringArray andFrame:frame];
}

- (id)initWithView:(UIView *)view andUrlStringArray:(NSMutableArray *)urlStringArray andFrame:(CGRect)frame
{
    if (view)
    {
        self = [self initWithFrame:frame];
        
        self.urlStringArray = urlStringArray;
        
        [view addSubview:self];
    }
    return self;
}


- (void)didMoveToSuperview
{

}

# pragma mark - 私有方法

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:frame];
        
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        
        _mainScrollView.contentSize = CGSizeMake(SELFWIDTH*3, SELFHEIGHT);
        
        _mainScrollView.bounces = NO;
        
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:_mainScrollView];
        
        c_page = 0;
        l_page = 0;
        r_page = 0;
        _scrollCurrentIndex = 1;
    }
    return self;
}

- (void)getImageNames
{
    //1.获取imageName字典
//    NSString * path = [NSString stringWithFormat:@"%@/ImagesForView.plist",[[NSBundle mainBundle] resourcePath]];
    
    NSString * path = [[NSBundle mainBundle] pathForResource:@"ImagesForView" ofType:@"plist"];
    
    NSDictionary * imageNames = [[NSDictionary alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
    
    //2.取出所有的image的名称
    NSArray * imageNamesArray = [imageNames allValues];
    
    self.imagesArray = imageNamesArray[0];
    
    
}


# pragma mark - PhotoObj Images

- (void)startWithImageDatasArray:(NSMutableArray *)imageDatasArray andCurrentIndex:(int)currentIndex
{
    self.imageDatasArray = imageDatasArray;
    
    _count = (int)imageDatasArray.count;
    
    c_page = currentIndex;
    l_page = c_page-1<0?(int)(_imageDatasArray.count - 1):(c_page-1);
    r_page = c_page+1<_imageDatasArray.count?(c_page+1):0;
    
    self.alpha = 0.0f;//动画效果
    
    if (self.imageDatasArray.count == 1 || !self.imageDatasArray.count)
    {
        _mainScrollView.scrollEnabled = NO;
    }
    else
    {
        _mainScrollView.scrollEnabled = YES;
    }
    
    [self loadImageDatasPage];
    
}

- (void)loadImageDatasPage
{
    
    for(UIView *view in _mainScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    _scrollCurrentIndex = 1;
    
    //CurrentPage
    ECShowImageView *currentImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
    [currentImageView setImageData:[_imageDatasArray objectAtIndex:c_page]];
    __weak typeof (&*self)weakSelf = self;
    currentImageView.singleTap = ^(UITapGestureRecognizer *tgr){
        __strong __typeof(&*self)strongSelf = weakSelf;
        [UIView animateWithDuration:0.25f animations:^{
//            strongSelf.alpha = 0.0f;
            [strongSelf.delegate scrollViewEndedHidden:strongSelf isHidden:YES];
        }];
    };
    [_mainScrollView addSubview:currentImageView];
    
    //LeftPage
    ECShowImageView *leftImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [leftImageView setImageData:[_imageDatasArray objectAtIndex:l_page]];
    [_mainScrollView addSubview:leftImageView];
    
    //RightPage
    ECShowImageView *rightImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(WIDTH*2, 0, WIDTH, HEIGHT)];
    [rightImageView setImageData:[_imageDatasArray objectAtIndex:r_page]];
    [_mainScrollView addSubview:rightImageView];
    
    [_mainScrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    
    
    
}

# pragma mark - TrueImages

- (void)startWithTrueImagesArray:(NSMutableArray *)trueImagesArray andCurrentIndex:(int)currentIndex
{
    self.trueImagesArray = trueImagesArray;
    
    _count = (int)trueImagesArray.count;
    c_page = currentIndex;
    l_page = c_page-1<0?(int)(_trueImagesArray.count - 1):(c_page-1);
    r_page = c_page+1<_trueImagesArray.count?(c_page+1):0;
    self.alpha = 0.0f;//动画效果
    
    if (self.trueImagesArray.count == 1 || !self.trueImagesArray.count)
    {
        _mainScrollView.scrollEnabled = NO;
    }
    else
    {
        _mainScrollView.scrollEnabled = YES;
    }
    
    [self loadTrueImagePage];
}

- (void)loadTrueImagePage
{
    
    for(UIView *view in _mainScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    _scrollCurrentIndex = 1;
    ECShowImageView *currentImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
    [currentImageView setImageData:[_trueImagesArray objectAtIndex:c_page]];
    __weak typeof (&*self)weakSelf = self;
    currentImageView.singleTap = ^(UITapGestureRecognizer *tgr){
        __strong __typeof(&*self)strongSelf = weakSelf;
        [UIView animateWithDuration:0.25f animations:^{
            strongSelf.alpha = 0.0f;
            [strongSelf.delegate scrollViewEndedHidden:strongSelf isHidden:YES];
        }];
    };
    [_mainScrollView addSubview:currentImageView];
    
    ECShowImageView *leftImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [leftImageView setImageData:[_trueImagesArray objectAtIndex:l_page]];
    [_mainScrollView addSubview:leftImageView];
    
    ECShowImageView *rightImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(WIDTH*2, 0, WIDTH, HEIGHT)];
    [rightImageView setImageData:[_trueImagesArray objectAtIndex:r_page]];
    [_mainScrollView addSubview:rightImageView];
    
    [_mainScrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    
}

# pragma mark - URL Images

- (void)startWithUrlStringArray:(NSMutableArray *)urlStringArray andCurrentIndex:(int)currentIndex
{
    
    self.urlStringArray = urlStringArray;
    _count = (int)urlStringArray.count;
    c_page = currentIndex;
    l_page = c_page-1<0?(int)(_urlStringArray.count - 1):(c_page-1);
    r_page = c_page+1<_urlStringArray.count?(c_page+1):0;
    self.alpha = 0.0f;//动画效果
    
    if (self.urlStringArray.count == 1 || !self.urlStringArray.count)
    {
        _mainScrollView.scrollEnabled = NO;
    }
    else
    {
        _mainScrollView.scrollEnabled = YES;
    }
    
    [self loadUrlPage];
    
    //        _pageControl = [HWPageControl hw_pageControlWithView:self andCount:_urlStringArray.count > 0 ? (int)_urlStringArray.count : (int)_imagesArray.count];
}

- (void)loadUrlPage
{
    
    for(UIView *view in _mainScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    _scrollCurrentIndex = 1;
    ECShowImageView *currentImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(WIDTH, 0, WIDTH, HEIGHT)];
    [currentImageView setImageData:[NSURL URLWithString:[_urlStringArray objectAtIndex:c_page]]];
    __weak typeof (&*self)weakSelf = self;
    currentImageView.singleTap = ^(UITapGestureRecognizer *tgr){
        __strong __typeof(&*self)strongSelf = weakSelf;
        [UIView animateWithDuration:0.25f animations:^{
            strongSelf.alpha = 0.0f;
            [strongSelf.delegate scrollViewEndedHidden:strongSelf isHidden:YES];
        }];
    };
    [_mainScrollView addSubview:currentImageView];
    
    ECShowImageView *leftImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [leftImageView setImageData:[NSURL URLWithString:[_urlStringArray objectAtIndex:l_page]]];
    [_mainScrollView addSubview:leftImageView];
    
    ECShowImageView *rightImageView = [[ECShowImageView alloc] initWithFrame:CGRectMake(WIDTH*2, 0, WIDTH, HEIGHT)];
    [rightImageView setImageData:[NSURL URLWithString:[_urlStringArray objectAtIndex:r_page]]];
    [_mainScrollView addSubview:rightImageView];
    
    [_mainScrollView setContentOffset:CGPointMake(self.frame.size.width, 0)];
    
}

# pragma mark - Image Names

- (void)startWithImagesArray:(NSMutableArray *)imagesArray andCurrentIndex:(int)currentIndex
{
    self.imagesArray = imagesArray;
    _count = (int)imagesArray.count;
    c_page = currentIndex;
    l_page = c_page-1<0?(int)(-imagesArray.count - 1):(c_page-1);
    r_page = c_page+1<_imagesArray.count?(c_page+1):0;
    
    if (self.imagesArray.count == 1 || !self.imagesArray.count)
    {
        _mainScrollView.scrollEnabled = NO;
    }
    else
    {
        _mainScrollView.scrollEnabled = YES;
    }
    
    [self loadPage];
    
    //        _pageControl = [HWPageControl hw_pageControlWithView:self andCount:_urlStringArray.count > 0 ? (int)_urlStringArray.count : (int)_imagesArray.count];
}

- (void)loadPage
{
    // 1.移除老三页
    for(UIView *view in _mainScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    if (_leftImage) {
        _leftImage = nil;
    }
    
    if (_currentImage) {
        _currentImage = nil;
    }
    
    if (_rightImage) {
        _rightImage = nil;
    }
    
    _scrollCurrentIndex = 1;
    // 2.加载新三页
    // 当前页
//    _currentImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], [_imagesArray objectAtIndex:c_page]]];
  _currentImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imagesArray objectAtIndex:c_page]]];
    
    UIImageView *currentImageView = [[UIImageView alloc] initWithImage:_currentImage];
    currentImageView.frame = CGRectMake(SELFWIDTH, 0, SELFWIDTH, SELFHEIGHT);
    [_mainScrollView addSubview:currentImageView];
    
    
    // 左侧页
//    _leftImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], c_page-1<0?[_imagesArray lastObject]:[_imagesArray objectAtIndex:c_page-1]]];
  _leftImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imagesArray objectAtIndex:l_page]]];
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:_leftImage];
    leftImageView.frame = CGRectMake(0, 0, SELFWIDTH, SELFHEIGHT);
    [_mainScrollView addSubview:leftImageView];
    
    // 右侧页
//    _rightImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], c_page+1<[_imagesArray count]? [_imagesArray objectAtIndex:c_page+1]:[_imagesArray firstObject]]];
  _rightImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imagesArray objectAtIndex:r_page]]];
  
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:_rightImage];
    rightImageView.frame = CGRectMake(SELFWIDTH*2, 0, SELFWIDTH, SELFHEIGHT);
    [_mainScrollView addSubview:rightImageView];
    
    // 3.scrollView偏移的中间
    [_mainScrollView setContentOffset:CGPointMake(SELFWIDTH, 0)];
    
}

- (void)setRepeats:(BOOL)repeats
{
    _repeats = repeats;
    
    if (_repeats)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
        // 当前线程循环不结束
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}


# pragma mark - 定时器轮播
- (void)timeTick
{
    [UIView animateWithDuration:1 animations:^{
        [_mainScrollView setContentOffset:CGPointMake(self.frame.size.width * 2, 0) animated:NO];
    } completion:^(BOOL finished) {
        c_page = c_page+1 < _count ? c_page+1:0;
        [self loadUrlPage];
//        [_pageControl selectPageWithIndex:c_page];
    }];
}


# pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat currentPageTmp = scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    
    __block int currentPage = (int)(currentPageTmp + 0.4 );

    DLog(@"%zd", currentPage);

    if (_scrollCurrentIndex != currentPage)
    {
        //这个变量用来判断页码是否改变
        int delta = currentPage - _scrollCurrentIndex;
        _scrollCurrentIndex = currentPage;
        
        
        if (_urlStringArray)
        {
            if(delta < 0)
            {
                c_page = c_page-1<0?(int)(_urlStringArray.count - 1):c_page-1;
                l_page = c_page-1<0?(int)(_urlStringArray.count - 1):(c_page-1);
                r_page = c_page+1<_urlStringArray.count?(c_page+1):0;
          
                
            }
            else
            {
                c_page = c_page+1<_urlStringArray.count?c_page+1:0;
                l_page = c_page-1<0?(int)(_urlStringArray.count - 1):(c_page-1);
                r_page = c_page+1<_urlStringArray.count?(c_page+1):0;
            }
        }
        else if (_imagesArray)
        {
            if(delta < 0)
            {
                // 左翻
                c_page = c_page-1<0?(int)_imagesArray.count - 1:c_page-1;
                l_page = c_page-1<0?(int)(_imagesArray.count - 1):(c_page-1);
                r_page = c_page+1<_imagesArray.count?(c_page+1):0;
            }
            else
            {
                // 右翻
                c_page = c_page+1 == _imagesArray.count?0:c_page+1;
                l_page = c_page-1<0?(int)(_imagesArray.count - 1):(c_page-1);
                r_page = c_page+1<_imagesArray.count?(c_page+1):0;
            }
        }
        else if (_imageDatasArray)
        {
            if(delta < 0)
            {
                c_page = c_page-1<0?(int)(_imageDatasArray.count - 1):c_page-1;
                l_page = c_page-1<0?(int)(_imageDatasArray.count - 1):(c_page-1);
                r_page = c_page+1<_imageDatasArray.count?(c_page+1):0;
                
            }
            else
            {
                c_page = c_page+1<_imageDatasArray.count?c_page+1:0;
                l_page = c_page-1<0?(int)(_imageDatasArray.count - 1):(c_page-1);
                r_page = c_page+1<_imageDatasArray.count?(c_page+1):0;
            }
            
        }
        
        if ([self.delegate respondsToSelector:@selector(scrollviewPageWillChangeNextCurrentIndex:nextLeftIndex:nextRightIndex:)])
        {
            [self.delegate scrollviewPageWillChangeNextCurrentIndex:c_page nextLeftIndex:l_page nextRightIndex:r_page];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (_urlStringArray)
    {
        [self loadUrlPage];
    }
    else if (_imagesArray)
    {
        [self loadPage];
    }
    else if (_imageDatasArray)
    {
        [self loadImageDatasPage];
    }
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
    _delegate = nil;
}

@end

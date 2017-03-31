//
//  HWScrollView.m
//  UIScrollView的循环滚动
//
//  Created by yellowei on 15/12/8.
//  Copyright (c) 2015年 yellowei. All rights reserved.
//

#import "HWAdsScrollView.h"
#import "UIImageView+WebCache.h"
#import "GlobalHeader.h"



#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define HEIGHT [[UIScreen mainScreen] bounds].size.height

#define MAIN_SCROLLVIEW_HEIGHT 150 //主滚动视图的高

#define SELFWIDTH self.bounds.size.width
#define SELFHEIGHT self.bounds.size.height
#define SELFX self.frame.origin.x
#define SELFY self.frame.origin.y

#define SCALE [UIScreen mainScreen].bounds.size.width / 414

@interface HWAdsScrollView ()


@property (nonatomic, strong) UIImage * currentImage;
@property (nonatomic, strong) UIImage * leftImage;
@property (nonatomic, strong) UIImage * rightImage;

@end

@implementation HWAdsScrollView
{
    UIScrollView *_mainScrollView;
     
    //
    int _count;
    
    NSTimer * _timer;
    NSTimer * _timerMaker;
    
    HWPageControl * _pageControl;
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
    [super didMoveToSuperview];
    

}

# pragma mark - 私有方法
- (void)awakeFromNib
{
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, WIDTH, MAIN_SCROLLVIEW_HEIGHT)];
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, MAIN_SCROLLVIEW_HEIGHT)];
    
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.delegate = self;
    
    _mainScrollView.contentSize = CGSizeMake(WIDTH*3, MAIN_SCROLLVIEW_HEIGHT);
    
    _mainScrollView.bounces = NO;
    
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    
    [self addSubview:_mainScrollView];
    
    
    
    _currentIndex = 0;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
        
        _mainScrollView.contentSize = CGSizeMake(WIDTH*3, SELFHEIGHT);
        
        _mainScrollView.bounces = NO;
        
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:_mainScrollView];
        
        
        
        _currentIndex = 0;
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


- (void)setImagesArray:(NSMutableArray *)imagesArray
{
    _imagesArray = imagesArray;
    _count = (int)imagesArray.count;
    
    [self loadPage];
    
        _pageControl = [HWPageControl hw_pageControlWithView:self andCount:_urlStringArray.count > 0 ? (int)_urlStringArray.count : (int)_imagesArray.count];
}


- (void)setUrlStringArray:(NSMutableArray *)urlStringArray
{
    _urlStringArray = urlStringArray;
    _count = (int)urlStringArray.count;
    
    [self loadUrlPage];
    
    if (!_pageControl)
    {
        _pageControl = [HWPageControl hw_pageControlWithView:self andCount:_urlStringArray.count > 0 ? (int)_urlStringArray.count : (int)_imagesArray.count];
    }
    
}

- (void)loadUrlPage
{
    for(UIView *view in _mainScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIImageView *currentImageView = [[UIImageView alloc] init];
    currentImageView.frame = CGRectMake(SELFWIDTH, 0, SELFWIDTH, SELFHEIGHT);
    [currentImageView setImageWithURL:[NSURL URLWithString:[_urlStringArray objectAtIndex:_currentIndex]]];
    [_mainScrollView addSubview:currentImageView];
    
    //左一
    UIImageView *leftImageView = [[UIImageView alloc] init];
    leftImageView.frame = CGRectMake(0, 0, SELFWIDTH, SELFHEIGHT);
    [leftImageView setImageWithURL:[NSURL URLWithString:_currentIndex-1<0?[_urlStringArray lastObject]:[_urlStringArray objectAtIndex:_currentIndex-1]]];
    [_mainScrollView addSubview:leftImageView];
    
    //左二
    UIImageView *leftImageView2 = [[UIImageView alloc] init];
    leftImageView2.frame = CGRectMake(- SELFWIDTH, 0, SELFWIDTH, SELFHEIGHT);
    [leftImageView2 setImageWithURL:[NSURL URLWithString:_currentIndex-2<0?[_urlStringArray objectAtIndex:_urlStringArray.count-2]:[_urlStringArray objectAtIndex:_currentIndex-2]]];
    [_mainScrollView addSubview:leftImageView2];
    
    //右一
    UIImageView *rightImageView = [[UIImageView alloc] init];
    rightImageView.frame = CGRectMake(SELFWIDTH * 2, 0, SELFWIDTH, SELFHEIGHT);
    [rightImageView setImageWithURL:[NSURL URLWithString:_currentIndex+1<_urlStringArray.count?[_urlStringArray objectAtIndex:_currentIndex+1]:[_urlStringArray firstObject]]];
    [_mainScrollView addSubview:rightImageView];
    
    //右二
    UIImageView *rightImageView2 = [[UIImageView alloc] init];
    rightImageView2.frame = CGRectMake(SELFWIDTH * 3, 0, SELFWIDTH, SELFHEIGHT);
    [rightImageView2 setImageWithURL:[NSURL URLWithString:_currentIndex+2<_urlStringArray.count?[_urlStringArray objectAtIndex:_currentIndex+2]:[_urlStringArray objectAtIndex:_urlStringArray.count - _currentIndex]]];
    [_mainScrollView addSubview:rightImageView2];
    
    [_mainScrollView setContentOffset:CGPointMake(SELFWIDTH, 0)];
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
    
    
    // 2.加载新三页
    // 当前页
    _currentImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], [_imagesArray objectAtIndex:_currentIndex]]];
    
    
    UIImageView *currentImageView = [[UIImageView alloc] initWithImage:_currentImage];
    currentImageView.frame = CGRectMake(SELFWIDTH, 0, SELFWIDTH, SELFHEIGHT);
    [_mainScrollView addSubview:currentImageView];
    
    
    // 左侧页
    _leftImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], _currentIndex-1<0?[_imagesArray lastObject]:[_imagesArray objectAtIndex:_currentIndex-1]]];
    
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:_leftImage];
    leftImageView.frame = CGRectMake(0, 0, SELFWIDTH, SELFHEIGHT);
    [_mainScrollView addSubview:leftImageView];
    
    // 右侧页
    _rightImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], _currentIndex+1<[_imagesArray count]? [_imagesArray objectAtIndex:_currentIndex+1]:[_imagesArray firstObject]]];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithImage:_rightImage];
    rightImageView.frame = CGRectMake(SELFWIDTH*2, 0, SELFWIDTH, SELFHEIGHT);
    [_mainScrollView addSubview:rightImageView];
    
    // 3.scrollView偏移的中间
    [_mainScrollView setContentOffset:CGPointMake(SELFWIDTH, 0)];
    
}

- (void)setRepeats:(BOOL)repeats
{
    _repeats = repeats;
    
    if (_repeats  && !_timerMaker)
    {
        _timerMaker = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(timerMaking:) userInfo:nil repeats:YES];
        // 当前线程循环不结束
        [[NSRunLoop mainRunLoop] addTimer:_timerMaker forMode:NSRunLoopCommonModes];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
        // 当前线程循环不结束
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}


# pragma mark - 定时器轮播
- (void)timerMaking:(id)sender
{
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
        // 当前线程循环不结束
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)timeTick:(id)sender
{   ECBlockSet
    [UIView animateWithDuration:0.75f animations:^{
        ECBlockGet(strongSelf)
        [strongSelf->_mainScrollView setContentOffset:CGPointMake(strongSelf.frame.size.width * 2, 0) animated:NO];
    } completion:^(BOOL finished) {
        ECBlockGet(strongSelf)
        strongSelf->_currentIndex = strongSelf->_currentIndex+1 < strongSelf->_count ? strongSelf->_currentIndex+1:0;
        [strongSelf loadUrlPage];
        [strongSelf->_pageControl selectPageWithIndex:strongSelf->_currentIndex];
    }];
}


# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if (_urlStringArray)
    {
        if (_timer)
        {
            [_timer invalidate];
            _timer = nil;
        }
        int index = scrollView.contentOffset.x/self.frame.size.width;
        if(index == 0)
            _currentIndex = _currentIndex-1<0?(int)(_urlStringArray.count - 1):_currentIndex-1;
        if(index == 2)
            _currentIndex = _currentIndex+1<_urlStringArray.count?_currentIndex+1:0;
        [self loadUrlPage];
        
        ECBlockSet
        dispatch_async(dispatch_get_main_queue(), ^{
            ECBlockGet(strongSelf)
            [strongSelf->_pageControl selectPageWithIndex:strongSelf->_currentIndex];
            
        });
        
    }
    else if (_imagesArray)
    {
        [_timer invalidate];
        _timer = nil;
        int index = scrollView.contentOffset.x/SELFWIDTH;
        if(index == 0)
        {
            // 左翻
            _currentIndex = _currentIndex-1<0?(int)_imagesArray.count - 1:_currentIndex-1;
        }
        if(index == 2)
        {
            // 右翻
            _currentIndex = _currentIndex+1 == _imagesArray.count?0:_currentIndex+1;
        }
        [self loadPage];
        
        ECBlockSet
        dispatch_async(dispatch_get_main_queue(), ^{
            ECBlockGet(strongSelf)
            [strongSelf->_pageControl selectPageWithIndex:strongSelf->_currentIndex];
            
        });
    }
}

- (void)dealloc
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}


@end

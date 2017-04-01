//
//  MultiPickerViewController.m
//  ThinkMail_iOS
//
//  Created by chen ling on 2/10/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import "MultiPickerViewController.h"
#import "MultiPickerCell.h"
#import "PickerElementView.h"
#import <ImageIO/ImageIO.h>
#import "AlbumObj.h"
#import "PhotoObj.h"
#import "ImageDataAPI.h"
#import "PHSourceManager.h"
#import "HWScrollView.h"
#import "GlobalHeader.h"

#define SCREEN_RECT [UIScreen mainScreen].bounds
#define IS_IOS_8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)
#define RECT_TABLE_VIEW CGRectMake(0, 1,self.view.bounds.size.width,self.view.bounds.size.height - 2)

#define HH_ACTION_SHEET_TAG 10000

/**
 *   牙位视图相关的屏幕比例, 是从影像浏览器里抽取过来的, 名字有时间再改
 */
#define SCREEN_HEIGHT_SCALE [UIScreen mainScreen].bounds.size.height / 568.f
#define SCREEN_WIDTH_SCALE [UIScreen mainScreen].bounds.size.width / 320.f
#define TeethPositionViewHeight 201.f * SCREEN_HEIGHT_SCALE     //5s上面的标准为200
#define TeethPositionViewWidth [UIScreen mainScreen].bounds.size.width

//时间标签
#define LabDateHeigth   30 * SCREEN_HEIGHT_SCALE
#define LabDateWidth    170

//返回标签
#define LabBackbuttonHeight     30 * SCREEN_HEIGHT_SCALE
#define LabBackbuttonWidth      60 * SCREEN_WIDTH_SCALE

//标识当前页码的
#define LabBigImageInfoHeight   20 * SCREEN_HEIGHT_SCALE
#define LabBigImageInfoWidth    60 * SCREEN_HEIGHT_SCALE

//右角小按钮
#define SmallbuttonWidth    30 * SCREEN_HEIGHT_SCALE
#define SmallbuttonSpace    16

//more按钮
#define MorebuttonHeigth    30 * SCREEN_HEIGHT_SCALE
#define MorebuttonWidth     45 * SCREEN_WIDTH_SCALE

@interface MultiPickerViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate, HWScrollViewDelegate, MultiPickerCellDelegate>
{
    UIView * m_topView;
    UILabel * m_labDate;
    UIButton * m_backBtn;
    UIView * m_bottomView;
    UIButton * m_overlayImageView;
    NSInteger _currentPage;
    UILabel *m_labBigImageInfo;
}

@property (nonatomic, strong) UITableView *aTableView;


@property (nonatomic, strong) NSMutableArray *elements; //可以包含视频，音频等元素
@property (nonatomic, strong) NSMutableOrderedSet *selectedElements;
@property (nonatomic, assign) CGSize imageSize;

//展示大图所需工作
@property (nonatomic, strong) HWScrollView * bigImgScroll;//用于展示大图

@end

@implementation MultiPickerViewController
@synthesize delegate;

@synthesize assetsGroup = _assetsGroup;
@synthesize aTableView = _aTableView;
@synthesize elements = _elements;
@synthesize selectedElements = _selectedElements;
@synthesize imageSize = _imageSize;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.allowsMultipleSelection = NO;
        self.limitsMinimumNumberOfSelection = NO;
        self.limitsMaximumNumberOfSelection = NO;
        self.minimumNumberOfSelection = 0;
        self.maximumNumberOfSelection = 0;
    }
    return self;
}

#pragma mark - init data


#pragma mark - Init view
- (void)initView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:RECT_TABLE_VIEW style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:tableView];
    
    self.aTableView = tableView;
}

- (HWScrollView *)bigImgScroll
{
    if (!_bigImgScroll)
    {
        _bigImgScroll = [[HWScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bigImgScroll.backgroundColor = kECBlackColor1;
        _bigImgScroll.delegate = self;
    }
    return _bigImgScroll;
}

- (void)loadView
{
    CGRect screenBound = SCREEN_RECT;
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    screenBound.size.height -= MIN(statusBarFrame.size.width, statusBarFrame.size.height);
    UIView *view = [[UIView alloc] initWithFrame:screenBound];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor whiteColor];
    view.opaque = YES;
    self.view = view;
    
    [self initView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //数据准备
    self.elements = [NSMutableArray array];
    self.selectedElements = [NSMutableOrderedSet orderedSet];
    self.imageSize = CGSizeMake(75, 75);
    
    UIButton *btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setFrame:CGRectMake(0, 0, 53, 28)];
    [btnLeft setTitle:@"返回" forState:UIControlStateNormal];
    [btnLeft setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnLeft.titleLabel setFont:[UIFont systemFontOfSize:15]];
    //    UIImage *backBtnImage = [[UIImage imageNamed:@"top_btn_left_n"] stretchableImageWithLeftCapWidth:12 topCapHeight:2];
    //    [btnLeft setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    
    [btnLeft addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIView *leftView = [self customBackImage:nil title:nil action:@selector(goBack:)];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    [self.navigationItem setLeftBarButtonItem:leftItem];
    
    /****right *****/
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 45, 30)];
    [btnRight setTitle:@"完成" forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btnRight addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    if (self.maximumNumberOfSelection > 1)
    {
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
    
//    if (self.maximumNumberOfSelection > )
//    {
//        NSString * title = [NSString stringWithFormat:@"完成(%zd/%zd)", _selectedElements.count, _maximumNumberOfSelection];
//        CGSize size = [NSString contentAutoWidhttWithText:title textHeight:17.f fontSize:15.f];
//        self.rightNavBtn.frame= CGRectMake(0, 0, size.width, 25);
//        [self.rightNavBtn setTitle:title forState:UIControlStateNormal];
//    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];  // Remove a deperacted warning
    titleLabel.text = self.title;
    self.navigationItem.titleView = titleLabel;
    
    
    
}

- (void)dealloc
{
    DLog(@"MultiPickerViewController Release!!");
}


- (UIView *)customBackImage:(UIImage *)backImg title:(NSString *)title action:(SEL)action
{
    if (backImg == nil)
    {
        backImg = [UIImage imageNamed:@"btn_navi_return_white"];
    }
    if (title == nil || title.length == 0)
    {
        title = @"返回";
    }
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 2, 40, 40);
    if (action)
    {
        [backBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [baseView addSubview:backBtn];
    baseView.width = 60;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 48, 44)];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = kECWhiteColor;
    label.backgroundColor = kECClearColor;
    label.text = title;
    label.font = [UIFont systemFontOfSize:17];
    [baseView addSubview:label];
    return baseView;
}


#pragma mark - Event

- (void)goBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)dissmiss
{
    DLog(@"self elements : %@",self.selectedElements);
    if (self.selectedElements && [self.selectedElements count] > 0)
    {
        __block NSMutableArray *infoArray = [NSMutableArray array];
        for (PhotoObj *asset in self.selectedElements)
        {
            /* NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             ALAssetRepresentation *assetRep = [asset defaultRepresentation];
             ALAssetOrientation assetOrientation = [assetRep orientation];
             CGImageRef image = [assetRep fullResolutionImage];
             UIImage *highQuality = [UIImage imageWithCGImage:image scale:1 orientation:(UIImageOrientation)assetOrientation];
             [dict setObject:highQuality forKey:@"IMG"];
             NSNumber *imgSize = [NSNumber numberWithUnsignedInteger:0];
             [dict setObject:imgSize forKey:@"SIZE"];
             NSString *strName = [asset defaultRepresentation].filename;
             [dict setObject:strName forKey:@"NAME"];
             [infoArray addObject:dict];
             */
            [[ImageDataAPI sharedInstance] getImageForPhotoObj:[asset photoObj] withSize:(IS_IOS_8? PHImageManagerMaximumSize:CGSizeZero) completion:^(BOOL ret, UIImage *image) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                if (image)
                {
                    [dict setObject:image forKey:@"IMG"];
                }
                NSNumber *imgSize = [NSNumber numberWithUnsignedInteger:0];
                [dict setObject:imgSize forKey:@"SIZE"];
                [dict setObject:@"" forKey:@"NAME"];
                [infoArray addObject:dict];
            }];
        }
        if (delegate && [delegate respondsToSelector:@selector(multiPickerViewController:didFinishPickingWithImages:)])
        {
            [delegate multiPickerViewController:self didFinishPickingWithImages:infoArray];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == HH_ACTION_SHEET_TAG) {
        NSMutableArray *infoArray = [NSMutableArray array];
        
        //里面存储一个dict，包含，name，
        switch (buttonIndex) {
            case 0:
            {
                for (ALAsset *asset in self.selectedElements) {
                    //UIImage *lowQuality = [self imageFromAsset:asset withMaxPixelSize:200];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    UIImage *lowQuality = [self thumbnailForAsset:asset maxPixelSize:400];
                    [dict setObject:lowQuality forKey:@"IMG"];
                    NSData *imgData = UIImageJPEGRepresentation(lowQuality, 0);
                    NSNumber *imgSize = [NSNumber numberWithUnsignedInteger:[imgData length]];
                    [dict setObject:imgSize forKey:@"SIZE"];
                    NSString *strName = [asset defaultRepresentation].filename;
                    [dict setObject:strName forKey:@"NAME"];
                    [infoArray addObject:dict];
                }
                DLog(@"低画质");
            }
                break;
            case 1:
            {
                for (ALAsset *asset in self.selectedElements) {
                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                    //                    ALAssetOrientation assetOrientation = [assetRep orientation];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    CGImageRef image = [assetRep fullScreenImage];
                    UIImage *generalQuality = [UIImage imageWithCGImage:image];
                    [dict setObject:generalQuality forKey:@"IMG"];
                    NSData *imgData = UIImageJPEGRepresentation(generalQuality, 0);
                    NSNumber *imgSize = [NSNumber numberWithUnsignedInteger:[imgData length]];
                    [dict setObject:imgSize forKey:@"SIZE"];
                    NSString *strName = [asset defaultRepresentation].filename;
                    [dict setObject:strName forKey:@"NAME"];
                    [infoArray addObject:dict];
                    
                    
                }
                DLog(@"普通画质");
            }
                break;
            case 2:
            {
                for (ALAsset *asset in self.selectedElements) {
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    
                    //Modify by Tujie 2014-10-23
                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                    ALAssetOrientation assetOrientation = [assetRep orientation];
                    CGImageRef image = [assetRep fullResolutionImage];
                    UIImage *highQuality = [UIImage imageWithCGImage:image scale:1 orientation:(UIImageOrientation)assetOrientation];//[UIImage imageWithCGImage:image];
                    //End modify
                    
                    //CGImageRef image = [[asset defaultRepresentation] fullResolutionImage];
                    //UIImage *highQuality = nil;
                    NSData *imgData = nil;
                    
                    if ([asset.description rangeOfString:@"JPG"].location != NSNotFound){
                        //highQuality = [UIImage imageWithCGImage:image scale:1.0f orientation:UIImageOrientationRight];
                        imgData = UIImageJPEGRepresentation(highQuality, 0);
                        // orientation 6
                    }
                    else { //png
                        //highQuality = [UIImage imageWithCGImage:image];
                        imgData = UIImagePNGRepresentation(highQuality);
                    }
                    
                    [dict setObject:highQuality forKey:@"IMG"];
                    
                    NSNumber *imgSize = [NSNumber numberWithUnsignedInteger:[imgData length]];
                    
                    [dict setObject:imgSize forKey:@"SIZE"];
                    NSString *strName = [asset defaultRepresentation].filename;
                    [dict setObject:strName forKey:@"NAME"];
                    [infoArray addObject:dict];
                }
                DLog(@"高画质");
            }
                break;
                
            default:
                break;
        }
        
        DLog(@"取到的image array: %@",infoArray);
        if (delegate && [delegate respondsToSelector:@selector(multiPickerViewController:didFinishPickingWithImages:)]) {
            [delegate multiPickerViewController:self didFinishPickingWithImages:infoArray];
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == HH_ACTION_SHEET_TAG) {
        for (id view in actionSheet.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
    
}



- (NSString *)filePath:(ALAsset *)asset
{
    if (![asset isKindOfClass:[ALAsset class]]) {
        DLog(@"取出的文件类型错误");
        return nil;
    }
    
    //NSString *fileUrl = [asset valueForProperty:ALAssetPropertyURLs];
    
    //NSString *fileId = [self getImageID:fileUrl];
    //NSString *suffix = [self getFileSuffix:fileUrl];
    NSString *fileName = asset.defaultRepresentation.filename;
    
    DLog(@"fileName : %@",fileName);
    return nil;
}

-(NSString *) getImageID:(NSString *)imageInfo
{
    NSArray *infos = [[imageInfo description] componentsSeparatedByString:@"id="];
    NSString *info = [infos lastObject];
    NSArray *subInfos = [info componentsSeparatedByString:@"&"];
    NSString *imageID = [subInfos objectAtIndex:0];
    return imageID;
}

- (NSString *)getFileSuffix:(NSString *)fileInfo
{
    NSArray *infos = [[fileInfo description] componentsSeparatedByString:@"id="];
    NSString *info = [infos lastObject];
    NSArray *subInfos = [info componentsSeparatedByString:@"&"];
    NSString *suffixString = [subInfos objectAtIndex:1];
    NSArray *suffixArray = [suffixString componentsSeparatedByString:@"="];
    NSString *suffix = [suffixArray objectAtIndex:1];
    return [suffix stringByReplacingOccurrencesOfString:@"[ ,;,\n,\t,\",}]" withString:@"" options: NSRegularExpressionSearch range:NSMakeRange(0, suffix.length)];
    ;
}

-(BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath
{
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))
        return NO;
    @try
    {
        NSData *imageData = nil;
        NSString *ext = [aPath pathExtension];
        if ([ext isEqualToString:@"PNG"]){
            imageData = UIImagePNGRepresentation(image);
        }
        else{
            
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        
        [imageData writeToFile:aPath atomically:YES];
        
        return YES;
    }
    
    @catch (NSException *e){
        DLog(@"create thumbnail exception.");
    }
    
    return NO;
    
}


-(void)onBackTouch:(id)sender
{
    
    ECBlockSet
    [UIView transitionWithView:_bigImgScroll duration:0.35   // 在noteView视图上设置过渡效果
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        ECBlockGet(strongSelf)
                        strongSelf->_bigImgScroll.frame = CGRectMake(kECScreenWidth, 0, strongSelf->_bigImgScroll.width, strongSelf->_bigImgScroll.height);
                        strongSelf->_bigImgScroll.alpha = 0;
                        
                        strongSelf.navigationController.navigationBar.hidden = NO;
                        [UIApplication sharedApplication].statusBarHidden = NO;
                    }
                    completion:^(BOOL finished){
                        ECBlockGet(strongSelf)
                        [strongSelf->_bigImgScroll removeFromSuperview];
                    }];
    
}


- (void)onSelectedClick:(UIButton *)btn
{
    BOOL canSelect = YES;
    if(self.allowsMultipleSelection && self.limitsMaximumNumberOfSelection)
    {
        canSelect = (self.selectedElements.count < self.maximumNumberOfSelection);
    }
    if (!canSelect && !m_overlayImageView.selected)
    {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"一次选择的图片不得超过%zd张",self.maximumNumberOfSelection] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alerView show];
    }
    else
    {
        PhotoObj *asset = [self.elements objectAtIndex:_currentPage];
        if(self.allowsMultipleSelection)
        {
            NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
            NSInteger rowNum = (_currentPage) / numberOfAssetsInRow;
            NSInteger tag = (_currentPage % numberOfAssetsInRow) + PICKER_ELEMENT_VIEW_TAG;
            MultiPickerCell * cell = [self.aTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowNum inSection:0]];
            
            PickerElementView * elementView = [cell viewWithTag:tag];
            
            if((m_overlayImageView.selected =! m_overlayImageView.selected))
            {
                [self.selectedElements addObject:asset];
                
                elementView.selected = YES;
                
            }
            else
            {
                [self.selectedElements removeObject:asset];
                elementView.selected = NO;
            }
        }
    }
}

- (void)onCompleteBtnClick:(UIButton *)btn
{
    //    [self onBackTouch:nil];
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self dissmiss];
}

#pragma mark - ViewWillAppear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_elements) {
        [_elements removeAllObjects];
    }
    
    /* [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
     if(result) {
     [self.elements addObject:result];
     }
     }];*/
    [[ImageDataAPI sharedInstance] getPhotosWithGroup:self.assetsGroup completion:^(BOOL ret, id obj) {
        [self.elements addObjectsFromArray:obj];
    }];
    [self.aTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - uitableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    if (self.elements.count > 0 && self.imageSize.width > 0) {
        NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
        numberOfRowsInSection = self.elements.count / numberOfAssetsInRow;
        if((self.elements.count - numberOfRowsInSection * numberOfAssetsInRow) > 0)
        {
            numberOfRowsInSection++;
        }
        
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MutilPickerCell";
    MultiPickerCell *cell = (MultiPickerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSInteger numberOfAssetsInRow = 0;
        if (self.imageSize.width > 0) {
            //计算一行显示几个
            numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
        }
        //计算间距
        CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
        
        cell = [[MultiPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier imageSize:self.imageSize numberOfAssets:numberOfAssetsInRow margin:margin];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setDelegate:(id<MultiPickerCellDelegate>)self];
        [cell setAllowsMultipleSelection:self.allowsMultipleSelection];
    }
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger offset = numberOfAssetsInRow * indexPath.row;
    NSInteger numberOfAssetsToSet = (offset + numberOfAssetsInRow > self.elements.count) ? (self.elements.count - offset) : numberOfAssetsInRow;
    
    NSMutableArray *assets = [NSMutableArray array];
    for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        //ALAsset *asset = [self.elements objectAtIndex:(offset + i)];
        PhotoObj *asset = [self.elements objectAtIndex:(offset + i)];
        [assets addObject:asset];
    }
    
    [cell setElements:assets];
    
    // Set selection states
    for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {
        //ALAsset *asset = [self.elements objectAtIndex:(offset + i)];
        PhotoObj *asset = [self.elements objectAtIndex:(offset + i)];
        if([self.selectedElements containsObject:asset]) {
            [cell selectElementAtIndex:i];
        } else {
            [cell deselectElementAtIndex:i];
        }
    }
    return cell;
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 0;
    
    if (self.imageSize.width > 0) {
        NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
        CGFloat margin = round((self.view.bounds.size.width - self.imageSize.width * numberOfAssetsInRow) / (numberOfAssetsInRow + 1));
        heightForRow = margin + self.imageSize.height;
    }
    
    return heightForRow;
}

#pragma mark - multipickercell delegate
- (BOOL)pickerCell:(MultiPickerCell *)cell canSelectElementAtIndex:(NSUInteger)index;
{
    BOOL canSelect = YES;
    if(self.allowsMultipleSelection && self.limitsMaximumNumberOfSelection)
    {
        canSelect = (self.selectedElements.count < self.maximumNumberOfSelection);
    }
    if (!canSelect)
    {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"一次选择的图片不得超过%zd张",self.maximumNumberOfSelection] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alerView show];
    }
    //  if (self.maximumNumberOfSelection <= 1)
    //  {
    //    NSIndexPath *indexPath = [self.aTableView indexPathForCell:cell];
    //
    //    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    //    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    //    ALAsset *asset = [self.elements objectAtIndex:assetIndex];
    //    [self.selectedElements addObject:asset];
    //    [self dissmiss];
    //    return NO;
    //  }
    
    return canSelect;
}

- (void)pickerCell:(MultiPickerCell *)cell didChangeElementSeletionState:(BOOL)selected atIndex:(NSUInteger)index;
{
    NSIndexPath *indexPath = [self.aTableView indexPathForCell:cell];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    //ALAsset *asset = [self.elements objectAtIndex:assetIndex];
    PhotoObj *asset = [self.elements objectAtIndex:assetIndex];
    if(self.allowsMultipleSelection)
    {
        if(selected) {
            [self.selectedElements addObject:asset];
        } else {
            [self.selectedElements removeObject:asset];
        }
    }
    else
    {
        [self.selectedElements addObject:asset];
        [self dissmiss];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        });
    }
}
//看大图
- (void)pickerCell:(MultiPickerCell *)cell showBigImageWithIndex:(NSInteger)index
{
    
    NSIndexPath *indexPath = [self.aTableView indexPathForCell:cell];
    
    NSInteger numberOfAssetsInRow = self.view.bounds.size.width / self.imageSize.width;
    NSInteger assetIndex = indexPath.row * numberOfAssetsInRow + index;
    
    [self.view addSubview:self.bigImgScroll];
    int selectNum = (int)assetIndex;//第几行第几个
    _currentPage = assetIndex;
    [self.bigImgScroll startWithImageDatasArray:self.elements andCurrentIndex:selectNum];
    
#warning developing
    //顶视图
    if (!m_topView)
    {
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TeethPositionViewWidth, 64)];
        m_topView = topView;
        topView.backgroundColor = ECColorWithRGB(0, 0, 0, 0.5);
        
        [self.bigImgScroll addSubview:topView];
        
        //时间label
        if (!m_labDate)
        {
            m_labDate = [[UILabel alloc]initWithFrame:CGRectMake(((self.view.frame.size.width - LabDateWidth) / 2), (self.view.frame.origin.y + 20 + 5), LabDateWidth, LabDateHeigth)];
            m_labDate.font=[UIFont systemFontOfSize:18.0f];
            m_labDate.textAlignment = NSTextAlignmentCenter;
            m_labDate.backgroundColor = ECColorWithRGB(0, 0, 0, 0);
            m_labDate.layer.cornerRadius = CGRectGetHeight(m_labDate.frame)/2;
            [m_labDate.layer setMasksToBounds:YES];
            m_labDate.textColor=[UIColor whiteColor];
            //        NSString * time = ((HWImageModel *)images[index]).updatetime;
            //        m_labDate.text = [time substringToIndex:time.length-3];
            m_labDate.text = @"图片预览";
            [topView addSubview:m_labDate];
        }
        
        if (!m_backBtn)
        {
            //返回按钮
            m_backBtn = [[UIButton alloc]initWithFrame:CGRectMake(8, (self.view.frame.origin.y + 20 + 5), LabBackbuttonWidth, LabBackbuttonHeight)];
            m_backBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            
            [m_backBtn setImage:[UIImage imageNamed:@"btn_navi_return_title"] forState:UIControlStateNormal];
            [m_backBtn setImageEdgeInsets:UIEdgeInsetsMake((LabBackbuttonHeight - 14) / 2, (LabBackbuttonWidth - 45) / 2, (LabBackbuttonHeight - 14) / 2, (LabBackbuttonWidth - 45) / 2)];
            m_backBtn.backgroundColor = ECColorWithRGB(0, 0, 0, 0);
            m_backBtn.layer.cornerRadius = CGRectGetHeight(m_backBtn.frame)/2;
            [m_backBtn.layer setMasksToBounds:YES];
            //    [m_backBtn setTitle:@"返回" forState:UIControlStateNormal];
            //    [m_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            [m_backBtn addTarget:self action:@selector(onBackTouch:) forControlEvents:UIControlEventTouchUpInside];
            
            [topView addSubview:m_backBtn];
        }
        
        UIButton*  moreBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        //moreBtn.tag=image.tag;
        moreBtn.frame=CGRectMake(self.view.frame.size.width - MorebuttonWidth - 8, self.view.frame.origin.y + 20 + 5, MorebuttonWidth, MorebuttonHeigth);
        moreBtn.backgroundColor = ECColorWithRGB(0, 0, 0, 0);
        [moreBtn setTitle:@"完成" forState:UIControlStateNormal];
        moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [moreBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [moreBtn addTarget:self action:@selector(onCompleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:moreBtn];
        
    }
    
    //底视图
    if (!m_bottomView)
    {
        UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _bigImgScroll.frame.size.height - 49, _bigImgScroll.frame.size.width, 49)];
        [_bigImgScroll addSubview:bottomView];
        m_bottomView = bottomView;
        bottomView.backgroundColor = ECColorWithRGB(0, 0, 0, 0.5);
        
        UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.01)];
        bottomLine.backgroundColor = kECBlackColor4;
        bottomLine.alpha = 0.2;
        [m_bottomView addSubview:bottomLine];
        
        // Overlay Image View
        UIButton *overlayImageView = [[UIButton alloc] initWithFrame:CGRectMake(bottomView.width - 35, (bottomView.height - 25) / 2, 25, 25)];
        overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        overlayImageView.layer.cornerRadius = 12.5f;
        overlayImageView.clipsToBounds = YES;
        overlayImageView.backgroundColor = ECColorWithRGB(255, 255, 255, 0.5);
        [overlayImageView setBackgroundImage:[UIImage imageNamed:@"photopicker_nor"] forState:UIControlStateNormal];
        [overlayImageView setBackgroundImage:[UIImage imageNamed:@"photopicker_sel"] forState:UIControlStateSelected];
        overlayImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        overlayImageView.clipsToBounds = YES;
        [overlayImageView addTarget:self action:@selector(onSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [bottomView addSubview:overlayImageView];
        m_overlayImageView = overlayImageView;
        
        //页码显示label
        m_labBigImageInfo=[[UILabel alloc]initWithFrame:CGRectMake(((self.view.frame.size.width - LabBigImageInfoWidth) / 2), (self.view.frame.size.height - LabBigImageInfoHeight - 8), LabBigImageInfoWidth, LabBigImageInfoHeight)];
        m_labBigImageInfo.font=[UIFont systemFontOfSize:18.0f];
        m_labBigImageInfo.textAlignment = NSTextAlignmentCenter;
        m_labBigImageInfo.backgroundColor = ECColorWithRGB(0, 0, 0, 0.5);
        m_labBigImageInfo.layer.cornerRadius = CGRectGetHeight(m_labBigImageInfo.frame)/2;
        [m_labBigImageInfo.layer setMasksToBounds:YES];
        m_labBigImageInfo.textColor=[UIColor whiteColor];
        
        
        [_bigImgScroll addSubview:m_labBigImageInfo];
    }
    
    if ([self.selectedElements containsObject:[self.elements objectAtIndex:selectNum]])
    {
        m_overlayImageView.selected = YES;
    }
    else
    {
        m_overlayImageView.selected = NO;
    }
    
    m_labBigImageInfo.text=[NSString stringWithFormat:@"%zd/%zd", selectNum+1, self.elements.count];
    //动画
    _bigImgScroll.frame = CGRectMake(kECScreenWidth, 0, _bigImgScroll.width, _bigImgScroll.height);
    //    m_viewBigImage.frame = [[UIScreen mainScreen] bounds];
    _bigImgScroll.alpha = 0;
    
    //放大（全屏）ShowImage的动画
    ECBlockSet
    [UIView transitionWithView:_bigImgScroll duration:0.35
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        ECBlockGet(strongSelf)
                        strongSelf->_bigImgScroll.frame = CGRectMake(0, 0, strongSelf->_bigImgScroll.width, strongSelf->_bigImgScroll.height);
                        strongSelf->_bigImgScroll.alpha = 1;
                        strongSelf.navigationController.navigationBar.hidden = YES;
                        [UIApplication sharedApplication].statusBarHidden = YES;
                    }
                    completion:^(BOOL finished){
                        ECBlockGet(strongSelf)
                        
                    }];
    
    
}

# pragma mark - HWScrollViewDelegate
- (void)scrollviewPageWillChangeNextCurrentIndex:(int)currntIndex nextLeftIndex:(int)leftIndex nextRightIndex:(int)rightIndex
{
    DLog(@"current page : %d", _bigImgScroll.currentIndex);
    if (_currentPage != currntIndex)
    {
        _currentPage = currntIndex;
        
        m_labBigImageInfo.text=[NSString stringWithFormat:@"%zd/%zd", currntIndex+1, self.elements.count];
        
        PhotoObj *asset = [self.elements objectAtIndex:currntIndex];
        if(self.allowsMultipleSelection)
        {
            if([self.selectedElements containsObject:asset])
            {
                m_overlayImageView.selected = YES;
            }
            else
            {
                m_overlayImageView.selected = NO;
            }
        }
    }
}

- (void)scrollViewEndedHidden:(HWScrollView *)scrllView isHidden:(BOOL)hidden
{
    if (m_topView.alpha == 1.0f)
    {
        [UIView animateWithDuration:0.1f animations:^{
            m_topView.alpha = 0.0f;
            m_bottomView.alpha = 0.0f;
            m_labBigImageInfo.alpha = 0.0f;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1f animations:^{
            m_topView.alpha = 1.0f;
            m_bottomView.alpha = 1.0f;
            m_labBigImageInfo.alpha = 1.0f;
        }];
    }
}

#pragma mark - Utils

// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        DLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size {
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    if ([asset isKindOfClass:[ALAsset class]])
    {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        
        CGDataProviderDirectCallbacks callbacks = {
            .version = 0,
            .getBytePointer = NULL,
            .releaseBytePointer = NULL,
            .getBytesAtPosition = getAssetBytesCallback,
            .releaseInfo = releaseAssetCallback,
        };
        
        CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
        CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
        
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                          (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                          (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInt:size],
                                                                                                          (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                          });
        CFRelease(source);
        CFRelease(provider);
        
        if (!imageRef) {
            return nil;
        }
        
        UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
        
        CFRelease(imageRef);
        
        return toReturn;
    }
    else if ([asset isKindOfClass:[PHAsset class]])
    {
        
    }
    return nil;
}


- (UIImage *)imageFromAsset:(ALAsset *)asset withMaxPixelSize:(CGFloat)size
{
    NSParameterAssert(asset != nil);
    
    ALAssetRepresentation *assetRepresentation = [asset defaultRepresentation];
    
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                             (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageAlways,
                             (id)[NSNumber numberWithDouble:size], (id)kCGImageSourceThumbnailMaxPixelSize,
                             nil];
    CGImageRef image = [assetRepresentation CGImageWithOptions:options];
    
    float_t scaleHeight = CGImageGetHeight(image)/size;
    
    UIImage *returnImage = [UIImage imageWithCGImage:image scale:scaleHeight orientation:0];
    
    return returnImage;
}



@end

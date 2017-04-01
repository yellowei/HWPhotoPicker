//
//  PhotoPickerController.m
//  ThinkMail_iOS
//
//  Created by chen ling on 2/10/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import "PhotoPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PhotoPickerCell.h"
#import "MultiPickerViewController.h"
#import "ImageDataAPI.h"
#import "AlbumObj.h"
#import "NSString+ECExtensions.h"
#import "GlobalHeader.h"

#define SCREEN_RECT [UIScreen mainScreen].bounds
BOOL isAuthorizedFetchPhoto()
{
    return YES;
    BOOL isAuthorized = NO;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)
    {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined)
        {
            return YES;
        }
        else if (status == PHAuthorizationStatusAuthorized)
        {
            isAuthorized = YES;
        }
        else
        {
            isAuthorized = NO;
        }
    }
    else
    {
        isAuthorized = ([ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusRestricted && [ALAssetsLibrary authorizationStatus] != ALAuthorizationStatusDenied);
    }
    if (!isAuthorized)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有访问照片的权限,您可以去系统设置[设置-隐私-照片]中为牙医管家开启照片功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    return isAuthorized;
    /*
     if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f)
     {
     PHFetchResult  *cameraRo = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
     if ([NSStringFromClass([cameraRo class]) isEqualToString:@"PHUnauthorizedFetchResult"])
     {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有访问照片的权限,您可以去系统设置[设置-隐私-照片]中为牙医管家开启照片功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
     [alert show];
     return NO;
     }
     else
     {
     return YES;
     }
     }
     else
     {
     
     }
     return NO;
     */
}

@interface PhotoPickerController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *aTableView;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assetsGroups;

@end

@implementation PhotoPickerController
@synthesize delegate;
@synthesize filterType;

@synthesize aTableView = _aTableView;
@synthesize assetsLibrary = _assetsLibrary;
@synthesize assetsGroups = _assetsGroups;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.filterType = pickerFilterTypeAllPhotos;
    }
    return self;
}

#pragma mark - loadView
- (void)initView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.dataSource = (id<UITableViewDataSource>)self;
    tableView.delegate = (id<UITableViewDelegate>)self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [tableView setSeparatorColor:[UIColor colorWithRed:(CGFloat)0xec/255.0 green:(CGFloat)0xec/255.0 blue:(CGFloat)0xec/ 255.0 alpha:1]];
    [self.view addSubview:tableView];
    
    self.aTableView = tableView;
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

#pragma mark - View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setFrame:CGRectMake(0, 0, 45, 30)];
    [btnRight setTitle:@"取消" forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnRight.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [btnRight addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.text = self.title;
    self.navigationItem.titleView = titleLabel;
    
    [self.navigationController.navigationBar setBarTintColor:ECColorWithHEX(0xe6e6e6)];
    
    
    /*
     self.assetsGroups = [[NSMutableArray alloc] initWithCapacity:0];
     ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
     self.assetsLibrary = assetsLibrary;
     
     
     //初始化数据
     void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
     if(assetsGroup) {
     switch(self.filterType) {
     case pickerFilterTypeAllAssets:
     [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
     break;
     case pickerFilterTypeAllPhotos:
     [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
     break;
     case pickerFilterTypeAllVideos:
     [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
     break;
     }
     
     if(assetsGroup.numberOfAssets > 0) {
     [self.assetsGroups addObject:assetsGroup];
     [self.aTableView reloadData];
     }
     }
     };
     
     void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
     DLog(@"Error: %@", [error localizedDescription]);
     };
     
     // Enumerate Camera Roll
     [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
     
     // Photo Stream
     [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
     
     // Album
     [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
     
     // Event
     [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupEvent usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
     
     // Faces
     [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupFaces usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
     */
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized)
            {
                [self loadData];
            }
            else
            {
                [self dissmiss];
            }
        }];
    }
    else if (authorStatus == PHAuthorizationStatusRestricted || authorStatus == PHAuthorizationStatusDenied)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有访问照片的权限,您可以去系统设置[设置-隐私-照片]中为牙医管家开启照片功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = 1001;
        [alert show];
    }
    else
    {
        [self loadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)loadData
{
    [[ImageDataAPI sharedInstance] getAlbumsWithCompletion:^(BOOL ret, id obj) {
        if (ret)
        {
            self.assetsGroups = [NSMutableArray arrayWithArray:obj];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.aTableView reloadData];
            });
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        [self dissmiss];
    }
}

#pragma mark - Dissmiss
- (void)dissmiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)dealloc
{
    DLog(@"PhotoPickerController Release!!");
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    PhotoPickerCell *cell = (PhotoPickerCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[PhotoPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    
    //ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    AlbumObj *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    cell.photoImageView.image = assetsGroup.posterImage;//[UIImage imageWithCGImage:assetsGroup.posterImage];
    cell.titleLabel.text = [NSString stringEmptyTransform:assetsGroup.name];//[NSString stringWithFormat:@"%@", [assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    cell.countLabel.text = [NSString stringWithFormat:@"(%zd张)", assetsGroup.count];//[NSString stringWithFormat:@"(%zd张)", assetsGroup.numberOfAssets];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    AlbumObj *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
    
    MultiPickerViewController *multiPicker = [[MultiPickerViewController alloc] init];
    multiPicker.delegate = (id<MultiPickerViewControllerDelegate>)self;
    multiPicker.title = assetsGroup.name;//[assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    multiPicker.filterType = filterType;
    multiPicker.assetsGroup = assetsGroup;
    multiPicker.maximumNumberOfSelection = self.maxImageCount;
    if (multiPicker.maximumNumberOfSelection > 1)
    {
        multiPicker.allowsMultipleSelection = YES;
        multiPicker.limitsMaximumNumberOfSelection = YES;
    }
    else
    {
        multiPicker.allowsMultipleSelection = NO;
    }
    
    
    
    
    [self.navigationController pushViewController:multiPicker animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MultiPickerViewControllerDelegate
- (void)multiPickerViewController:(MultiPickerViewController *)controller
       didFinishPickingWithImages:(NSArray *)images
{
    if (delegate && [delegate respondsToSelector:@selector(photoPickerController:didFinishPickingWithImages:)]) {
        [delegate photoPickerController:self didFinishPickingWithImages:images];
    }
}


# pragma mark - 私有方法
+ (void)showTitle:(NSString *)title message:(NSString *)message{
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}
@end

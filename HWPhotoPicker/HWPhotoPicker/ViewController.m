//
//  ViewController.m
//  HWPhotoPicker
//
//  Created by yellowei on 17/3/31.
//  Copyright © 2017年 yellowei. All rights reserved.
//

#import "ViewController.h"
#import "PhotoPickerController.h"
#import "GlobalHeader.h"

@interface ViewController ()<PhotoPickerControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

# pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kECScreenWidth, kECScreenHeight - 64) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableClick:)];
        [_tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return _dataSource;
}

# pragma mark - 触发手势

- (void)onTableClick:(UITapGestureRecognizer *)tap
{
    PhotoPickerController *imagePickerController = [[PhotoPickerController alloc] initWithNibName:nil bundle:nil];
    imagePickerController.title = @"本地相册";
    [imagePickerController setDelegate:(id<PhotoPickerControllerDelegate>)self];
    imagePickerController.maxImageCount = 999;
    imagePickerController.filterType = pickerFilterTypeAllPhotos;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - 当相册选取玩图片后调用次方法
#pragma mark -<PhotoPickerControllerDelegate>代理方法
/**
 *  当相册选取玩图片后调用次方法
 *  controller
 *  images     被选取的图片数组
 */
- (void)photoPickerController:(PhotoPickerController *)controller
   didFinishPickingWithImages:(NSArray *)images
{
    if (images.count > 0)
    {
        [self.dataSource removeAllObjects];
        
        for (NSDictionary *dict in images)
        {
            UIImage * image = dict[@"IMG"];
            [_dataSource addObject:image];
        }
        [self.tableView reloadData];
    }
    
}

# pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    [cell.imageView setImage:[_dataSource objectAtIndex:indexPath.row]];
    [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}



@end

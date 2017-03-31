//
//  MultiPickerViewController.h
//  ThinkMail_iOS
//
//  Created by chen ling on 2/10/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoPickerController.h"

@class MultiPickerViewController;
@class AlbumObj;
@protocol MultiPickerViewControllerDelegate <NSObject>

@optional

- (void)multiPickerViewController:(MultiPickerViewController *)controller
       didFinishPickingWithImages:(NSArray *)images;

@end

@interface MultiPickerViewController : UIViewController

@property (nonatomic, assign) id<MultiPickerViewControllerDelegate> delegate;

//@property (nonatomic, retain) ALAssetsGroup *assetsGroup;
@property (nonatomic, retain) AlbumObj *assetsGroup;

/**
 *	@brief	是否支持多选
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/**
 *	@brief	最小选多个个
 */
@property (nonatomic, assign) BOOL limitsMinimumNumberOfSelection;

/**
 *	@brief	最多选多少个
 */
@property (nonatomic, assign) BOOL limitsMaximumNumberOfSelection;

@property (nonatomic, assign) NSUInteger minimumNumberOfSelection;
@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;

@property (nonatomic, assign) PhotoPickerFilterType filterType;

@end

//
//  PhotoPickerController.h
//  ThinkMail_iOS
//
//  Created by chen ling on 2/10/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    pickerFilterTypeAllAssets,
    pickerFilterTypeAllPhotos,
    pickerFilterTypeAllVideos
} PhotoPickerFilterType;

BOOL isAuthorizedFetchPhoto();

@class PhotoPickerController;
@protocol PhotoPickerControllerDelegate <NSObject>

@optional
- (void)photoPickerController:(PhotoPickerController *)controller
   didFinishPickingWithImages:(NSArray *)images;


@end

@interface PhotoPickerController : UIViewController
@property (nonatomic, assign) id<PhotoPickerControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger maxImageCount;
@property (nonatomic, assign) PhotoPickerFilterType filterType;

@end


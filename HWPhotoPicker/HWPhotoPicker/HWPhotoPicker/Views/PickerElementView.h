//
//  PickerElementView.h
//  ThinkMail_iOS
//
//  Created by chen ling on 2/11/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class PickerElementView, PhotoObj;
@protocol  PickerElementViewDelegate<NSObject>

@required
- (BOOL)elementViewCanBeSeleted:(PickerElementView *)elementView;
- (void)elementView:(PickerElementView *)elementView didChangeSeletionState:(BOOL)selected;
- (void)elementViewShowBigImage:(PickerElementView *)elementView;

@end
//选中的view
@interface PickerElementView : UIView

@property (nonatomic, assign) id<PickerElementViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, strong) PhotoObj *element;//ALAsset *element;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end

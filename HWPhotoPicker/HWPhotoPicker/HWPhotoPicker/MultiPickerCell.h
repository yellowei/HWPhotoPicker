//
//  MultiPickerCell.h
//  ThinkMail_iOS
//
//  Created by chen ling on 2/11/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PICKER_ELEMENT_VIEW_TAG  1


@class MultiPickerCell;
@protocol MultiPickerCellDelegate <NSObject>

@required
- (BOOL)pickerCell:(MultiPickerCell *)cell canSelectElementAtIndex:(NSUInteger)index;
/**
 *	@brief	取出选出的元素的代理
 *
 *	@param 	cell 	self
 *	@param 	selected 	是否是选中
 *	@param 	index 	选中的index
 */
- (void)pickerCell:(MultiPickerCell *)cell didChangeElementSeletionState:(BOOL)selected atIndex:(NSUInteger)index;

- (void)pickerCell:(MultiPickerCell *)cell showBigImageWithIndex:(NSInteger)index;

@end

//多先的cell
@interface MultiPickerCell : UITableViewCell

@property (nonatomic, assign) id<MultiPickerCellDelegate> delegate;

/**
 *	@brief	是否支持多选
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@property (nonatomic, copy) NSArray *elements;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSUInteger numberOfElements;
@property (nonatomic, assign) CGFloat margin;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfElements margin:(CGFloat)margin;

- (void)selectElementAtIndex:(NSUInteger)index;
- (void)deselectElementAtIndex:(NSUInteger)index;
@end

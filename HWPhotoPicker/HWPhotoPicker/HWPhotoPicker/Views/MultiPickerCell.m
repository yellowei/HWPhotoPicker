//
//  MultiPickerCell.m
//  ThinkMail_iOS
//
//  Created by chen ling on 2/11/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import "MultiPickerCell.h"
#import "PickerElementView.h"
#import "PhotoObj.h"
#import "GlobalHeader.h"

#define PICKER_ELEMENT_VIEW_TAG  1

@implementation MultiPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageSize:(CGSize)imageSize numberOfAssets:(NSUInteger)numberOfElements margin:(CGFloat)margin
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.imageSize = imageSize;
        self.numberOfElements = numberOfElements;
        self.margin = margin;
//        [self setFrame:CGRectMake(0, 0, self.bounds.size.width, imageSize.height)];
//        [self.contentView setFrame:self.bounds];
        [self addElementsViews];
    }
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)addElementsViews
{
    for (UIView *subview in self.contentView.subviews) {
        if ([subview isKindOfClass:[PickerElementView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    for (NSUInteger i = 0 ; i < self.numberOfElements; i ++) {
        CGFloat offset = (self.margin + self.imageSize.width) * i;
        
        CGRect elementViewFrame = CGRectMake(offset + self.margin, self.margin, self.imageSize.width, self.imageSize.height);
        
        PickerElementView *elementView = [[PickerElementView alloc] initWithFrame:elementViewFrame];
        elementView.delegate = (id<PickerElementViewDelegate>)self;
        elementView.tag = PICKER_ELEMENT_VIEW_TAG + i;
        elementView.autoresizingMask = UIViewAutoresizingNone;
        
        [self.contentView addSubview:elementView];
    }
}


- (void)setElements:(NSArray *)elements_
{
    _elements = elements_;
    
    // Set assets
    for(NSUInteger i = 0; i < self.numberOfElements; i++) {
        PickerElementView *elementView = (PickerElementView *)[self.contentView viewWithTag:PICKER_ELEMENT_VIEW_TAG + i];
        if (i < self.elements.count) {
            elementView.hidden = NO;
            elementView.element = [self.elements objectAtIndex:i];
        }
        else
        {
            elementView.hidden = YES;
        }
    }
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    
    // Set property
    for(UIView *subview in self.contentView.subviews) {
        if([subview isMemberOfClass:[PickerElementView class]]) {
            [(PickerElementView *)subview setAllowsMultipleSelection:self.allowsMultipleSelection];
        }
    }
}

#pragma mark - public method
- (void)selectElementAtIndex:(NSUInteger)index;
{
    PickerElementView *elementView = (PickerElementView *)[self.contentView viewWithTag:(index + PICKER_ELEMENT_VIEW_TAG)];
    elementView.selected = YES;
}
- (void)deselectElementAtIndex:(NSUInteger)index;
{
    PickerElementView *elementView = (PickerElementView *)[self.contentView viewWithTag:(index + PICKER_ELEMENT_VIEW_TAG)];
    elementView.selected = NO;
}

#pragma mark - element delegate
- (BOOL)elementViewCanBeSeleted:(PickerElementView *)elementView;
{
    if (self) {
        return [self.delegate pickerCell:self canSelectElementAtIndex:(elementView.tag - PICKER_ELEMENT_VIEW_TAG)];
        
    }
    return NO;
}
- (void)elementView:(PickerElementView*)elementView didChangeSeletionState:(BOOL)selected;
{
    if (self) {
        [self.delegate pickerCell:self didChangeElementSeletionState:selected atIndex:(elementView.tag - PICKER_ELEMENT_VIEW_TAG)];
    }
}

- (void)elementViewShowBigImage:(PickerElementView *)elementView
{
    if ([self.delegate respondsToSelector:@selector(pickerCell:showBigImageWithIndex:)])
    {
        [self.delegate pickerCell:self showBigImageWithIndex:(elementView.tag - PICKER_ELEMENT_VIEW_TAG)];
    }
}

- (void)dealloc
{
    NSLog(@"MultiPickerCell Release!!!");
}

@end

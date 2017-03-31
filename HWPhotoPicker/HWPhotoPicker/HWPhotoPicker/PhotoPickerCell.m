//
//  PhotoPickerCell.m
//  ThinkMail_iOS
//
//  Created by chen ling on 2/10/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import "PhotoPickerCell.h"
#import "NSString+ECExtensions.h"

@implementation PhotoPickerCell
@synthesize photoImageView = _photoImageView;
@synthesize titleLabel = _titleLabel;
@synthesize countLabel = _countLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      self.backgroundView.backgroundColor = [UIColor colorWithRed:246.0 / 255.0 green:246.0 / 255.0 blue:246.0 / 255.0 alpha:1];
      UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10, 5, 75, 75)];
      backView.layer.cornerRadius = 4;
      UIColor *color = [UIColor colorWithRed:(CGFloat)0xec/255.0 green:(CGFloat)0xec/255.0 blue:(CGFloat)0xec/ 255.0 alpha:1];
      [backView.layer setBorderColor:color.CGColor];
      [backView.layer setBorderWidth:0.5];
      
      _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 69, 69)];
      [backView addSubview:_photoImageView];
      
      [self.contentView addSubview:backView];
      
      
      UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
      titleLabel.font = [UIFont systemFontOfSize:15.f];
      titleLabel.textColor = [UIColor colorWithRed:37.0 / 255.0 green:37.0 / 255.0 blue:37.0 / 255.0 alpha:1];
      titleLabel.highlightedTextColor = [UIColor whiteColor];
      titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
      
      [self.contentView addSubview:titleLabel];
      self.titleLabel = titleLabel;
      
      // Count
      UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
      countLabel.font = [UIFont systemFontOfSize:15];
      countLabel.textColor = [UIColor colorWithWhite:0.498 alpha:1.0];
      countLabel.highlightedTextColor = [UIColor whiteColor];
      countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
      
      [self.contentView addSubview:countLabel];
      self.countLabel = countLabel;
      self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      
//        _lineView = [[SeparateLine alloc] initWithFrame:CGRectZero];
//        _lineView.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)contentAutoSizeWithText:(NSString *)text boundSize:(CGSize)boundSize font:(UIFont *)font
{
  CGSize size = CGSizeZero;
  text = [NSString stringEmptyTransform:text];
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
  {
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size = [text boundingRectWithSize:boundSize options: NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
  }
  return size;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView setFrame:self.bounds];
    //[_lineView setFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
    
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat imageViewSize = height - 1;
    CGFloat width = self.contentView.bounds.size.width - 20;
    CGSize titleTextSize = [self contentAutoSizeWithText:self.titleLabel.text boundSize:CGSizeMake(MAXFLOAT, 20) font:self.titleLabel.font];
    if (titleTextSize.width > width)
    {
      titleTextSize.width = width;
    }
  
    CGSize countTextSize = [self contentAutoSizeWithText:self.countLabel.text boundSize:CGSizeMake(MAXFLOAT, 20) font:self.countLabel.font];
    if (countTextSize.width > width)
    {
      countTextSize.width = width;
    }
  
    CGRect titleLabelFrame;
    CGRect countLabelFrame;
    
    if((titleTextSize.width + countTextSize.width + 10) > width) {
        titleLabelFrame = CGRectMake(imageViewSize + 10, 0, width - countTextSize.width - 10, imageViewSize);
        countLabelFrame = CGRectMake(titleLabelFrame.origin.x + titleLabelFrame.size.width + 2, 0, countTextSize.width, imageViewSize);
    } else {
        titleLabelFrame = CGRectMake(imageViewSize + 10, 0, titleTextSize.width, imageViewSize);
        countLabelFrame = CGRectMake(titleLabelFrame.origin.x + titleLabelFrame.size.width + 2, 0, countTextSize.width, imageViewSize);
    }
    
    self.titleLabel.frame = titleLabelFrame;
    self.countLabel.frame = countLabelFrame;
}

@end

//
//  VedioElementInfoView.m
//  ThinkMail_iOS
//
//  Created by chen ling on 2/11/14.
//  Copyright (c) 2014 RICHINFO. All rights reserved.
//

#import "VedioElementInfoView.h"

@interface VedioElementInfoView()


@property (nonatomic, retain) UILabel *durationLabel;

@end

@implementation VedioElementInfoView

- (void)dealloc
{
    _durationLabel = nil;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
        
        // Image View
        CGRect iconImageViewFrame = CGRectMake(6, (self.bounds.size.height - 8) / 2, 14, 8);
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:iconImageViewFrame];
        iconImageView.image = [UIImage imageNamed:@"video"];
        iconImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [self addSubview:iconImageView];
        
        // Label
        CGRect durationLabelFrame = CGRectMake(iconImageViewFrame.origin.x + iconImageViewFrame.size.width + 6, 0, self.bounds.size.width - (iconImageViewFrame.origin.x + iconImageViewFrame.size.width + 6) - 6, self.bounds.size.height);
        UILabel *durationLabel = [[UILabel alloc] initWithFrame:durationLabelFrame];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = NSTextAlignmentRight;
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.font = [UIFont boldSystemFontOfSize:12];
        durationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:durationLabel];
        self.durationLabel = durationLabel;
    }
    
    return self;
}

- (void)setDuration:(CGFloat)duration
{
    _duration = duration;
    
    // Set text
    if(0 <= self.duration && self.duration < 60 * 60) {
        NSInteger min = self.duration / 60.0;
        NSInteger sec = self.duration - 60 * min;
        
        self.durationLabel.text = [NSString stringWithFormat:@"%zd:%02zd", min, sec];
    } else if(60 * 60 <= self.duration && self.duration < 60 * 60 * 60) {
        NSInteger hour = self.duration / (60.0 * 60.0);
        NSInteger min = (self.duration - (60.0 * 60.0) * hour) / 60.0;
        NSInteger sec = self.duration - (60.0 * 60.0) * hour - (60 * min);
        
        self.durationLabel.text = [NSString stringWithFormat:@"%zd:%02zd:%02zd", hour, min, sec];
    }
}



@end
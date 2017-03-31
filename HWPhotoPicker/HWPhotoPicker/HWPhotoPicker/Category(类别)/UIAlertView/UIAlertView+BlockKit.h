//
//  UIAlertView+BlockKit.h
//  ECCustomer
//
//  Created by Sophist on 2016/10/26.
//  Copyright © 2016年 yellowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (BlockKit)

typedef void(^UIAlertView_block_self_index)(UIAlertView *alertView, NSInteger btnIndex);

+ (UIAlertView*)bk_showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles
                                  handler:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))block;

@property(nonatomic,copy)UIAlertView_block_self_index clickBolck;

@end

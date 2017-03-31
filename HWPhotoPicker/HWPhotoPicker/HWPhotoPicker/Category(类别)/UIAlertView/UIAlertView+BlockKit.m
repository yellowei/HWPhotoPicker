//
//  UIAlertView+BlockKit.m
//  ECCustomer
//
//  Created by Sophist on 2016/10/26.
//  Copyright © 2016年 yellowei. All rights reserved.
//

#import "UIAlertView+BlockKit.h"
#import "NSArray+Util.h"
#import <objc/runtime.h>

static void *blockKey = &blockKey;

@implementation UIAlertView (BlockKit)

- (UIAlertView_block_self_index)clickBolck{
    return objc_getAssociatedObject(self,blockKey);
}
-(void)setClickBolck:(UIAlertView_block_self_index)clickBolck
{
    objc_setAssociatedObject(self, blockKey, clickBolck, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


+ (UIAlertView*)bk_showAlertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles
                                  handler:(void (^)(UIAlertView *alertView, NSInteger buttonIndex))block
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:[otherButtonTitles objectAtIndexCheck:0],[otherButtonTitles objectAtIndexCheck:1],[otherButtonTitles objectAtIndexCheck:2],[otherButtonTitles objectAtIndexCheck:3],[otherButtonTitles objectAtIndexCheck:4],[otherButtonTitles objectAtIndexCheck:5],nil];
    alert.delegate = alert;
    alert.clickBolck = block;
    [alert show];
    return alert;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.clickBolck) {
        alertView.clickBolck(alertView,buttonIndex);
        alertView.clickBolck = nil;
    }
    
}


@end

//
//  NSObject+AOP.h
//  ECDoctor
//
//  Created by yellowei on 16/4/25.
//  Copyright © 2016年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface NSObject (AOP)

+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector;

- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;

@end

# pragma mark - UIView Touch Effect
@interface UIView (TouchEffect)

@property (nonatomic, assign) BOOL canHightLight;

@property (nonatomic, strong) UIColor * newHighlightColor;

@end


@interface UIImage(ECExtensions)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end

@interface UIView(test)
+ (UIView *)customBackImage:(UIImage *)backImg title:(NSString *)title target:(id)target action:(SEL)action;
@end

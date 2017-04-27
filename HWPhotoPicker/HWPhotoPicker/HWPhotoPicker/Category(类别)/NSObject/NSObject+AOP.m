//
//  NSObject+AOP.m
//  ECDoctor
//
//  Created by yellowei on 16/4/25.
//  Copyright © 2016年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import "NSObject+AOP.h"
#import "GlobalHeader.h"
#import "NSString+CalculateSize.h"

#define HWAssert(condition, ...) \
if (!(condition)){ HWLog(__FILE__, __FUNCTION__, __LINE__, __VA_ARGS__);} \
NSAssert(condition, @"%@", __VA_ARGS__);

void HWLog(const char* file, const char* func, int line, NSString* fmt, ...)
{
    va_list args; va_start(args, fmt);
    NSLog(@"%s|%s|%d|%@", file, func, line, [[NSString alloc] initWithFormat:fmt arguments:args]);
    va_end(args);
}


@implementation NSObject (AOP)

+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];
    
    Method originalMethod = class_getClassMethod(cls, origSelector);
    Method swizzledMethod = class_getClassMethod(cls, newSelector);
    
    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* swizzing super class method, added if not exist */
        class_replaceMethod(metacls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];
    
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    if (class_addMethod(cls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /*swizzing super class instance method, added if not exist */
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end


# pragma mark - NSArray

@implementation NSArray (AOP)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        /* 数组有内容obj类型才是__NSArrayI */
        NSArray* obj = [[NSArray alloc] initWithObjects:@0, nil];
        [obj swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(swizzleObjectAtIndex:)];
        
        
        /* iOS9 以上，没内容类型是__NSArray0 */
         if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
         {
             obj = [[NSArray alloc] init];
             [obj swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(swizzleObjectAtIndex0:)];
         }
        
    });
}


/* __NSArray0 没有元素，也不可以变 */
- (id)swizzleObjectAtIndex0:(NSUInteger)index{
    return nil;
}

- (id)swizzleObjectAtIndex:(NSUInteger)index {
    if (index < self.count && index < NSNotFound)
    {
        return [self swizzleObjectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSMutableArray (AOP)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray* obj = [[NSMutableArray alloc] init];
        //对象方法 __NSArrayM 和 __NSArrayI 都有实现，都要swizz
        [obj swizzleInstanceMethod:@selector(objectAtIndex:) withMethod:@selector(swizzleObjectAtIndex:)];
        [obj swizzleInstanceMethod:@selector(addObject:) withMethod:@selector(swizzleAddObject:)];
        [obj swizzleInstanceMethod:@selector(insertObject:atIndex:) withMethod:@selector(swizzleInsertObject:atIndex:)];
        [obj swizzleInstanceMethod:@selector(removeObjectAtIndex:) withMethod:@selector(swizzleRemoveObjectAtIndex:)];
        [obj swizzleInstanceMethod:@selector(replaceObjectAtIndex:withObject:) withMethod:@selector(swizzleReplaceObjectAtIndex:withObject:)];
        [obj swizzleInstanceMethod:@selector(removeObjectsInRange:) withMethod:@selector(swizzleRemoveObjectsInRange:)];
        [obj swizzleInstanceMethod:@selector(subarrayWithRange:) withMethod:@selector(swizzleSubarrayWithRange:)];
    });
}
- (void) swizzleAddObject:(id)anObject {
    if (anObject) {
        [self swizzleAddObject:anObject];
    } else {
        HWAssert(NO, @"NSMutableArray invalid args swizzleAddObject:[%@]", anObject);
    }
}
- (id) swizzleObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self swizzleObjectAtIndex:index];
    }
    return nil;
}
- (void) swizzleInsertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= self.count) {
        [self swizzleInsertObject:anObject atIndex:index];
    } else {
        if (!anObject) {
            HWAssert(NO, @"NSMutableArray invalid args swizzleInsertObject:[%@] atIndex:[%@]", anObject, @(index));
        }
        if (index > self.count) {
            HWAssert(NO, @"NSMutableArray swizzleInsertObject[%@] atIndex:[%@] out of bound:[%@]", anObject, @(index), @(self.count));
        }
    }
}

- (void) swizzleRemoveObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self swizzleRemoveObjectAtIndex:index];
    } else {
        HWAssert(NO, @"NSMutableArray swizzleRemoveObjectAtIndex:[%@] out of bound:[%@]", @(index), @(self.count));
    }
}


- (void) swizzleReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index < self.count && anObject) {
        [self swizzleReplaceObjectAtIndex:index withObject:anObject];
    } else {
        if (!anObject) {
            HWAssert(NO, @"NSMutableArray invalid args swizzleReplaceObjectAtIndex:[%@] withObject:[%@]", @(index), anObject);
        }
        if (index >= self.count) {
            HWAssert(NO, @"NSMutableArray swizzleReplaceObjectAtIndex:[%@] withObject:[%@] out of bound:[%@]", @(index), anObject, @(self.count));
        }
    }
}

- (void) swizzleRemoveObjectsInRange:(NSRange)range {
    if (range.location + range.length <= self.count) {
        [self swizzleRemoveObjectsInRange:range];
    }else {
        HWAssert(NO, @"NSMutableArray invalid args swizzleRemoveObjectsInRange:[%@]", NSStringFromRange(range));
    }
}

- (NSArray *)swizzleSubarrayWithRange:(NSRange)range
{
    if (range.location + range.length <= self.count){
        return [self swizzleSubarrayWithRange:range];
    }else if (range.location < self.count){
        return [self swizzleSubarrayWithRange:NSMakeRange(range.location, self.count-range.location)];
    }
    return nil;
}

@end


#pragma mark - NSDictionary
@implementation NSDictionary (Safe)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        [NSDictionary swizzleClassMethod:@selector(dictionaryWithObject:forKey:) withMethod:@selector(swizzleDictionaryWithObject:forKey:)];
        [NSDictionary swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:count:) withMethod:@selector(swizzleDictionaryWithObjects:forKeys:count:)];
        
        /* 数组有内容obj类型才是__NSDictionaryI，没内容类型是__NSDictionary0 */
        NSDictionary* obj = [NSDictionary dictionaryWithObjectsAndKeys:@0,@0,nil];
        [obj swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(swizzleObjectForKey:)];
    });
}
+ (instancetype) swizzleDictionaryWithObject:(id)object forKey:(id)key
{
    if (object && key) {
        return [self swizzleDictionaryWithObject:object forKey:key];
    }
    HWAssert(NO, @"NSDictionary invalid args swizzleDictionaryWithObject:[%@] forKey:[%@]", object, key);
    return nil;
}
+ (instancetype) swizzleDictionaryWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
{
    NSInteger index = 0;
    id ks[cnt];
    id objs[cnt];
    for (NSInteger i = 0; i < cnt ; ++i) {
        if (keys[i] && objects[i]) {
            ks[index] = keys[i];
            objs[index] = objects[i];
            ++index;
        } else {
            HWAssert(NO, @"NSDictionary invalid args swizzleDictionaryWithObject:[%@] forKey:[%@]", objects[i], keys[i]);
        }
    }
    return [self swizzleDictionaryWithObjects:objs forKeys:ks count:index];
}
- (id) swizzleObjectForKey:(id)aKey
{
    if (aKey){
        return [self swizzleObjectForKey:aKey];
    }
    return nil;
}

@end

@implementation NSMutableDictionary (Safe)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary* obj = [[NSMutableDictionary alloc] init];
        [obj swizzleInstanceMethod:@selector(objectForKey:) withMethod:@selector(swizzleObjectForKey:)];
        [obj swizzleInstanceMethod:@selector(setObject:forKey:) withMethod:@selector(swizzleSetObject:forKey:)];
        [obj swizzleInstanceMethod:@selector(removeObjectForKey:) withMethod:@selector(swizzleRemoveObjectForKey:)];
    });
}
- (id) swizzleObjectForKey:(id)aKey
{
    if (aKey){
        return [self swizzleObjectForKey:aKey];
    }
    return nil;
}
- (void) swizzleSetObject:(id)anObject forKey:(id)aKey {
    if (anObject && aKey) {
        [self swizzleSetObject:anObject forKey:aKey];
    } else {
        HWAssert(NO, @"NSMutableDictionary invalid args swizzleSetObject:[%@] forKey:[%@]", anObject, aKey);
    }
}

- (void) swizzleRemoveObjectForKey:(id)aKey {
    if (aKey) {
        [self swizzleRemoveObjectForKey:aKey];
    } else {
        HWAssert(NO, @"NSMutableDictionary invalid args swizzleRemoveObjectForKey:[%@]", aKey);
    }
}

@end

# pragma mark - UIView Touch Effect
@interface UIView ()

@property (nonatomic, strong) UIColor * originalColor;

@end

@implementation UIView (TouchEffect)

static NSString * uiview_touch_effect_key = @"uiview_touch_effect_key";

static NSString * uiview_touch_effect_canhiglight_key = @"uiview_touch_effect_canhiglight_key";

static NSString * uiview_touch_effect_higlightcolor_key = @"uiview_touch_effect_higlightcolor_key";

# pragma mark 自定义属性

- (UIColor *)originalColor
{
    return objc_getAssociatedObject(self, &uiview_touch_effect_key);
}

- (void)setOriginalColor:(UIColor *)originalColor
{
    objc_setAssociatedObject(self, &uiview_touch_effect_key, originalColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canHightLight
{
    return [objc_getAssociatedObject(self, &uiview_touch_effect_canhiglight_key) boolValue];
}

- (void)setCanHightLight:(BOOL)canHightLight
{
    objc_setAssociatedObject(self, &uiview_touch_effect_canhiglight_key, [NSNumber numberWithBool:canHightLight], OBJC_ASSOCIATION_ASSIGN);
}

- (UIColor *)newHighlightColor
{
    return objc_getAssociatedObject(self, &uiview_touch_effect_higlightcolor_key);
}

- (void)setNewHighlightColor:(UIColor *)newHighlightColor
{
    objc_setAssociatedObject(self, &uiview_touch_effect_higlightcolor_key, newHighlightColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


# pragma mark - UIResponder Touch Effect

@implementation UIResponder (TouchEffect)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        UIResponder * obj = [[UIResponder alloc] init];
        [obj swizzleInstanceMethod:@selector(touchesEnded:withEvent:) withMethod:@selector(swizzleTouchesEnded:withEvent:)];
        [obj swizzleInstanceMethod:@selector(touchesBegan:withEvent:) withMethod:@selector(swizzleTouchesBegan:withEvent:)];
        [obj swizzleInstanceMethod:@selector(touchesCancelled:withEvent:) withMethod:@selector(swizzleTouchesCancelled:withEvent:)];
        [obj swizzleInstanceMethod:@selector(touchesMoved:withEvent:) withMethod:@selector(swizzleTouchesMoved:withEvent:)];
    });
}


# pragma mark 被替换的方法

- (void)swizzleTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self isKindOfClass:[UIView class]])
    {
        UIView * view = (UIView *)self;
        if (view.canHightLight)
        {
            view.originalColor = view.backgroundColor;
            if (view.newHighlightColor)
            {
                [view setBackgroundColor:view.newHighlightColor];
            }
            else
            {
                [view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.08]];
            }
            [view.nextResponder touchesBegan:touches withEvent:event];
        }
        else
        {
            [view.nextResponder touchesBegan:touches withEvent:event];
        }
        
    }
    else
    {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}

- (void)swizzleTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self isKindOfClass:[UIView class]])
    {
        UIView * view = (UIView *)self;
        if (view.canHightLight)
        {
            [view setBackgroundColor:view.originalColor];
            [view.nextResponder touchesEnded:touches withEvent:event];
        }
        else
        {
            [view.nextResponder touchesEnded:touches withEvent:event];
        }
        
    }
    else
    {
        [self.nextResponder touchesEnded:touches withEvent:event];
    }
}

- (void)swizzleTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self isKindOfClass:[UIView class]])
    {
        UIView * view = (UIView *)self;
        if (view.canHightLight)
        {
            if (view.newHighlightColor)
            {
                [view setBackgroundColor:view.newHighlightColor];
            }
            else
            {
                [view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.08]];
            }
            [view.nextResponder touchesMoved:touches withEvent:event];
        }
        else
        {
            [view.nextResponder touchesMoved:touches withEvent:event];
        }
        
    }
    else
    {
        [self.nextResponder touchesMoved:touches withEvent:event];
    }
}

- (void)swizzleTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self isKindOfClass:[UIView class]])
    {
        UIView * view = (UIView *)self;
        if (view.canHightLight)
        {
            [view setBackgroundColor:view.originalColor];
            [view.nextResponder touchesCancelled:touches withEvent:event];
        }
        else
        {
            [view.nextResponder touchesCancelled:touches withEvent:event];
        }
        
    }
    else
    {
        [self.nextResponder touchesCancelled:touches withEvent:event];
    }
}


@end


# pragma mark - UIViewController NavBar

static NSString * UIViewController_hideNavgationbar_key = @"UIViewController_hideNavgationbar_key";

@interface UIViewController ()<UINavigationControllerDelegate>

@end

@implementation UIViewController (navBar)

- (BOOL)hideNavBar
{
    return [objc_getAssociatedObject(self, &UIViewController_hideNavgationbar_key) boolValue];
}

- (void)setHideNavBar:(BOOL)isHide
{
    objc_setAssociatedObject(self, &UIViewController_hideNavgationbar_key, [NSNumber numberWithBool:isHide], OBJC_ASSOCIATION_ASSIGN);
    [self.navigationController setNavigationBarHidden:isHide  animated:NO];
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        UIViewController * obj = [[UIViewController alloc] init];
        [obj swizzleInstanceMethod:@selector(viewDidLoad) withMethod:@selector(swizzleViewDidLoad)];
        [obj swizzleInstanceMethod:@selector(init) withMethod:@selector(swizzleInit)];
        [obj swizzleInstanceMethod:@selector(viewDidAppear:) withMethod:@selector(swizzleViewDidAppear:)];
        
    });
}

-(void)swizzleViewDidLoad
{
    [self initNavBarProperty];
    [self swizzleViewDidLoad];
}

-(void)swizzleInit
{
    self.hidesBottomBarWhenPushed = YES;
    [self swizzleInit];
}

-(void)swizzleViewDidAppear:(BOOL)animated
{
    [self swizzleViewDidAppear:animated];
    if (self.hideNavBar) {
        [self.navigationController setNavigationBarHidden:self.hideNavBar animated:animated];
        self.navigationController.delegate = self;
    }
    
    //自定义返回按钮手势会消失
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    }
}


-(void)initNavBarProperty
{
    // 设置导航条的色调 理解为"混合色"
    UINavigationController *nav = (UINavigationController *)([self isKindOfClass:[UINavigationController class]]?self:self.navigationController);
    nav.navigationBar.barTintColor = [UIColor whiteColor];
    // 导航栏默认是半透明状态
    nav.navigationBar.backgroundColor = [UIColor whiteColor];
    nav.navigationBar.translucent = NO;
    // 导航栏标题颜色
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : kECBlackColor2}];
    
    UIImage *colorImage = [UIImage imageWithColor:[UIColor whiteColor]];
    [nav.navigationBar setBackgroundImage:colorImage forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setShadowImage:[UIImage imageWithColor:kECBlackColor5]];
    if (nav.viewControllers.count > 1) {
        [self initNavBackItem];
    }
    
}

-(void)initNavBackItem
{
    [self customBackImage:nil title:nil];
}

- (void)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)customBackImage:(UIImage *)backImg title:(NSString *)title
{
    UIView *baseView = [UIView customBackImage:backImg title:title target:self action:@selector(onBack:)];
    
    UIBarButtonItem *leftBarButtonItems = [[UIBarButtonItem alloc]initWithCustomView:baseView];
    
    UIBarButtonItem *nagetiveSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                   target:nil action:nil];
    nagetiveSpacer.width = -15;//这个值可以根据自己需要自己调整
    
    self.navigationItem.leftBarButtonItems = @[nagetiveSpacer, leftBarButtonItems];
    
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    //    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:viewController.hideNavBar animated:animated];
    
}



@end

@implementation UIImage (ECExtensions)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end


@implementation UIView (test)

+ (UIView *)customBackImage:(UIImage *)backImg title:(NSString *)title target:(id)target action:(SEL)action
{
    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(15, 20, 60, 44)];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = 0;
    if (kECScreenWidth > 376)
    {
        x = -5;
    }
    else if (kECScreenWidth > 321)
    {
        x = -2;
    }
    backBtn.frame = CGRectMake(x, 0, 60, 44);
    if (action)
    {
        [backBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (backImg == nil && title.length == 0)
    {
        backImg = [UIImage imageNamed:@"btn_navi_return_title"];
        CGSize size = backImg.size;
        CGFloat scale = size.height/16;
        size.width = size.width/scale;
        size.height = 16;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake((44-size.height)/2, 10, (44-size.height)/2, CGRectGetWidth(backBtn.frame)-size.width - 10)];
    }
    else if (backImg == nil && title.length > 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kECWhiteColor;
        label.backgroundColor = kECClearColor;
        label.numberOfLines = 1;
        label.text = title;
        label.font = [UIFont systemFontOfSize:17];
        CGSize size = [NSString contentAutoSizeWithText:title boundSize:CGSizeMake(MAXFLOAT, 20) font:label.font];
        if (size.width > 80)
        {
            size.width = 80;
        }
        else if (size.width < 20)
        {
            size.width = 20;
        }
        label.width = size.width;
        [baseView addSubview:label];
    }
    else if (backImg && title.length == 0)
    {
        CGSize size = backImg.size;
        CGFloat scale = size.height/15;
        size.width = size.width/scale;
        size.height = 15;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake((44-size.height)/2, 0, (44-size.height)/2, CGRectGetWidth(backBtn.frame)-size.width)];
    }
    else
    {
        CGSize size = backImg.size;
        CGFloat scale = size.height/15;
        size.width = size.width/scale;
        size.height = 15;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake((44-size.height)/2, 0, (44-size.height)/2, CGRectGetWidth(backBtn.frame)-size.width)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(size.width + 5, 0, 48, 44)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = kECWhiteColor;
        label.backgroundColor = kECClearColor;
        label.numberOfLines = 1;
        label.text = title;
        label.font = [UIFont systemFontOfSize:17];
        size = [NSString contentAutoSizeWithText:title boundSize:CGSizeMake(MAXFLOAT, 20) font:label.font];
        if (size.width > 80)
        {
            size.width = 80;
        }
        else if (size.width < 20)
        {
            size.width = 20;
        }
        label.width = size.width;
        [baseView addSubview:label];
    }
    if (backImg)
    {
        [backBtn setImage:backImg forState:UIControlStateNormal];
    }
    [baseView addSubview:backBtn];
    return baseView;
}

@end

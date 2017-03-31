//
//  NSObject+RunTimeUtility.m
//  ECDoctor
//
//  Created by yellowei on 16/12/30.
//  Copyright © 2016年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import "NSObject+RunTimeUtility.h"
#import <objc/runtime.h>

@implementation NSObject (RunTimeUtility)

- (id)getPrivateProperty:(NSString *)propertyName
{
    Ivar iVar = class_getInstanceVariable([self class], [propertyName UTF8String]);
    if (iVar == nil) {
        iVar = class_getInstanceVariable([self class], [[NSString stringWithFormat:@"_%@",propertyName] UTF8String]);
    }
    id propertyVal = object_getIvar(self, iVar);
    return propertyVal;
}


@end

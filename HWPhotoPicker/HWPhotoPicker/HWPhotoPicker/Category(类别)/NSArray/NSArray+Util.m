//
//  NSArray+Util.m
//  ECDoctor
//
//  Created by Sophist on 16/1/26.
//  Copyright © 2016年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import "NSArray+Util.h"

@implementation NSArray (Util)

- (id)objectAtIndexCheck:(NSUInteger)index {
  if (index >= [self count])
  {
    return nil;
  }
  id value = [self objectAtIndex:index];
  if (value == [NSNull null])
  {
    return nil;
  }
  return value;
}


@end

//
//  NSObject+RunTimeUtility.h
//  ECDoctor
//
//  Created by yellowei on 16/12/30.
//  Copyright © 2016年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RunTimeUtility)

- (id)getPrivateProperty:(NSString *)propertyName;

@end


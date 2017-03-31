//
//  HWImageModel.m
//  ECDoctor
//
//  Created by linsen on 15/8/17.
//  Copyright (c) 2015年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import "HWImageModel.h"
#import "NSString+ECExtensions.h"
#import <UIKit/UIKit.h>

@implementation HWImageModel
+ (HWImageModel *)objectWithKeyValues:(id)keyValues
{
    HWImageModel *imageObject = nil;
    if (keyValues && [keyValues isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *record = keyValues;
        NSArray *Series = record[@"Series"];
        NSString *StudyTime = record[@"StudyTime"];
        if ([StudyTime containsString:@"-"])
        {
            StudyTime = [StudyTime stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        NSString *StudyUID = record[@"StudyUID"];
        if (Series || StudyTime || StudyUID)
        {
             NSString *updatetime = record[@"updatetime"];
            for (NSDictionary *serie in Series)
            {
                NSString *SeriesUID = serie[@"SeriesUID"];
                NSArray *images = serie[@"images"];
                if (SeriesUID && images)
                {
                    for (NSDictionary *image in images)
                    {
                        NSString *SOPClassUID = image[@"SOPClassUID"];
                        NSString *SOPInstanceUID = image[@"SOPInstanceUID"];
                        NSString *BlankOut = [NSString stringEmptyTransform:image[@"BlankOut"]];
                        if (SOPClassUID && SOPInstanceUID)
                        {
                            imageObject = [[HWImageModel alloc] init];
                            imageObject.sopinstanceuid = [NSString stringEmptyTransform: SOPInstanceUID];
                            imageObject.sopclassuid = [NSString stringEmptyTransform: SOPClassUID];
                            imageObject.studytime = [NSString stringEmptyTransform:StudyTime];
                            imageObject.studyuid = [NSString stringEmptyTransform:StudyUID];
                            imageObject.seriesuid = [NSString stringEmptyTransform:SeriesUID];
                            imageObject.updatetime = [NSString stringEmptyTransform:updatetime];
                            if ([BlankOut isEqualToString:@"0"])
                            {
                                imageObject.datastatus = 1;
                            }
                            else
                            {
                                imageObject.datastatus = 0;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            NSString *sopinstanceuid = record[@"clinicid"];
            if (sopinstanceuid && sopinstanceuid.length > 0)
            {
                imageObject = [HWImageModel objectWithKeyValues:record];
            }
        }
    }
    return imageObject;
}

+ (NSMutableArray *)objectArrayWithKeyValuesArray:(NSArray *)keyValuesArray
{
    NSMutableArray *returnArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *record in keyValuesArray)
    {
        NSArray *Series = record[@"Series"];
        NSString *StudyTime = record[@"StudyTime"];
        if ([StudyTime containsString:@"-"])
        {
            StudyTime = [StudyTime stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        NSString *StudyUID = record[@"StudyUID"];
        if (Series || StudyTime || StudyUID)
        {
            
            NSString *updatetime = record[@"updatetime"];
            if ([updatetime containsString:@"-"])
            {
                updatetime = [updatetime stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            }
            
            
            for (NSDictionary *serie in Series)
            {
                NSString *SeriesUID = serie[@"SeriesUID"];
                NSArray *images = serie[@"images"];
                if (SeriesUID && images)
                {
                    for (NSDictionary *image in images)
                    {
                        NSString *SOPClassUID = image[@"SOPClassUID"];
                        NSString *SOPInstanceUID = image[@"SOPInstanceUID"];
                        NSString *sophistId = image[@"sopuid"];
                        NSString *title = image[@"title"];
                        NSString *contentdescription = image[@"contentdescription"];
                        NSString *bodyposition = image[@"bodyposition"];
                        NSString *BlankOut = [NSString stringEmptyTransform:image[@"BlankOut"]];
                        if (SOPClassUID && SOPInstanceUID)
                        {
                            HWImageModel *imageObject = [[HWImageModel alloc] init];
                            imageObject.sopinstanceuid = [NSString stringEmptyTransform: SOPInstanceUID];
                            imageObject.sopclassuid = [NSString stringEmptyTransform: SOPClassUID];
                            imageObject.studytime = [NSString stringEmptyTransform:StudyTime];
                            imageObject.studyuid = [NSString stringEmptyTransform:StudyUID];
                            imageObject.seriesuid = [NSString stringEmptyTransform:SeriesUID];
                            imageObject.updatetime = [NSString stringEmptyTransform:updatetime];
                            imageObject.sopuid = [NSString stringEmptyTransform:sophistId];
                            imageObject.title = [NSString stringEmptyTransform:title];
                            imageObject.contentdescription = [NSString stringEmptyTransform:contentdescription];
                            imageObject.bodyposition = [NSString stringEmptyTransform:bodyposition];
                          
                            if ([BlankOut isEqualToString:@"0"])
                            {
                                imageObject.datastatus = 1;
                            }
                            else
                            {
                                imageObject.datastatus = 0;
                            }
                            [returnArr addObject:imageObject];
                        }
                    }
                }
            }
        }
        else
        {
            NSString *sopinstanceuid = record[@"clinicid"];
            if (sopinstanceuid && sopinstanceuid.length > 0)
            {
                HWImageModel *imageObject = [HWImageModel objectWithKeyValues:record];
                [returnArr addObject:imageObject];
            }
        }
    }
    return returnArr;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.imageidentity = @"";
        self.studyuid = @"";
        self.clinicid = @"";
        self.customerid = @"";
        self.studyidentity = @"";
        self.date = @"";
        self.datastatus = 0;
        self.updatetime  = @"";
        self.studytime = @"";
        self.seriesuid = @"";
        self.sopclassuid = @"";
        self.sopinstanceuid = @"";
    }
    return self;
}


@end

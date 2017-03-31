//
//  HWImageModel.h
//  ECDoctor
//
//  Created by linsen on 15/8/17.
//  Copyright (c) 2015年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	@brief	影像(查询:354)
 *
 *	Created by mac on 2015-08-17 13:59
 */
@interface HWImageModel : NSObject

@property (nonatomic, copy)NSString *clinicid;
//@property (nonatomic, copy)NSString *doctorid;
@property (nonatomic, copy)NSString *customerid;
/**
 *	@brief	图像ID
 *
 *	Created by mac on 2015-08-18 09:50
 */
@property (nonatomic, copy)NSString *imageidentity;
@property (nonatomic, assign)NSInteger datastatus;
@property (nonatomic, copy)NSString *updatetime;



/**
 *	@brief	就诊ID
 *
 *	Created by mac on 2015-08-18 09:50
 */
@property (nonatomic, copy)NSString *studyuid;

@property (nonatomic, copy) NSString * seriesuid;

@property (nonatomic, copy) NSString * sopuid;



/**
 *  治疗状态
 */
@property (nonatomic, copy) NSString * title;//0,1,2 -> 前，中，后

@property (nonatomic, copy) NSString * contentdescription;//备注

@property (nonatomic, copy) NSString * bodyposition;//牙位





/**
 *	@brief	图像ID
 *
 *	Created by mac on 2015-08-18 09:50
 */
@property (nonatomic, copy)NSString *date;

/**
 *	@brief	图像ID
 *
 *	Created by mac on 2015-08-18 09:50
 */
@property (nonatomic, copy)NSString *studyidentity;


/**
 *	@brief	就诊时间
 *
 *	Created by mac on 2015-09-08 09:22
 */
@property (nonatomic, copy)NSString *studytime;

/**
 *	@brief	<#Description#>
 *
 *	Created by mac on 2015-09-08 09:23
 */
//@property (nonatomic, copy)NSString *seriesuid;

/**
 *	@brief	<#Description#>
 *
 *	Created by mac on 2015-09-08 09:23
 */
@property (nonatomic, copy)NSString *sopclassuid;

/**
 *	@brief	<#Description#>
 *
 *	Created by mac on 2015-09-08 09:23
 */
@property (nonatomic, copy)NSString *sopinstanceuid;

/**
 *	@brief	删除标记，为0表示存在，其它就为被删除
 *
 *	Created by mac on 2015-10-06 19:17
 */
//@property (nonatomic, copy)NSString *blankout;


/* 图像url:http://115.29.37.174:82/WADO.php?action=LoadImage&StudyUID=studyuid&SeriesUID=seriesuid&SopUID=sopinstanceuid&Columns=100&Rows=100
 
 url后面增加参数 &Columns=80&Rows=80 实现分辨率访问；
 增加参数&outfit=1表示外切图片，默认是内适应图片
 增加参数&backcolor=0xffffff表示背景颜色为白色，默认背景色为白色
 示例：http://115.28.139.39/image/WADO.php?action=LoadImage&FileName=55.jpg&Columns=800&Rows=400&backcolor=0xffffff&outfit=1
 */


- (NSString *)getThumbnailImageUrlStr;
- (NSString *)getImageUrlStr;
@end

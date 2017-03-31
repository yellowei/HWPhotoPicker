//
//  NSString+Date.h
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)

- (NSComparisonResult)dateStrCompare:(NSString *)dateStr;

/**
 *  格式化时间
 *
 *  @param time 秒
 *
 *  @return 格式化时间
 */
+ (NSString *)timeFormat:(NSInteger)time;

/**
 *	@brief	时间字符串转换
 *
 *	@param 	dateStr 	原始时间字符串
 *
 *	@return	转换后的字符串
 *
 *	Created by mac on 2015-08-27 11:44
 */
+ (NSString *)stringFromDateSpec:(NSString *)dateStr;

/**
 *	@brief	时间字符串转换
 *
 *	@param 	date 	时间
 *
 *	@return	转换后的字符串
 *
 *	Created by mac on 2015-09-09 17:24
 */
+ (NSString *)stringFromDate:(NSDate *)date;


/**
 *	@brief	获取周几
 *
 *	@param 	dateComponent 	时间
 *
 *	@return 周几
 *
 *	Created by mac on 2015-08-27 11:43
 */
+ (NSString *)getWeekDayWith:(NSDateComponents *)dateComponent;


/**
 *  时间戳转文件列表时间
 *
 *  @return 格式化时间
 */
- (NSString *)timestampFormat;

/**
 *  讨论信息列表时间戳转换
 *
 *  @return 格式化时间
 */
- (NSString *)discussionTimestampFormat;



/**
 *  判断输入时间是过去还是将来
 *
 *  @param timeStr 标准时间
 *
 *  @return 是否在将来
 */
+ (BOOL)isFutureWithTimeStr:(NSString *)timeStr;

/**
 *  时间样式转换
 *
 *  @param strDate 标准时间
 *
 *  @return 日期(今天明天)
 */
+(NSString*)getDateDayInfo:(NSString*)strDate;

/**
 *  时间样式转换
 *
 *  @param strDate 标准时间
 *
 *  @return 今天明天+时间
 */
+(NSString*)getDateInfo:(NSString*)strDate;


/**
 *  时间样式转换(包含了时间)
 *
 *  @param strDate 标准时间
 *
 *  @return 今天明天+时间
 */
+(NSString*)getTimeInfo:(NSString*)strDate;


/**
 *  时间样式转换(历史欠款 预约)
 *
 *  @param strDate 标准时间
 *
 *  @return 今天明天+时间
 */
+(NSString*)getDateOfDebt:(NSString*)strDate;


+(NSString*)getTimeString:(NSString*)strDate;

/**
 *	@brief	年龄转换
 *
 *	@param 	birthday 	出生日期
 *
 *	@return	年龄
 *
 *	Created by mac on 2015-09-28 21:49
 */
+ (NSString *)getAgeWithBirthday:(NSString *)birthday;



@end

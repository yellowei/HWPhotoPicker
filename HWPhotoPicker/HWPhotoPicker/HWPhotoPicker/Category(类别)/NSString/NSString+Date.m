//
//  NSString+Date.m
//  ECAcademy
//
//  Created by Sophist on 2017/3/28.
//  Copyright © 2017年 dentalink. All rights reserved.
//

#import "NSString+Date.h"
#import "NSString+ECExtensions.h"
@implementation NSString (Date)
static NSDateFormatter *dateFormatter;
- (NSComparisonResult)dateStrCompare:(NSString *)dateStr
{
    if ([self isValid] && [dateStr isValid])
    {
        NSString *selfStr = [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
        selfStr = [selfStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        selfStr = [selfStr stringByReplacingOccurrencesOfString:@":" withString:@""];
        if (selfStr.length > 14)
        {
            selfStr = [selfStr substringToIndex:14];
        }
        
        while (selfStr.length < 14)
        {
            selfStr = [selfStr stringByAppendingString:@"0"];
        }
        
        NSString *compareStr = [dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        compareStr = [compareStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        compareStr = [compareStr stringByReplacingOccurrencesOfString:@":" withString:@""];
        if (compareStr.length > 14)
        {
            compareStr = [compareStr substringToIndex:14];
        }
        
        while (compareStr.length < 14)
        {
            compareStr = [compareStr stringByAppendingString:@"0"];
        }
        
        if ([selfStr longLongValue] > [compareStr longLongValue])
        {
            return NSOrderedDescending;
        }
        else if ([selfStr longLongValue] == [compareStr longLongValue])
        {
            return NSOrderedSame;
        }
        else
        {
            return NSOrderedAscending;
        }
        
    }
    return NSOrderedAscending;
}

#pragma mark 格式化时间
+ (NSString *)timeFormat:(NSInteger)time
{
    NSString *result = @"00:00";
    if (time >= 3600) {
        NSInteger hour = time/3600;
        NSInteger minute = (time-hour*3600)/60;
        NSInteger second = time-hour*3600-minute*60;
        
        NSString *hourString = [[NSString alloc] initWithFormat:@"%zd",hour];
        if(hour < 10) {
            hourString = [[NSString alloc] initWithFormat:@"0%zd",hour];
        }
        
        NSString *minString = [[NSString alloc] initWithFormat:@"%zd",minute];
        if(minute < 10) {
            minString = [[NSString alloc] initWithFormat:@"0%zd",minute];
        }
        
        NSString *secondString = [[NSString alloc] initWithFormat:@"%zd",second];
        if(second < 10) {
            secondString = [[NSString alloc] initWithFormat:@"0%zd",second];
        }
        result = [[NSString alloc] initWithFormat:@"%@:%@:%@",hourString,minString,secondString];
    }
    else if (time < 3600 && time > 0) {
        NSInteger minute = time/60;
        NSInteger second = time-minute*60;;
        NSString *minString = [[NSString alloc] initWithFormat:@"%zd",minute];
        if(minute < 10) {
            minString = [[NSString alloc] initWithFormat:@"0%zd",minute];
        }
        
        NSString *secondString = [[NSString alloc] initWithFormat:@"%zd",second];
        if(second < 10) {
            secondString = [[NSString alloc] initWithFormat:@"0%zd",second];
        }
        result = [[NSString alloc] initWithFormat:@"%@:%@",minString,secondString];
    }
    return result;
}

+ (NSString *)stringFromDateSpec:(NSString *)dateStr
{
    if (dateStr == nil || dateStr.length < 10) {
        return dateStr;
    }
    
    //时间标签设置
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSDate *date = [NSDate date];
    NSString *timeString = @"";
    unsigned unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit |
    NSWeekdayCalendarUnit;
    
    NSCalendar *theCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; //[NSCalendar currentCalendar];
    [theCalendar setTimeZone:timeZone];
    NSDateComponents *comps = [theCalendar components:unitFlags fromDate:date];
    int nowmonth = (int)[comps month];
    int nowday = (int)[comps day];
    int nowyear = (int)[comps year];
    int nowWeekday = (int)[comps weekday];
    
    NSString *strToday = [NSString stringWithFormat:@"%d/%.2d/%.2d 00:00:00", nowyear, nowmonth, nowday];
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *dateToday = [dateFormatter dateFromString:strToday];
    NSDate *dateMessage = [dateFormatter dateFromString:dateStr];
    
    comps = [theCalendar components:unitFlags fromDate:dateMessage];
    int showYear = (int)[comps year];
    int showHour = (int)[comps hour];
    int showMinute = (int)[comps minute];
    int showMonth = (int)[comps month];
    int showDay = (int)[comps day];
    int weekDay = (int)[comps weekday];
    int inWeek = [dateToday timeIntervalSinceDate:dateMessage]/(3600 * 24);
    
    if ([[dateMessage earlierDate:dateToday] isEqualToDate:dateToday] ) {
        timeString = [NSString stringWithFormat:@"%.2d:%.2d", showHour, showMinute] ;
    }
    else if(0 == inWeek) {
        timeString = @"昨天";
    }
    // Modify by Mark 2014-02-13
    //    else if(1 == inWeek) {
    //        timeString = @"前天";
    //    }
    //    else if (inWeek < 7) {
    // nowWeekday本来就要减一，再要减掉周日，所以减2了
    // 中国日历，星期一起，我操！！！
    else if((inWeek < nowWeekday-2) && (nowWeekday-weekDay > 0)) {
        NSArray *weekName = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
        timeString = [NSString stringWithFormat:@"星期%@", [weekName objectAtIndex:weekDay-1]];
    }
    // 本年度内只显示月日
    // Add by Mark 2014-02-12
    else if (showYear == nowyear) {
        timeString = [NSString stringWithFormat:@"%.2d/%.2d", showMonth, showDay];
    }
    // End Add
    else {
        // 年数两位数
        // Modify by Mark 2014-03-17
        timeString = [NSString stringWithFormat:@"%d/%.2d/%.2d", showYear, showMonth, showDay] ;
    }
    
    return timeString;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    if (!date || ![date isKindOfClass:[NSDate class]])
    {
        date = [NSDate date];
        
    }
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString *)getWeekDayWith:(NSDateComponents *)dateComponent
{
    NSString *strWeek = @"";
    if (dateComponent && [dateComponent isKindOfClass:[NSDateComponents class]])
    {
        NSInteger nWeekend = ([dateComponent weekday]-1)%7;
        switch (nWeekend) {
            case 0:
                strWeek = @"周日";
                break;
            case 1:
                strWeek = @"周一";
                break;
            case 2:
                strWeek = @"周二";
                break;
            case 3:
                strWeek = @"周三";
                break;
            case 4:
                strWeek = @"周四";
                break;
            case 5:
                strWeek = @"周五";
                break;
            case 6:
                strWeek = @"周六";
                break;
            default:
                break;
        }
    }
    return strWeek;
}

+(NSString*)getDateDayInfo:(NSString*)strDate
{
    if (nil==strDate || strDate.length==0) {
        return @"";
    }
    
    static NSUInteger uintFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSCalendarUnitSecond;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:strDate];
    
    if (nil==date) {
        return @"";
    }
    
    NSDateComponents* compsDate = [calendar components:uintFlags fromDate:date];
    NSDateComponents* compsNow = [calendar components:uintFlags fromDate:[NSDate date]];
    NSDateComponents* compsYesterday = [calendar components:uintFlags fromDate:[NSDate date]];
    compsYesterday.day -= 1;
    NSDate* dateYesterday= [calendar dateFromComponents:compsYesterday];
    compsYesterday = [calendar components:uintFlags fromDate:dateYesterday];
    
    long lInterval = 0-date.timeIntervalSinceNow;   // 秒
    
    if (lInterval < 0)
    {
        NSDateComponents* compsTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsTomorrow.day += 1;
        NSDate* dateTomorrow= [calendar dateFromComponents:compsTomorrow];
        compsYesterday = [calendar components:uintFlags fromDate:dateTomorrow];
        
        NSDateComponents* compsAfterTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsAfterTomorrow.day += 2;
        NSDate* dateAfterTomorrow = [calendar dateFromComponents:compsAfterTomorrow];
        compsAfterTomorrow = [calendar components:uintFlags fromDate:dateAfterTomorrow];
        
        if (compsNow.year==compsDate.year && compsNow.month==compsDate.month && compsNow.day==compsDate.day) {
            return @"今天";
        }
        else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
            return @"明天";
        }
        else if (compsAfterTomorrow.year==compsDate.year && compsAfterTomorrow.month==compsDate.month && compsAfterTomorrow.day==compsDate.day) {
            return @"后天";
        }
        else
        {
            return [NSString stringWithFormat:@"%d/%d/%d", (int)compsDate.year, (int)compsDate.month, (int)compsDate.day];
        }
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month &&compsDate.day == compsNow.day){
        return @"今天";
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
        return @"昨天";
    }
    else if (compsYesterday.year==compsDate.year)
    {
        return [NSString stringWithFormat:@"%zd/%zd", compsDate.month, compsDate.day];
    }
    else
    {
        return [NSString stringWithFormat:@"%zd/%zd/%zd", compsDate.year, compsDate.month, compsDate.day];
    }
    return strDate;
}

+(NSString*)getDateInfo:(NSString*)strDate
{
    if (nil==strDate || strDate.length==0) {
        return @"";
    }
    
    static int hour = 60*60;
    static NSUInteger uintFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSCalendarUnitSecond;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:strDate];
    
    if (nil==date) {
        return @"";
    }
    
    NSDateComponents* compsDate = [calendar components:uintFlags fromDate:date];
    NSDateComponents* compsNow = [calendar components:uintFlags fromDate:[NSDate date]];
    NSDateComponents* compsYesterday = [calendar components:uintFlags fromDate:[NSDate date]];
    compsYesterday.day -= 1;
    NSDate* dateYesterday= [calendar dateFromComponents:compsYesterday];
    compsYesterday = [calendar components:uintFlags fromDate:dateYesterday];
    
    long lInterval = 0-date.timeIntervalSinceNow;   // 秒
    
    if (lInterval < 0)
    {
        NSDateComponents* compsTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsTomorrow.day += 1;
        NSDate* dateTomorrow= [calendar dateFromComponents:compsTomorrow];
        compsYesterday = [calendar components:uintFlags fromDate:dateTomorrow];
        
        NSDateComponents* compsAfterTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsAfterTomorrow.day += 2;
        NSDate* dateAfterTomorrow = [calendar dateFromComponents:compsAfterTomorrow];
        compsAfterTomorrow = [calendar components:uintFlags fromDate:dateAfterTomorrow];
        
        if (compsNow.year==compsDate.year && compsNow.month==compsDate.month && compsNow.day==compsDate.day) {
            return [NSString stringWithFormat:@"今天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
            return [NSString stringWithFormat:@"明天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (compsAfterTomorrow.year==compsDate.year && compsAfterTomorrow.month==compsDate.month && compsAfterTomorrow.day==compsDate.day) {
            return [NSString stringWithFormat:@"后天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else
        {
            return [NSString stringWithFormat:@"%d/%d/%d", (int)compsDate.year, (int)compsDate.month, (int)compsDate.day];
        }
    }
    else if (lInterval < (hour/12)) {
        return @"刚刚";
    }
    else if (lInterval < hour) {
        return [NSString stringWithFormat:@"%d分钟前", (int)lInterval/(hour/60)];
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month &&compsDate.day == compsNow.day){
        NSInteger nHour = compsDate.hour;
        if (0<=nHour && nHour<6) {
            return [NSString stringWithFormat:@"凌晨 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (6<=nHour && nHour<8) {
            return [NSString stringWithFormat:@"早上 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (8<=nHour && nHour<12) {
            return [NSString stringWithFormat:@"上午 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (12<=nHour && nHour<13) {
            return [NSString stringWithFormat:@"中午 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (13<=nHour && nHour<18) {
            return [NSString stringWithFormat:@"下午 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (18<=nHour && nHour<24) {
            return [NSString stringWithFormat:@"晚上 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
        return [NSString stringWithFormat:@"昨天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
    }
    else {
        return [NSString stringWithFormat:@"%d/%d/%d", (int)compsDate.year, (int)compsDate.month, (int)compsDate.day];
    }
    
    return strDate;
}

+(NSString*)getDateOfDebt:(NSString*)strDate
{
    if (nil==strDate || strDate.length==0) {
        return @"";
    }
    
    //  static int hour = 60*60;
    static NSUInteger uintFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSCalendarUnitSecond;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:strDate];
    
    if (nil==date) {
        return @"";
    }
    
    NSDateComponents* compsDate = [calendar components:uintFlags fromDate:date];
    NSDateComponents* compsNow = [calendar components:uintFlags fromDate:[NSDate date]];
    NSDateComponents* compsYesterday = [calendar components:uintFlags fromDate:[NSDate date]];
    compsYesterday.day -= 1;
    NSDate* dateYesterday= [calendar dateFromComponents:compsYesterday];
    compsYesterday = [calendar components:uintFlags fromDate:dateYesterday];
    
    NSDateComponents* compsBeforeYesterday = [calendar components:uintFlags fromDate:[NSDate date]];
    compsBeforeYesterday.day -= 2;
    NSDate* dateBeforeYesterday= [calendar dateFromComponents:compsBeforeYesterday];
    compsBeforeYesterday = [calendar components:uintFlags fromDate:dateBeforeYesterday];
    
    long lInterval = 0-date.timeIntervalSinceNow;   // 秒
    
    if (lInterval < 0)
    {
        NSDateComponents* compsTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsTomorrow.day += 1;
        NSDate* dateTomorrow= [calendar dateFromComponents:compsTomorrow];
        compsYesterday = [calendar components:uintFlags fromDate:dateTomorrow];
        
        NSDateComponents* compsAfterTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsAfterTomorrow.day += 2;
        NSDate* dateAfterTomorrow = [calendar dateFromComponents:compsAfterTomorrow];
        compsAfterTomorrow = [calendar components:uintFlags fromDate:dateAfterTomorrow];
        
        if (compsNow.year==compsDate.year && compsNow.month==compsDate.month && compsNow.day==compsDate.day) {
            return [NSString stringWithFormat:@"今天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
            return [NSString stringWithFormat:@"明天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else if (compsAfterTomorrow.year==compsDate.year && compsAfterTomorrow.month==compsDate.month && compsAfterTomorrow.day==compsDate.day) {
            return [NSString stringWithFormat:@"后天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
        }
        else
        {
            if (compsNow.year == compsDate.year) {
                return [NSString stringWithFormat:@"%d/%d %d:%02d", (int)compsDate.month, (int)compsDate.day, (int)compsDate.hour, (int)compsDate.minute];
            }else{
                return [NSString stringWithFormat:@"%d/%d/%d %d:%02d", (int)compsDate.year, (int)compsDate.month, (int)compsDate.day, (int)compsDate.hour, (int)compsDate.minute];
            }
        }
        
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month &&compsDate.day == compsNow.day){
        return [NSString stringWithFormat:@"今天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
        return [NSString stringWithFormat:@"昨天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
    }
    else if (compsBeforeYesterday.year==compsDate.year && compsBeforeYesterday.month==compsDate.month && compsBeforeYesterday.day==compsDate.day) {
        return [NSString stringWithFormat:@"前天 %d:%02d", (int)compsDate.hour, (int)compsDate.minute];
    }
    else {
        if (compsNow.year == compsDate.year) {
            return [NSString stringWithFormat:@"%d/%d %d:%02d",(int)compsDate.month, (int)compsDate.day, (int)compsDate.hour, (int)compsDate.minute];
        }else{
            return [NSString stringWithFormat:@"%d/%d/%d %d:%02d", (int)compsDate.year, (int)compsDate.month, (int)compsDate.day, (int)compsDate.hour, (int)compsDate.minute];
        }
        
    }
    
    return strDate;
}

+ (BOOL)isFutureWithTimeStr:(NSString *)timeStr
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    
    NSDate* dateGet = [formatter dateFromString:timeStr];
    NSTimeZone *zone1 = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone1 secondsFromGMTForDate:dateGet];
    NSDate *inputDate = [dateGet dateByAddingTimeInterval:interval1];
    
    //本地当前时间
    NSDate *datenow = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localDate = [datenow dateByAddingTimeInterval:interval];
    
    if ((long)[inputDate timeIntervalSince1970]>(long)[localDate timeIntervalSince1970]) {
        return YES;
    }else{
        return NO;
    }
}

+(NSString*)getTimeInfo:(NSString*)strDate
{
    if (nil==strDate || strDate.length==0) {
        return @"";
    }
    
    static NSUInteger uintFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSCalendarUnitSecond;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:strDate];
    
    if (nil == date)
    {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        date = [formatter dateFromString:strDate];
    }
    
    if (nil==date) {
        return @"";
    }
    
    NSDateComponents* compsDate = [calendar components:uintFlags fromDate:date];
    NSDateComponents* compsNow = [calendar components:uintFlags fromDate:[NSDate date]];
    NSDateComponents* compsYesterday = [calendar components:uintFlags fromDate:[NSDate date]];
    compsYesterday.day -= 1;
    NSDate* dateYesterday= [calendar dateFromComponents:compsYesterday];
    compsYesterday = [calendar components:uintFlags fromDate:dateYesterday];
    
    long lInterval = 0-date.timeIntervalSinceNow;   // 秒
    
    if (lInterval < 0){
        NSDateComponents* compsTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsTomorrow.day += 1;
        NSDate* dateTomorrow= [calendar dateFromComponents:compsTomorrow];
        compsYesterday = [calendar components:uintFlags fromDate:dateTomorrow];
        
        NSDateComponents* compsAfterTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsAfterTomorrow.day += 2;
        NSDate* dateAfterTomorrow = [calendar dateFromComponents:compsAfterTomorrow];
        compsAfterTomorrow = [calendar components:uintFlags fromDate:dateAfterTomorrow];
        
        if (compsNow.year==compsDate.year && compsNow.month==compsDate.month && compsNow.day==compsDate.day) {
            return [NSString stringWithFormat:@"今天 %zd:%02zd", compsDate.hour, compsDate.minute];
        }
        else
        {
            return [NSString stringWithFormat:@"%zd/%zd/%zd %zd:%zd:%zd", compsDate.year, compsDate.month, compsDate.day, compsDate.hour, compsDate.minute, compsDate.minute];
        }
    }
    //    else if (lInterval < (hour/12))
    //    {
    //        return @"刚刚";
    //    }
    //    else if (lInterval < hour) {
    //        return [NSString stringWithFormat:@"%02zd分钟前", lInterval/(hour/60)];
    //    }
    else if (compsNow.year==compsDate.year && compsNow.month==compsDate.month &&compsDate.day == compsNow.day){
        NSInteger nHour = compsDate.hour;
        //凌晨
        if (0<=nHour && nHour<6) {
            return [NSString stringWithFormat:@"%zd:%02zd", compsDate.hour, compsDate.minute];
        }
        //早上
        else if (6<=nHour && nHour<8) {
            return [NSString stringWithFormat:@"%zd:%02zd", compsDate.hour, compsDate.minute];
        }
        //上午
        else if (8<=nHour && nHour<12) {
            return [NSString stringWithFormat:@"%zd:%02zd", compsDate.hour, compsDate.minute];
        }
        //中午
        else if (12<=nHour && nHour<13) {
            return [NSString stringWithFormat:@"%zd:%02zd", compsDate.hour, compsDate.minute];
        }
        //下午
        else if (13<=nHour && nHour<18) {
            return [NSString stringWithFormat:@"%zd:%02zd", compsDate.hour, compsDate.minute];
        }
        //晚上
        else if (18<=nHour && nHour<24) {
            return [NSString stringWithFormat:@"%zd:%02zd", compsDate.hour, compsDate.minute];
        }
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day)
    {
        return [NSString stringWithFormat:@"昨天 %zd:%02zd", compsDate.hour, compsDate.minute];
    }
    else if (compsNow.year==compsDate.year)
    {
        return [NSString stringWithFormat:@"%zd月%zd日 %zd:%02zd", compsDate.month, compsDate.day, compsDate.hour, compsDate.minute];
    }
    else
    {
        return [NSString stringWithFormat:@"%zd/%zd/%zd %zd:%02zd", compsDate.year, compsDate.month, compsDate.day, compsDate.hour, compsDate.minute];
    }
    
    return strDate;
}

+(NSString*)getTimeString:(NSString*)strDate
{
    if (nil==strDate || strDate.length==0) {
        return @"";
    }
    
    static NSUInteger uintFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSCalendarUnitSecond;
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:strDate];
    
    if (nil==date) {
        return @"";
    }
    
    NSDateComponents* compsDate = [calendar components:uintFlags fromDate:date];
    NSDateComponents* compsNow = [calendar components:uintFlags fromDate:[NSDate date]];
    NSDateComponents* compsYesterday = [calendar components:uintFlags fromDate:[NSDate date]];
    compsYesterday.day -= 1;
    NSDate* dateYesterday= [calendar dateFromComponents:compsYesterday];
    compsYesterday = [calendar components:uintFlags fromDate:dateYesterday];
    
    long lInterval = 0-date.timeIntervalSinceNow;   // 秒
    
    if (lInterval < 0){
        NSDateComponents* compsTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsTomorrow.day += 1;
        NSDate* dateTomorrow= [calendar dateFromComponents:compsTomorrow];
        compsYesterday = [calendar components:uintFlags fromDate:dateTomorrow];
        
        NSDateComponents* compsAfterTomorrow = [calendar components:uintFlags fromDate:[NSDate date]];
        compsAfterTomorrow.day += 2;
        NSDate* dateAfterTomorrow = [calendar dateFromComponents:compsAfterTomorrow];
        compsAfterTomorrow = [calendar components:uintFlags fromDate:dateAfterTomorrow];
        
        if (compsNow.year==compsDate.year && compsNow.month==compsDate.month && compsNow.day==compsDate.day) {
            return @"今天";
        }
        else
        {
            return [NSString stringWithFormat:@"%02zd/%02zd/%02zd", compsDate.year, compsDate.month, compsDate.day];
        }
    }
    else if (compsNow.year==compsDate.year && compsNow.month==compsDate.month &&compsDate.day == compsNow.day){
        return @"今天";
    }
    else if (compsYesterday.year==compsDate.year && compsYesterday.month==compsDate.month && compsYesterday.day==compsDate.day) {
        return @"昨天";
    }
    else if (compsNow.year==compsDate.year) {
        return [NSString stringWithFormat:@"%02zd/%02zd", compsDate.month, compsDate.day];
    }
    else {
        return [NSString stringWithFormat:@"%02zd/%02zd/%02zd", compsDate.year, compsDate.month, compsDate.day];
    }
    
    return strDate;
}

+ (NSString *)getAgeWithBirthday:(NSString *)birthday
{
    if (birthday.length > 4)
    {
        NSString *str1 = [birthday substringToIndex:4];
        NSString *now = [NSString stringFromDate:nil];
        NSString *str2 = [now substringToIndex:4];
        NSInteger value = [str2 integerValue] - [str1 integerValue];
        if (value > 0)
        {
            return [NSString stringWithFormat:@"%zd", value];
        }
    }
    return @"";
}
@end

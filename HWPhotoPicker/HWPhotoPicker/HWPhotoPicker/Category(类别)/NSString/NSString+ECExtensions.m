//
//  NSString+ECExtensions.m
//  ECDoctor
//
//  Created by linsen on 15/8/18.
//  Copyright (c) 2015年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import "NSString+ECExtensions.h"
#import "GlobalHeader.h"

@implementation NSString (ECExtensions)
#pragma mark 判断字符串是否为空
- (BOOL)isEmpty
{
    if ([self length] <= 0 || self == (id)[NSNull null] || self == nil) {
        return YES;
    }
    return NO;
}

#pragma mark 判断是否不为空字符串
- (BOOL)isValid
{
    return (self == nil || ![self isKindOfClass:[NSString class]] || [[self removeWhiteSpacesFromString] isEqualToString:@""] || [self isEqualToString:@"(null)"]) ? NO :YES;
}

- (BOOL)isValidMoblieNum
{
    if ([self isValid])
    {
        NSString *phoneRegex = @"^((13)|(14)|(15)|(16)|(17)|(18))\\d{9}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        return [phoneTest evaluateWithObject:self];
    }
    return NO;
}

- (NSString *)stringEmptyTransform
{
    if (self == nil || self == (id)[NSNull null])
    {
        return @"";
    }
    if (![self isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"%@", self];
    }
    return self;
}

+ (NSString *)stringEmptyTransform:(NSString *)originalStr
{
    if (originalStr == nil || originalStr == (id)[NSNull null])
    {
        return @"";
    }
    if (![originalStr isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"%@", originalStr];
    }
    return originalStr;
}



- (NSString *)URLEncodedString
{
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, (__bridge CFStringRef)@":/?&=;+!@#$()',*", kCFStringEncodingUTF8);
    //return (NSString *)CFBridgingRelease(encodedString);
}

+ (NSString *)getPinyinWithStr:(NSString *)str
{
  str = [NSString stringEmptyTransform:str];
  if (str.length > 0)
  {
    NSMutableString *ms = [[NSMutableString alloc] initWithString:str];
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
      DLog(@"pinyin: %@", ms);
    }
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
      DLog(@"pinyin: %@", ms);
    }
    NSString *tempStr = [ms stringByReplacingOccurrencesOfString:@" " withString:@""];
    tempStr = [tempStr uppercaseString];
    return tempStr;
  }
  return str;
}

#pragma mark 移除字符串两边空格
- (NSString *)removeWhiteSpacesFromString
{
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

#pragma mark 检测字符串是否包含某字符串
- (BOOL)containsString:(NSString *)subString
{
  if (![subString isValid]) {
    subString = @"";
  }
    return ([self rangeOfString:subString].location == NSNotFound) ? NO : YES;
}

#pragma mark 替换字符串
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar
{
    return  [self stringByReplacingOccurrencesOfString:olderChar withString:newerChar];
}

#pragma mark 移除子字符串
- (NSString *)removeSubString:(NSString *)subString
{
    if ([self containsString:subString])
    {
        NSRange range = [self rangeOfString:subString];
        return  [self stringByReplacingCharactersInRange:range withString:@""];
    }
    return self;
}

#pragma mark 根据字典替换字符串
- (NSString *)stringByReplacingStringsFromDictionary:(NSDictionary *)dict
{
    NSMutableString *string = [self mutableCopy];
    for (NSString *target in dict)
    {
        [string replaceOccurrencesOfString:target
                                withString:[dict objectForKey:target]
                                   options:0
                                     range:NSMakeRange(0, [string length])];
    }
    return string;
}

#pragma mark 预定义的HTML实体转换为字符
- (NSString *)specialCharsDecode
{
    NSString *string = self;
    NSArray *strings = [NSArray arrayWithObjects:@"&nbsp;",@"&amp;",@"&lt;",@"&gt;",@"&quot;",@"&#39;", nil];
    for (NSString *stringName in strings)
    {
        NSRange foundObj = [string rangeOfString:stringName options:NSCaseInsensitiveSearch];
        if (foundObj.length > 0)
        {
            if ([stringName isEqualToString:@"&nbsp;"]) {
                string = [string stringByReplacingOccurrencesOfString:stringName withString:@" "];
            }
            if ([stringName isEqualToString:@"&amp;"]) {
                string = [string stringByReplacingOccurrencesOfString:stringName withString:@"&"];
            }
            if ([stringName isEqualToString:@"&lt;"]) {
                string = [string stringByReplacingOccurrencesOfString:stringName withString:@"<"];
            }
            if ([stringName isEqualToString:@"&gt;"]) {
                string = [string stringByReplacingOccurrencesOfString:stringName withString:@">"];
            }
            if ([stringName isEqualToString:@"&quot;"]) {
                string = [string stringByReplacingOccurrencesOfString:stringName withString:@""];
            }
            if ([stringName isEqualToString:@"&#39;"]) {
                string = [string stringByReplacingOccurrencesOfString:stringName withString:@"'"];
            }
            string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        }
    }
    return string;
}

#pragma mark 格式化文件大小单位
+ (NSString *)converseUnitK:(long long)size
{
    long GSize = 1 * 1024 * 1024 * 1024; //1G等于这么多B
    long MBSize = 1 * 1024 * 1024;       //1MB等于这么多B
    long KBSize = 1 * 1024;
    
    NSString *sizeString = @"";
    if (size >= GSize) {
        //说明大小已经到G以上了
        unsigned long long kb = size / 1024;
        unsigned long long mb = kb / 1024;
        unsigned long long G = mb / 1024;
        sizeString = [[NSString alloc] initWithFormat:@"%lldG",G];
    }
    else if (size > MBSize) {
        //说明大小在M 和 G 之间
        unsigned long long kb = size / 1024;
        unsigned long long mb = kb / 1024;
        sizeString = [[NSString alloc] initWithFormat:@"%lldMB",mb];
    }
    else if (size > KBSize) {
        unsigned long long kb = size / 1024;
        sizeString = [[NSString alloc] initWithFormat:@"%lldKB",kb];
    }
    else if (size <= KBSize){
        unsigned long long kb = size;
        sizeString = [[NSString alloc] initWithFormat:@"%lldB",kb];
    }
    return sizeString;
}


#pragma mark 时间戳转文件列表时间
- (NSString *)timestampFormat
{
    NSString *timestamp = self;
    if (nil == timestamp) {
        return nil;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]; // zh_CN en_US
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark 讨论信息列表时间戳转换
- (NSString *)discussionTimestampFormat
{
    NSString *timestamp = [self timestampFormat];
    if (nil == timestamp) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDate *date = [formatter dateFromString:timestamp];
    NSDate *now = [NSDate date];
    
    // 比较发送时间和当前时间
    NSTimeInterval delta = [now timeIntervalSinceDate:date];
    
    if (delta < 60) {
        // 1分钟以内
        return @"刚刚";
    }
    else if (delta < 60 * 60) {
        // 60分钟以内
        return [[NSString alloc] initWithFormat:@"%.f分钟前", delta/60];
    }
    else if (delta < 60 * 60 * 24) {
        // 24小时内
        return [[NSString alloc] initWithFormat:@"%.f小时前", delta/(60 * 60)];
    }
    
    return timestamp;
}









+(NSString*)strmethodComma:(NSString *)string
{
  string = [NSString stringEmptyTransform:string];
    if (![string isValid])
    {
        return @"0.00";
    }
  double floatValue = [string doubleValue];
  floatValue = nearbyint(floatValue*100);
  floatValue = floatValue/100.00;
  string = [NSString stringWithFormat:@"%f", floatValue];
    NSString *sign = nil;
    if ([string hasPrefix:@"-"]||[string hasPrefix:@"+"])
    {
        sign = [string substringToIndex:1];
        string = [string substringFromIndex:1];
    }
    NSArray *array = [string componentsSeparatedByString:@"."];
    if ([array count] > 0)
    {
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
        NSString *tempStr = array[0];
        NSInteger i = tempStr.length;
        NSInteger j = tempStr.length;
        while (j > 0) {
            j--;
            if (i - j == 3 || j == 0)
            {
                [values insertObject:[tempStr substringWithRange:NSMakeRange(j, i-j)] atIndex:0];
                i = j;
            }
        }
        if ([values count] > 0)
        {
            string = [values componentsJoinedByString:@","];
        }
        else
        {
            string = @"0";
        }
        if ([array count] > 1)
        {
            tempStr = array[1];
        }
        else
        {
            tempStr = @"";
        }
        if (tempStr.length > 2)
        {
            tempStr = [tempStr substringWithRange:NSMakeRange(0, 2)];
        }
        while (tempStr.length < 2)
        {
            tempStr = [tempStr stringByAppendingString:@"0"];
        }
        string = [string stringByAppendingFormat:@".%@", tempStr];
        
    }
    else
    {
        string = @"0.00";
    }
    if (sign)
    {
        string = [NSString stringWithFormat:@"%@%@", sign, string];
        //string = [NSString stringWithFormat:@"%@", string];
    }
    return string;
}



+ (NSString *)getGUID
{
    NSString* strGUID = nil;
    unsigned   unTime = (unsigned)time(0);
    unsigned   num1 = arc4random() % 100;
    unsigned   num2 = arc4random() % 100;
    unsigned   num3 = arc4random() % 100;
    unsigned   num4 = arc4random() % 10;
    //unsigned   num5 = arc4random() % 100;
    strGUID = [NSString stringWithFormat:@"%d%02d%02d%02d%d", unTime, num1, num2, num3, num4];
  //strGUID = [NSString stringWithFormat:@"%d%02d%02d%02d%02d%02d", unTime, num1, num2, num3, num4, num5];
    return strGUID;
}

+(NSString *)filtrateStringContainTransformSubstring:(NSString *)targetStr
{
  if (![targetStr isValid]) {
    return @"";
  }
  targetStr = [[targetStr stringByReplacingOccurrencesOfString:@"\t" withString:@""] mutableCopy];
  targetStr = [[targetStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "] mutableCopy];
  NSString *overViewStr = targetStr;
  NSInteger index = 0;
  while (overViewStr.length  > index) {
    NSString *tempStr = [overViewStr substringWithRange:NSMakeRange(index, 1)];
    if ([tempStr isEqualToString:@" "]) {
      index++;
    }else if([tempStr isEqualToString:@"\t"]||[tempStr isEqualToString:@"\n"]||[tempStr isEqualToString:@"\r"]){
      index++;
    }else{
      break;
    }
  }
  if (index > 0) {
    overViewStr = [overViewStr stringByReplacingCharactersInRange:NSMakeRange(0, index) withString:@""];
  }

  return overViewStr;
}

//截取url中参数
+ (NSString *)getParamValueFromUrl:(NSString *)url paramName:(NSString *)paramName
{
  if (![paramName hasSuffix:@"="]) {
    paramName = [NSString stringWithFormat:@"%@=", paramName];
  }
  
  NSString *str = nil;
  NSRange   start = [url rangeOfString:paramName];
  if (start.location != NSNotFound) {
    // confirm that the parameter is not a partial name match
    unichar  c = '?';
    if (start.location != 0) {
      c = [url characterAtIndex:start.location - 1];
    }
    if (c == '?' || c == '&' || c == '#') {
      NSRange     end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
      NSUInteger  offset = start.location + start.length;
      str = end.location == NSNotFound ?
      [url substringFromIndex:offset] :
      [url substringWithRange:NSMakeRange(offset, end.location)];
      str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
  }
  return str;
}


/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters
{
    
    // 查找参数
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [self substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum
{
    NSString *arabicNumStr = [NSString stringWithFormat:@"%ld",(long)arabicNum];
    NSArray *arabicNumeralsArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"];
    NSArray *chineseNumeralsArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零"];
    NSArray *digits = @[@"个",@"十",@"百",@"千",@"万",@"十",@"百",@"千",@"亿",@"十",@"百",@"千",@"兆"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:chineseNumeralsArray forKeys:arabicNumeralsArray];
    
    if (arabicNum < 20 && arabicNum > 9) {
        if (arabicNum == 10) {
            return @"十";
        }else{
            NSString *subStr1 = [arabicNumStr substringWithRange:NSMakeRange(1, 1)];
            NSString *a1 = [dictionary objectForKey:subStr1];
            NSString *chinese1 = [NSString stringWithFormat:@"十%@",a1];
            return chinese1;
        }
    }else{
        NSMutableArray *sums = [NSMutableArray array];
        for (int i = 0; i < arabicNumStr.length; i ++)
        {
            NSString *substr = [arabicNumStr substringWithRange:NSMakeRange(i, 1)];
            NSString *a = [dictionary objectForKey:substr];
            NSString *b = digits[arabicNumStr.length -i-1];
            NSString *sum = [a stringByAppendingString:b];
            if ([a isEqualToString:chineseNumeralsArray[9]])
            {
                if([b isEqualToString:digits[4]] || [b isEqualToString:digits[8]])
                {
                    sum = b;
                    if ([[sums lastObject] isEqualToString:chineseNumeralsArray[9]])
                    {
                        [sums removeLastObject];
                    }
                }else
                {
                    sum = chineseNumeralsArray[9];
                }
                
                if ([[sums lastObject] isEqualToString:sum])
                {
                    continue;
                }
            }
            
            [sums addObject:sum];
        }
        NSString *sumStr = [sums  componentsJoinedByString:@""];
        NSString *chinese = [sumStr substringToIndex:sumStr.length-1];
        return chinese;
    }
}


@end

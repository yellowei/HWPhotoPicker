//
//  NSString+ECExtensions.h
//  ECDoctor
//
//  Created by linsen on 15/8/18.
//  Copyright (c) 2015年 EasyCloud Health Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (ECExtensions)
/**
 *  判断字符串是否为空
 *
 *  @return YES为空 NO则否
 */
- (BOOL)isEmpty;

/**
 *  判断是否不为空字符串
 *
 *  @return YES是不为空字符串 NO则否
 */
- (BOOL)isValid;
/**
 *  判断是否是电话号码
 *
 *  @return YES是不为空字符串 NO则否
 */
- (BOOL)isValidMoblieNum;

/**
 *	@brief	字符串空处理
 *
 *	@return	处理后字符串
 *
 *	Created by mac on 2015-08-21 10:16
 */
- (NSString *)stringEmptyTransform;

+ (NSString *)stringEmptyTransform:(NSString *)originalStr;


- (NSString *)URLEncodedString;

+ (NSString *)getPinyinWithStr:(NSString *)str;

/**
 *  移除字符串两边空格
 *
 *  @return 返回过滤后的字符串
 */
- (NSString *)removeWhiteSpacesFromString;

/**
 *  检测字符串是否包含某字符串
 *
 *  @param subString 被包含字符串
 *
 *  @return YES包含 NO则否
 */
- (BOOL)containsString:(NSString *)subString;

/**
 *  替换字符串
 *
 *  @param olderChar 被替换字符串
 *  @param newerChar 替换新的字符串
 *
 *  @return 被替换过的字符串
 */
- (NSString *)replaceCharcter:(NSString *)olderChar withCharcter:(NSString *)newerChar;

/**
 *  移除子字符串
 *
 *  @param subString 被移除的字符串
 *
 *  @return 移除后的字符串
 */
- (NSString *)removeSubString:(NSString *)subString;

/**
 *  根据字典替换字符串
 *
 *  @param dict 替换字典
 *
 *  @return 替换过的字符串
 */
- (NSString *)stringByReplacingStringsFromDictionary:(NSDictionary *)dict;

/**
 *  预定义的HTML实体转换为字符
 *
 *  @return 处理过的字符
 */
- (NSString *)specialCharsDecode;

/**
 *  格式化文件大小单位
 *
 *  @param size 文件大小(字节)
 *
 *  @return 包含大小单位的字符串
 */
+ (NSString *)converseUnitK:(long long)size;



/**
 *	@brief	金额转换
 *
 *	@param 	string 原始字符串
 *
 *	@return	处理后字符串（1,234,378.00）
 *
 *	Created by mac on 2015-09-15 20:57
 */
+(NSString*)strmethodComma:(NSString *)string;





/**
 *	@brief	获取随机GUID
 *
 *	@return	<#return value description#>
 *
 *	Created by mac on 2015-09-15 20:57
 */
+ (NSString *)getGUID;

/**
 *	@brief	过滤包含转义字符的字符串
 *
 *	@return	过滤后的字符串
 *
 *	Created by mac on 2015-09-15 20:57
 */
+(NSString *)filtrateStringContainTransformSubstring:(NSString *)targetStr;

/**
 *  截取url中参数
 *
 *  @param url       url
 *  @param paramName 参数key
 *
 *  @return 参数详情
 */
+ (NSString *)getParamValueFromUrl:(NSString *)url paramName:(NSString *)paramName;



/**
 *  字符串MD5加密
 */
+ (NSString *)md5HexDigest:(NSString*)input;


/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters;


/**
 *  将阿拉伯数字转换为中文数字
 */
+(NSString *)translationArabicNum:(NSInteger)arabicNum;

@end

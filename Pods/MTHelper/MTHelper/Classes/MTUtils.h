//
//  MTUtils.h
//  MTNOP
//
//  Created by renwanqian on 14-4-16.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <UIKit/UIKit.h>

#define __BASE64( text )        [MTUtils base64StringFromText:text]
#define __TEXT( base64 )        [MTUtils textFromBase64String:base64]

@interface MTUtils : NSObject


+ (NSInteger)signalLevel:(NSInteger)signal;
+ (CGFloat)degreeToRadian:(CGFloat)degree;
+ (CGFloat)standardDeviationWithDatas:(NSArray *)datas avgValue:(CGFloat)avgValue;
+ (NSString *)networkTypecategorized:(NSString *)networkType;
+ (NSString *)radioTypeWithRadioAccessTechnology:(NSString *)currentRadioAccessTechnology;

+ (NSString *)cgiStringWithNoTag:(NSString*)network lac:(int)lac ci:(int)ci;
+ (NSString *)cgiStringWithTag:(NSString*)network lac:(int)lac ci:(int)ci;
+ (NSString *)cellString:(NSString*)network lac:(int)lac ci:(int)ci separator:(NSString*)separator;

/**
 *  获取 NSDocumentDirectory 地址
 *
 *  @return NSDocumentDirectory 地址
 */
+ (NSString *)getRootPath;
+ (NSString *)storePath:(NSString *)fileName;//文件存储方法封装

+(BOOL) NSStringIsValidEmail:(NSString *)checkString;
/******************************************************************************
 函数名称 : + (NSString *)base64StringFromText:(NSString *)text
 函数描述 : 将文本转换为base64格式字符串
 输入参数 : (NSString *)text    文本
 输出参数 : N/A
 返回参数 : (NSString *)    base64格式字符串
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64StringFromText:(NSString *)text;
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
/******************************************************************************
 函数名称 : + (NSString *)textFromBase64String:(NSString *)base64
 函数描述 : 将base64格式字符串转换为文本
 输入参数 : (NSString *)base64  base64格式字符串
 输出参数 : N/A
 返回参数 : (NSString *)    文本
 备注信息 :
 ******************************************************************************/
+ (NSString *)textFromBase64String:(NSString *)base64;
+ (NSString *)base64EncodedStringFrom:(NSData *)data;

+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key;
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key;
@end

@interface NSString (size)
- (CGSize)sizeWithAttributeFont:(UIFont *)font;
- (CGSize)sizeWithAttributeFont:(UIFont *)font forWidth:(int)width;

@end


@interface UIImage (colorsize)

+ (UIImage *)imageWithColor:(UIColor *)color;
-(UIImage*)resize:(CGSize)size;
@end

@interface UIColor (html)
/**
 *  UIColor with html format
 *
 *  @param e.g. value 0xFFFF0000 for red.
 *
 *  @return color
 */
+ (UIColor *)colorWithHtmlFormat:(NSUInteger)value;
/**
 *  UIColor with hex string format
 *
 *  @param e.g. color 0xFFFF00 for red.
 *
 *  @return color
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

+ (UIColor *)colorWithHexString:(NSString *)color alpha :(CGFloat)alpha;
/**
 *  hex string format of UIColor
 *
 *  @param color
 *
 *  @return e.g. color 0xFFFF00 for red.
 */
+ (NSString*)hexStringOfColor:(UIColor*)color;

 

@end

@interface UIView (grand)

- (void)setGradientBackground;

@end

@interface NSMutableDictionary (allowNil)

- (void)setObjectOrNil:(id)anObject forKey:(id <NSCopying> )aKey;

@end

@interface NSDate (MTUtils)
+ (NSString *)currentDateString;
+ (NSString *)currentDateStringWithMillis;
+ (NSString*)dayStringFromNow:(int)days;
+ (NSString*)monthStringFromNow:(int)months;

+ (NSString*)stringFromDate:(NSDate*)date dateFormat:(NSString *)dateFormat;
+ (NSString *)dateFormat2String:(NSDate*)date withFormat :(NSString*) format;

+ (NSDate*)dateFromString:(NSString*)dateString dateFormat:(NSString *)dateFormat;
+ (NSDate*)dateFromYMD:(int)year month:(int)month day:(int)day;
+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate todays:(int)days;
+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate tomonths:(int)months;

+ (long long)currentTimeMillis;


- (NSString *)dateStringWithFormat:(NSString *)format;



@end

@interface NSString (converter)

+(NSString*)fromInt:(int)value;
+(NSString*)fromFloat:(float)value;
+(NSString*)fromFloat:(float)value decimal:(int)decimal;
+(NSString*)fromNumber:(NSNumber*)value decimal:(int)decimal;
+(NSString*)fromObject:(id)value;
+(NSString*)fromObject:(id)value decimal:(int)decimal;

@end

/*
@interface NSObject (setValuesAndKeys)

-(void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

@end
 */

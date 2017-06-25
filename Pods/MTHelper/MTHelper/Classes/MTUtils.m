//
//  MTUtils.m
//  MTNOP
//
//  Created by renwanqian on 14-4-16.
//  Copyright (c) 2014年 cn.mastercom. All rights reserved.
//



#import "MTUtils.h"
#import "UIDevice+Cell.h"
#import <QuartzCore/QuartzCore.h>
#include <math.h>
#include <sys/time.h>



//空字符串
#define     LocalStr_None           @""

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation MTUtils


+(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
//
//    
//    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
//    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
//    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
//    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
//    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailTest evaluateWithObject:checkString];
}


+ (NSString *)base64StringFromText:(NSString *)text
{
    if (text && ![text isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY  改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        //IOS 自带DES加密 Begin  改动了此处
        //data = [self DESEncrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [self base64EncodedStringFrom:data];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSString *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        //取项目的bundleIdentifier作为KEY   改动了此处
        //NSString *key = [[NSBundle mainBundle] bundleIdentifier];
        NSData *data = [self dataWithBase64EncodedString:base64];
        //IOS 自带DES解密 Begin    改动了此处
        //data = [self DESDecrypt:data WithKey:key];
        //IOS 自带DES加密 End
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        return LocalStr_None;
    }
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
      
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)dataWithBase64EncodedString:(NSString *)string
 函数描述 : base64格式字符串转换为文本数据
 输入参数 : (NSString *)string
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 :
 ******************************************************************************/
+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    if (string == nil)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        [NSException raise:NSInvalidArgumentException format:nil];
    #pragma clang diagnostic pop
    
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}

/******************************************************************************
 函数名称 : + (NSString *)base64EncodedStringFrom:(NSData *)data
 函数描述 : 文本数据转换为base64格式字符串
 输入参数 : (NSData *)data
 输出参数 : N/A
 返回参数 : (NSString *)
 备注信息 :
 ******************************************************************************/
+ (NSString *)base64EncodedStringFrom:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}


+ (NSInteger)signalLevel:(NSInteger)signal {
    NSInteger levelCount = 10; //bars_ten1 ~ bars_ten10
    CGFloat minSignal = -113.0;
    CGFloat maxSignal = -51.0;
    if (signal <= minSignal) {
        return 0; //bars_ten0
    } else if (signal >= maxSignal) {
        return levelCount; //bars_ten10
    } else {
        return levelCount - floor(((signal - maxSignal) / ((minSignal - maxSignal) / levelCount)));
    }
}

+ (CGFloat)degreeToRadian:(CGFloat)degree {
    return degree * M_PI / 180.0;
}

+ (CGFloat)standardDeviationWithDatas:(NSArray *)datas avgValue:(CGFloat)avgValue {
    NSInteger count = [datas count];
    
    if (count == 0) {
        return 0;
    }
    
    CGFloat sd = 0;
    for (int i = 0; i < count; i++) {
        sd +=  pow([datas[i] floatValue] - avgValue, 2.0);
    }
    
    return [[NSString stringWithFormat:@"%.04f", sqrt(sd / count)] floatValue];
}


+ (NSString *)networkTypecategorized:(NSString *)networkType{
    if(networkType == nil)return @"UNKNOWN";
    
    if([@"EDGE" isEqualToString:networkType] || [@"GPRS" isEqualToString:networkType] || [@"IDEN" isEqualToString:networkType]){
        return @"GSM";
    }else if([@"HSDPA" isEqualToString:networkType] || [@"HSUPA" isEqualToString:networkType] || [@"HSPA" isEqualToString:networkType] || [@"HSPAP" isEqualToString:networkType] || [@"HSPA+" isEqualToString:networkType] || [@"UMTS" isEqualToString:networkType]){
        NSString *mccmnc = [[UIDevice currentDevice].mcc stringByAppendingString:[UIDevice currentDevice].mnc];
        
        if([@"46000" isEqualToString:mccmnc] || [@"46002" isEqualToString:mccmnc] || [@"46007" isEqualToString:mccmnc] || [@"46008" isEqualToString:mccmnc]){
            return @"TD";
        }else if([@"46001" isEqualToString:mccmnc] || [@"46006" isEqualToString:mccmnc]){
            return @"WCDMA";
        }else{
            return @"TD";
        }
    }else if([@"RTT" isEqualToString:networkType] || [@"CDMA" isEqualToString:networkType]){
        return @"CDMA";
    }else if([networkType hasPrefix:@"EVDO"]){
        return @"EVDO";
    }
    
    
    
    return networkType;
}




+ (NSString *)cgiStringWithNoTag:(NSString*)network lac:(int)lac ci:(int)ci{
    if([network isEqualToString:@"LTE"]){
        return [NSString stringWithFormat:@"%d-%d-%d",lac,ci/256,ci%256];
    }else if([network hasPrefix:@"EVDO"]){
        return [NSString stringWithFormat:@"%d-%d-%d",lac,ci/256,ci%256];
    }else{
        return [NSString stringWithFormat:@"%d-%d",lac,ci];
    }
}

+ (NSString *)cgiStringWithTag:(NSString*)network lac:(int)lac ci:(int)ci{
    if([network isEqualToString:@"LTE"]){
        return [NSString stringWithFormat:@"ECGI:%d-%d-%d",lac,ci/256,ci%256];
    }else if([network hasPrefix:@"EVDO"]){
        return [NSString stringWithFormat:@"CGI:%d-%d-%d",lac,ci/256,ci%256];
    }else{
        return [NSString stringWithFormat:@"CGI:%d-%d",lac,ci];
    }
}

+ (NSString *)cellString:(NSString*)network lac:(int)lac ci:(int)ci separator:(NSString*)separator{
    if([network isEqualToString:@"LTE"]){
        return [NSString stringWithFormat:@"TAC:%d%@ECI:%d-%d",lac,separator,ci/256,ci%256];
    }else if([network hasPrefix:@"EVDO"]){
        return [NSString stringWithFormat:@"SID:%d%@NID:%d%@%d",lac,separator,ci/256,separator,ci%256];
    }else{
        return [NSString stringWithFormat:@"LAC:%d%@CI:%d",lac,separator,ci];
    }
}

+ (NSString *)radioTypeWithRadioAccessTechnology:(NSString *)currentRadioAccessTechnology {
    
    if (currentRadioAccessTechnology == nil) {
        return @"UNKNOWN";
    }
    
    return [[currentRadioAccessTechnology stringByReplacingOccurrencesOfString:@"CTRadioAccessTechnology"
                                                                    withString:@""] uppercaseString];
}


+ (NSString *)storePath:(NSString *)fileName {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}


/**
 *  获取 NSDocumentDirectory 地址
 *
 *  @return NSDocumentDirectory 地址
 */
+ (NSString *)getRootPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

@end
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation NSString (size)
- (CGSize) sizeWithAttributeFont:(UIFont *)font{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [self sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
    }else{
        return [self sizeWithFont:font forWidth:MAXFLOAT lineBreakMode:NSLineBreakByCharWrapping];
    }
}

- (CGSize)sizeWithAttributeFont:(UIFont *)font forWidth:(int)width{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName: font} context:nil].size;
    }else{
        return [self sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        
    }
}

@end
#pragma clang diagnostic pop

@implementation  UIImage (colorsize)

+ (UIImage *)imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return image;
}

-(UIImage*)resize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end

@implementation UIColor (html)

+ (UIColor *)colorWithHtmlFormat:(NSUInteger)value {
	NSUInteger alpha = value >> 24;
	NSUInteger red = (value >> 16) & 0xFF;
	NSUInteger green = (value >> 8) & 0xFF;
	NSUInteger blue = value & 0xFF;
    
	return [UIColor colorWithRed:(red / 255.0) green:(green / 255.0) blue:(blue / 255.0) alpha:(alpha / 255.0)];
}

+ (UIColor *)colorWithHexString:(NSString *)color{
    if(color == nil){
        return nil;
    }
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    // String should be 6 or more characters
    if ([cString length] < 6) {
        return nil;
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha :(CGFloat)alpha
{
    if(color == nil){
        return nil;
    }
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    
    // String should be 6 or more characters
    if ([cString length] < 6) {
        return nil;
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
     return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}
+ (NSString*)hexStringOfColor:(UIColor*)color{
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"#%02x%02x%02x",(int)(r*255.0f),(int)(g*255.0f),(int)(b*255.0f)];
}

@end

@implementation UIView (gradient)

- (void)setGradientBackground {
	CAGradientLayer *shadowLayer = [[CAGradientLayer alloc] init];
	shadowLayer.startPoint = CGPointMake(0.0, 0.0);
	shadowLayer.endPoint = CGPointMake(1.0, 0.0);
	shadowLayer.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
	shadowLayer.colors = [NSArray arrayWithObjects:
	                      (id)[[UIColor colorWithHtmlFormat:0xff0f303C] CGColor],
	                      (id)[[UIColor colorWithHtmlFormat:0xff015f79] CGColor],
	                      (id)[[UIColor colorWithHtmlFormat:0xff0f303C] CGColor],
	                      nil];
	[self.layer insertSublayer:shadowLayer atIndex:0];
}

@end

@implementation NSMutableDictionary (allowNil)

- (void)setObjectOrNil:(id)anObject forKey:(id <NSCopying> )aKey {
	if (anObject == nil) {
		[self setObject:@"" forKey:aKey];
	} else {
		[self setObject:anObject forKey:aKey];
	}
}

@end

@implementation NSDate (MTUtils)

+ (NSString *)currentDateString {
    char fmt[32];
    struct timeval tv;
    struct tm *tm;
    
    gettimeofday(&tv, NULL);
    tm = localtime(&tv.tv_sec);
    
    strftime(fmt, sizeof(fmt), "%Y-%m-%d %H:%M:%S", tm);
    
    return [NSString stringWithUTF8String:fmt];
}

+ (NSString *)currentDateStringWithMillis {
    char fmt[32], buf[32];
    struct timeval tv;
    struct tm *tm;
    
    gettimeofday(&tv, NULL);
    tm = localtime(&tv.tv_sec);
    
    strftime(fmt, sizeof(fmt), "%Y-%m-%d %H:%M:%S.%%03u", tm);
    snprintf(buf, sizeof(buf), fmt, tv.tv_usec / 1000);
    
    return [NSString stringWithUTF8String:buf];
}

+(NSString*)dayStringFromNow:(int)days{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:24*3600*days];
    return [NSDate stringFromDate:date dateFormat:@"yyyy-MM-dd"];
}

+(NSString*)monthStringFromNow:(int)months{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:24*3600*30];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    [comps setDay:0];
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:now  options:0];
    return [NSDate stringFromDate:date dateFormat:@"yyyy-MM"];
}


+(NSString*) stringFromDate:(NSDate*)date dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:dateFormat];
    return [formatter stringFromDate:date];
}


+(NSString*) dateFormat2String:(NSDate*)date withFormat: (NSString*) format
{
    NSDateFormatter * dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateStr=[dateFormatter stringFromDate:date];
    return  dateStr;
}

+(NSDate*) dateFromString:(NSString*)dateString dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:dateFormat];
    return [formatter dateFromString:dateString];
}

+(NSDate*) dateFromYMD:(int)year month:(int)month day:(int)day{
    NSString *str = [NSString stringWithFormat:@"%04d-%02d-%02d",year,month,day];
    return [NSDate dateFromString:str dateFormat:@"yyyy-MM-dd"];
}



+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate todays:(int)days
{
    NSDate *dateTemp = [[NSDate alloc]init];
    NSTimeInterval interval = 24*60*60*days;
    dateTemp = [dateTemp initWithTimeInterval:interval sinceDate:beginDate];
    
    return dateTemp;
}

+ (NSDate *)jsDateFromBeginDate:(NSDate *)beginDate tomonths:(int)months
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:months];
    [comps setDay:0];
    return [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:beginDate  options:0];
}


+ (long long)currentTimeMillis {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000LL + tv.tv_usec / 1000;
}

- (NSString *)dateStringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:self];
}

@end

@implementation NSString (converter)
+(NSString*)fromInt:(int)value{
    return [NSString stringWithFormat:@"%d",value];
}
+(NSString*)fromFloat:(float)value{

    return [NSString stringWithFormat:@"%.2f",value];
}
+(NSString*)fromFloat:(float)value decimal:(int)decimal{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:decimal];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    return [formatter stringFromNumber:[NSNumber numberWithFloat:value]];
}

+(NSString*)fromNumber:(NSNumber*)value decimal:(int)decimal{
    if ([self IsEmpty :value]) {
        return nil;
    }
   
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:decimal];
    //因为setRoundingMode方法显示不了小数点前的0，改成了numberStyle方法
//    [formatter setRoundingMode:NSNumberFormatterRoundHalfDown];
    formatter.numberStyle=kCFNumberFormatterRoundFloor;
    
    if ([value doubleValue]<1.0&&[value doubleValue]>-1) {
        return [NSString stringWithFormat:@"%@", [formatter stringFromNumber:value]];
    }
    return [formatter stringFromNumber:value];
}
+ (BOOL) IsEmpty:(id )thing
{
    return thing == nil
    || ([thing isEqual:[NSNull null]]) //JS addition for coredata
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}
+(NSString*)fromObject:(id)value{
    return [self fromObject:value decimal:2];
}
+(NSString*)fromObject:(id)value decimal:(int)decimal{
    if(value == nil || value == [NSNull null]){
        return nil;
    }
    if([value isKindOfClass:NSString.class]){
        return (NSString *)value;
    }else if([value isKindOfClass:NSNumber.class]){
        NSNumber *number = (NSNumber*)value;
        float intv = number.intValue;
        float floatv = number.floatValue;
        if(intv == floatv){
            return [self fromInt:number.intValue];
        }else{
            return [self fromNumber:number decimal:decimal];
        }
    }else{
        return [NSString stringWithFormat:@"%@",value];
    }
}

@end


/*
@implementation NSObject (setValuesAndKeys)

-(void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues{
    if ([self isKindOfClass:[NSDictionary class]]) {
        [self setValuesForKeysWithDictionary:keyedValues];
        return;
    }
    if (![keyedValues isKindOfClass:[NSDictionary class]] || keyedValues == nil) {
        return;
    }
    for (NSString* key in keyedValues) {
        objc_property_t property = class_getProperty(object_getClass(self), [key UTF8String]);
        if (property) {
            
            [self setValue:[keyedValues objectForKey:key] forKey:key];
        }
    }
    
}

@end
 */

//
//  FKLogDocument.m
//  newifi
//
//  Created by test－mac on 2018/4/8.
//  Copyright © 2018年 DT010153. All rights reserved.
//

#import "FKLogDocument.h"

@implementation FKLogDocument

+ (void)printLogDocument
{
#ifdef DEBUG
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"model:%@  name:%@",[device model],[device name]);
    if ([[device model] isEqualToString:@"iPhone"] || [[device model] isEqualToString:@"iPad"]) {
        [self redirectNSLogToDocumentFolder];
    }
#else
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
#endif
}

#pragma mark --- 日志文件 ---

void UncaughtExceptionHandler(NSException* exception)
{
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols];
    //异常发生时的调用栈
    NSMutableString *strSymbols = [[NSMutableString alloc]init];
    //将调用栈平成输出日志的字符串
    for (NSString *str in symbols) {
        [strSymbols appendString:str];
        [strSymbols appendString:@"\r\n"];
    }
    //将crash日志保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"iOSLog"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:logDirectory]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error = %@",[error localizedDescription]);
        }
    }
    
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"UncaughtException.log"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@",- %@ ->[Uncaught Exception]\r\nName:%@,Reason:%@\r\n[Fe Symbols Start]\r\n%@[Fe Symbols End]\r\n\r\n",dateStr,name,reason,strSymbols];
    
    //把错误日志写到文件中
    if (![fileManager fileExistsAtPath:logFilePath]) {
        [crashString writeToFile:logFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }else{
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}

+ (void)redirectNSLogToDocumentFolder{
    //如果已经连接Xcode调试则不输出到文件
    if (isatty(STDOUT_FILENO)) {
        return;
    }
    
    //判定如果是模拟器就不输出
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model]hasSuffix:@"Simulator"]) {
        return;
    }
    //将NSLog打印信息保存到Document目录下的Log文件夹下
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *logDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"iOSLog"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:logDirectory];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * newDate = [NSDate date];
    if (!fileExists) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:logDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"error = %@",[error localizedDescription]);
        }
    }else{
        NSArray * filePaths = [fileManager contentsOfDirectoryAtPath:logDirectory error:nil];
        NSRange range = NSMakeRange(0, 19);
        [filePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
            if (path.length > range.length + range.location) {
                NSString * str = [path substringWithRange:range];
                NSDate * date = [formatter dateFromString:str];
                if (newDate.timeIntervalSince1970 > (date.timeIntervalSince1970 + DAY * 24 * 60 * 60)) {
                    NSError * error;
                    BOOL status = [fileManager removeItemAtPath:[logDirectory stringByAppendingFormat:@"/%@",path] error:&error];
                    if (!status) {
                        NSLog(@"%@",error);
                    }
                }
            }
        }];
    }
    
    //每次启动都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:newDate];
    
    NSString *logFilePath = [logDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    //将log文件输出到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a++", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a++", stderr);
    //捕获Object-C异常日志
    
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

@end

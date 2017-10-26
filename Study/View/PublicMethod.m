//
//  PublicMethod.m
//  PictureHouseKeeper
//
//  Created by 李亚军 on 16/8/16.
//  Copyright © 2016年 zyyj. All rights reserved.
//

#import "PublicMethod.h"
#import <UIKit/UIKit.h>

@implementation PublicMethod

+(void)showAlert:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
}

+(NSString *)getDocumentMainPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return path;
}

+(NSString *)getDocumentImagePath{
    return [[PublicMethod getDocumentMainPath] stringByAppendingPathComponent:DocumentImagePathName];
}

+(NSString *)getDocumentVideoPath{
    return [[PublicMethod getDocumentMainPath] stringByAppendingPathComponent:DocumentVideoPathName];
}


+(void)addNewFolder:(NSString *)name inNextPath:(NSString *)path{
    NSString *allpath = @"";
    if (![name  isEqual: @""]) {
        allpath = [NSString stringWithFormat:@"%@/%@",path,name];
    }else{
        allpath = path;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:allpath]) {
        NSLog(@"文件夹路径已存在。。。");
    }else{
        [fileManager createDirectoryAtPath:allpath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

//判断文件是否已经在沙盒中已经存在？
+(BOOL)isFileExist:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:fileName];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

+(NSString *)getPicName{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyyMMddHHmmssSSS";
    format.timeZone = [NSTimeZone systemTimeZone];
    return [format stringFromDate:[NSDate new]];
}


+(void)saveFileList:(NSMutableArray *)arry{
    if (arry == nil || arry.count<=0) {
        return;
    }
    NSString *path = [[PublicMethod getDocumentMainPath] stringByAppendingPathComponent:FileListName];
    [arry writeToFile:path atomically:YES];
    
}


+(void)deleteFile:(NSString *)path{
    NSFileManager *fileM = [NSFileManager defaultManager];
    if ([fileM fileExistsAtPath:path]) {
        [fileM removeItemAtPath:path error:nil];
    }
}


+(void)savekeyValue:(NSString *)value withKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString *)getValue:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

@end

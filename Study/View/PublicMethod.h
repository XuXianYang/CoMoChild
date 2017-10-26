//
//  PublicMethod.h
//  PictureHouseKeeper
//
//  Created by 李亚军 on 16/8/16.
//  Copyright © 2016年 zyyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicMethod : NSObject

//提示消息
+(void)showAlert:(NSString *)msg;

//获取主路径：比如 Document层级
+(NSString *)getDocumentMainPath;

//获取主路径下保存图片级路径
+(NSString *)getDocumentImagePath;

//获取主路径下保存视频级路径
+(NSString *)getDocumentVideoPath;


//是否存在
+(BOOL)isFileExist:(NSString *)fileName;

//生成文件夹
+(void)addNewFolder:(NSString *)name inNextPath:(NSString *)path;

//保存文件
+(void)saveFileList:(NSMutableArray *)arry;

//删除文件
+(void)deleteFile:(NSString *)path;

//获取日期名称
+(NSString *)getPicName;


//保存字符串
+(void)savekeyValue:(NSString *)value withKey:(NSString *)key;
+(NSString *)getValue:(NSString *)key;
@end

#import <Foundation/Foundation.h>

@interface XXYMyTools : NSObject
//判断字符串是否包含空格
+(BOOL)isEmpty:(NSString *) str;
//判断字符串是否有中文
+(BOOL)isChinese:(NSString *)str;
//判断是否是电话号码
+ (NSString *)valiMobile:(NSString *)mobile;
//判断照相机是否授权
+(BOOL)isCameraValid;
//处理拍照的图片翻转
+ (UIImage *)fixOrientation:(UIImage *)aImage;
@end

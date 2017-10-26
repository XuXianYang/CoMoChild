#import <UIKit/UIKit.h>
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

@interface UIImage (XXYImage)

//去掉渲染图层
+ (instancetype)imageWithOriginalNamed:(NSString *)imageName;

/**
 *  根据图片名自动加载适配iOS6\7的图片
 */
+ (UIImage *)imageWithName:(NSString *)name;

/**
 *  根据图片名返回一张能够自由拉伸的图片
 */
+ (UIImage *)resizedImage:(NSString *)name;

//异步绘制圆角图片
-(void)hq_imageWithCorner:(CGSize)size fillCorlor:(UIColor*)fillCorlor completion:(void(^)(UIImage*image))completion;

@end

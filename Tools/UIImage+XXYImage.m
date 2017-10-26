#import "UIImage+XXYImage.h"

@implementation UIImage (XXYImage)

+ (instancetype)imageWithOriginalNamed:(NSString *)imageName
{
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
+ (UIImage *)imageWithName:(NSString *)name
{
    UIImage *image = nil;
    if (iOS7) { // 处理iOS7的情况
        NSString *newName = [name stringByAppendingString:@"_os7"];
        image = [UIImage imageNamed:newName];
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

+ (UIImage *)resizedImage:(NSString *)name
{
    UIImage *image = [UIImage imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

-(void)hq_imageWithCorner:(CGSize)size fillCorlor:(UIColor*)fillCorlor completion:(void(^)(UIImage*image))completion
{
    //1.利用绘图,建立上下文联系
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIGraphicsBeginImageContextWithOptions(size,YES,0);
        
        CGRect rect=CGRectMake(0, 0, size.width, size.height);
        
        [fillCorlor setFill];
        
        UIRectFill(rect);
        
        //利用贝塞尔路径,裁切效果
        UIBezierPath*path=[UIBezierPath bezierPathWithOvalInRect:rect];
        [path addClip];
        
        //绘制图像
        [self drawInRect:rect];
        
        //取得结果
        UIImage*result=UIGraphicsGetImageFromCurrentImageContext();
        
        //关闭上下文
        UIGraphicsEndImageContext();
        
        //完成回调
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(completion!=nil)
            {
                completion(result);
            }
        });
    });
}
@end

#import "XXYCampusPictureView.h"
#import "XXYCampusDynamicFrame.h"
#import "XXYCampusDynamicModel.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "XXYPreviewPicturesController.h"
#import <DALabeledCircularProgressView.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface XXYCampusPictureView ()

@property(nonatomic,strong)UIImage*videoImage;
@end

@implementation XXYCampusPictureView
-(void)setCampusFrame:(XXYCampusDynamicFrame *)campusFrame
{
    _campusFrame = campusFrame;
    
    NSInteger imageCount=campusFrame.dataModel.picCount;
    CGFloat picWidth=(MainScreenW-30)/3;
    for (UIView*view in [self subviews])
    {
        [view removeFromSuperview];
    };
    if(imageCount>0)
    {
        for (NSInteger i=0;i<imageCount;i++)
        {
            UIImageView*imageView=[[UIImageView alloc]init];
            imageView.frame=CGRectMake(10+(picWidth+5)*(i%3), (picWidth+5)*(i/3), picWidth, picWidth);
            imageView.contentMode=UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.tag=500+i;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(seeBigImage:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:gesture];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?imageslim",campusFrame.dataModel.imageArray[i]]]placeholderImage:[UIImage imageNamed:@"school_bg_pic"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            }];
            
            [self addSubview:imageView];
        }
    }
    else if (campusFrame.dataModel.vedioUrl)
    {
        UIImageView*imageView=[[UIImageView alloc]init];
        imageView.frame=CGRectMake(10, 0, MainScreenW-20, (MainScreenW-20)*0.56);
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        
        UIButton*btnvideoPlay = [[UIButton alloc] initWithFrame:CGRectMake((imageView.frame.size.width-imageView.frame.size.height)/2, 0, imageView.frame.size.height, imageView.frame.size.height)];
        [btnvideoPlay setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
        [btnvideoPlay addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:btnvideoPlay];
        
        if(_videoImage)
        {
            imageView.image=_videoImage;
        }
        else
        {
            imageView.image=[UIImage imageNamed:@"school_bg_pic"];
            //  后台执行：
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                _videoImage = [self thumbnailImageForVideo:[NSURL URLWithString:campusFrame.dataModel.vedioUrl] atTime:1.0];
                if(_videoImage)
                {
                    imageView.image=_videoImage;
                }
            });
        }
        [self addSubview:imageView];
    }
}

-(void)playVideo
{
    if(self.campusFrame.dataModel.vedioUrl)
    {
        AVPlayerViewController *avplayer = [[AVPlayerViewController alloc] init];
        [avplayer setVideoGravity: AVLayerVideoGravityResizeAspect];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.campusFrame.dataModel.vedioUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
        
        [player play];
        avplayer.player = player;
        [self.window.rootViewController presentViewController:avplayer animated:YES completion:nil];
    }
}
//截取视频缩略图
-(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    //    if(!thumbnailImageRef)
    //        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    return thumbnailImage;
}

/**
 查看大图
 */
-(void)seeBigImage:(UITapGestureRecognizer*)tap
{
    UIView*view=[tap view];
    NSInteger picIndex=view.tag;
    XXYPreviewPicturesController*previewCon=[[XXYPreviewPicturesController alloc]init];
    previewCon.campusImgArray=self.campusFrame.dataModel.imageArray;
    
    previewCon.picIndex=picIndex;
    
    //CATransition * animation = [CATransition animation];
    
    //animation.duration = 0.4;    //  时间
    
    /**  type：动画类型
     *  pageCurl       向上翻一页
     *  pageUnCurl     向下翻一页
     *  rippleEffect   水滴
     *  suckEffect     收缩
     *  cube           方块
     *  oglFlip        上下翻转
     */
    //animation.type = @"rippleEffect";
    
    /**  type：页面转换类型
     *  kCATransitionFade       淡出
     *  kCATransitionMoveIn     覆盖
     *  kCATransitionReveal     底部显示
     *  kCATransitionPush       推出
     */
    //animation.type = kCATransitionMoveIn;
    
    //PS：type 更多效果请 搜索： CATransition
    
    /**  subtype：出现的方向
     *  kCATransitionFromRight       右
     *  kCATransitionFromLeft        左
     *  kCATransitionFromTop         上
     *  kCATransitionFromBottom      下
     */
    //animation.subtype = kCATransitionFromRight;
    
    // [self.window.layer addAnimation:animation forKey:nil];                   //  添加动作
    [self.window.rootViewController presentViewController: previewCon animated:NO completion:nil];     //  跳转
    //[previewCon setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    //[self.window.rootViewController presentViewController:previewCon animated:YES completion:nil];
}


@end

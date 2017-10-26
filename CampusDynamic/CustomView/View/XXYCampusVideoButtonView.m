#import "XXYCampusVideoButtonView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
@interface XXYCampusVideoButtonView()
@property(nonatomic,strong)UITapGestureRecognizer*tap;

@end

@implementation XXYCampusVideoButtonView
-(void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl=videoUrl;
    for (UIView*view in [self subviews])
    {
        [view removeFromSuperview];
    };

    if(_videoUrl)
    {
        UIImageView*imageView=[[UIImageView alloc]init];
        imageView.frame=CGRectMake(5, 0, 15, 15);
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image=[UIImage imageNamed:@"school_movie"];
        [self addSubview:imageView];
        
        UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 80, 15)];
        label.text=@"CoMo视频";
        label.font=[UIFont systemFontOfSize:16];
        label.textColor=XXYMainColor;
        [self addSubview:label];
        ///asdcfdsfds
        self.tap=[[UITapGestureRecognizer alloc]init];
        [self.tap addTarget:self action:@selector(playVideo)];
        [self addGestureRecognizer:self.tap];
    }
}
-(void)playVideo
{
    if(self.videoUrl)
    {
        AVPlayerViewController *avplayer = [[AVPlayerViewController alloc] init];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoUrl]];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
        [avplayer setVideoGravity: AVLayerVideoGravityResizeAspect];
        
        [player play];
        avplayer.player = player;
        [self.window.rootViewController presentViewController:avplayer animated:YES completion:nil];
    }
}

@end

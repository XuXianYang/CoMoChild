#import "XXYMyPraiseCell.h"
#import <UIImageView+WebCache.h>
#import"XXYMyPraiseModel.h"
#import <AVFoundation/AVFoundation.h>

@interface XXYMyPraiseCell()
@property (weak, nonatomic) IBOutlet UIImageView *userIconImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *otherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
@implementation XXYMyPraiseCell
-(void)setDataModel:(XXYMyPraiseModel *)dataModel
{
    [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.uIcon] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    _userNameLabel.text=dataModel.uName;
    _timeLabel.text=dataModel.uTime;
    _commentLabel.text=dataModel.uContent;
    
    if(!dataModel.hasImg&&dataModel.uVideoUrl)
    {
        UIImage*img= [self thumbnailImageForVideo:[NSURL URLWithString:dataModel.uVideoUrl] atTime:1.0];
        self.picImageView.image=img;
    }
    else
    {
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.uImage] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    }
    
    _otherNameLabel.text=[NSString stringWithFormat:@"@%@",dataModel.uMyName];
    _contentLabel.text=dataModel.uMyontent;
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

-(void)layoutSubviews
{
    _contentLabel.textColor=XXYCharacterBgColor;
    _userNameLabel.textColor=XXYCharacterBgColor;
    _commentLabel.textColor=XXYCharacterBgColor;
    self.userIconImageView.clipsToBounds=YES;
    self.userIconImageView.layer.cornerRadius=17.5;
    self.picImageView.contentMode=UIViewContentModeScaleAspectFill;
    self.picImageView.clipsToBounds=YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

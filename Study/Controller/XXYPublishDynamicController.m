#import "XXYPublishDynamicController.h"
#import "ZYQAssetPickerController.h"
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomPlayerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import"PublicMethod.h"
#import "XXYPreviewPicturesController.h"
#import"BSHttpRequest.h"
#import <SVProgressHUD/SVProgressHUD.h>

#import "XXYImagePickerCon.h"
#import <AFNetworking.h>
@interface XXYPublishDynamicController ()<ZYQAssetPickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate>
{
    
    UIScrollView               *_editv;
    UITextView           *_textView;
    UILabel              *_placeholderLabel;
    UIButton             *_addPic;
    NSMutableArray       *_imageArray;
    UIView                *_toolbarView;
    AVPlayer            *_player; // 视频播放对象
    AVPlayerItem        *_playerItem; // 视频资源对象
    
    NSURL*  _videoUrl;//已选择视频的url
    UIImageView*_videoImageView;//已选择视频的截图
    
    NSInteger _upLoadSucess;
    
    NSString*_videoUploadUrlString;
    
    CGFloat _progressValue;
    
}
@property ( nonatomic,strong)  CustomPlayerView *playerView;
@property ( nonatomic,copy)  NSString *plistFileName;
@property ( nonatomic,retain)  NSMutableArray *picPathArr;

@property (nonatomic, strong) NSProgress *progress;

@property ( nonatomic,strong)  UILabel *videoTimeLabel;

@property (nonatomic, strong) UILabel *videoSizeLabel;

@end

@implementation XXYPublishDynamicController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"详情";
    
    _progressValue=0;
    _upLoadSucess=0;
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;
    [self setUpTitleView];
    [self setUpSubViews];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //本地生成一个文件夹
    [PublicMethod addNewFolder:@"" inNextPath:[PublicMethod getDocumentVideoPath]];

    if(self.shareIndex==2)
    {
        _textView.text=self.shareString;
        _placeholderLabel.text=nil;
    }
}
-(NSMutableArray*)picPathArr
{
    if(!_picPathArr)
    {
        _picPathArr=[NSMutableArray array];
    }
    return _picPathArr;
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float height = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        // 设置view弹出来的位置
        _toolbarView.frame=CGRectMake(0,self.view.frame.size.height-height-50, MainScreenW, 50);
    }];
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.5 animations:^{
        // 设置view弹出来的位置
        _toolbarView.frame=CGRectMake(0,self.view.frame.size.height-50, MainScreenW, 50);
    }];
}
//初始化子控件
-(void)setUpSubViews
{
    _imageArray = [NSMutableArray array];
    
    // 评论 + 照片
    _editv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, MainScreenW, MainScreenH-64)];
    _editv.backgroundColor = [UIColor clearColor];
    _editv.bounces=YES;
    _editv.delegate=self;
    _editv.contentSize=CGSizeMake(0, MainScreenH-64+5);
    [self.view addSubview:_editv];
    
    // 评论 UITextView
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, CGRectGetWidth(_editv.frame)-15*2, 70)];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font=[UIFont systemFontOfSize:15];
    [_textView becomeFirstResponder];
    _textView.delegate = self;
    [_editv addSubview:_textView];
    
    // 提示字
    _placeholderLabel = [[UILabel alloc] init];
    _placeholderLabel.frame =CGRectMake(5, 6, CGRectGetWidth(_editv.frame)-15*4, 20);
    _placeholderLabel.text = @"在此编辑内容!";
    _placeholderLabel.textColor = [UIColor colorWithWhite:0.4 alpha:0.6];
    _placeholderLabel.font = [UIFont systemFontOfSize:15];
    _placeholderLabel.enabled = NO; // lable必须设置为不可用
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    [_textView addSubview:_placeholderLabel];
    
    //添加照片
    //[self setUpAddPicBtn];
   // _editv.frame = CGRectMake(0, 64, MainScreenW, CGRectGetMaxY(_addPic.frame)+20);
    
    if(!self.index)
    {
        _toolbarView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-50, MainScreenW, 50)];
        _toolbarView.backgroundColor=XXYBgColor;
        [self.view addSubview:_toolbarView];
    }
    
  NSArray*imageNameArr=@[@"pub_school_pic",@"pub_school_camera",@"pub_school_play",@"pub_school_vidicon"];
    
    NSArray*bottomTitleArr=@[@"相册",@"相机",@"视频",@"录像"];
    
    CGFloat spaceWidth=(MainScreenW-120)/5;
    
    for(int i=0;i<4;i++)
    {
        UIButton*toolBarBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        toolBarBtn.frame=CGRectMake((i+1)*spaceWidth+30*i, 5, 30, 30);
        [toolBarBtn addTarget:self action:@selector(toolBarBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        toolBarBtn.tag=100+i;
        [toolBarBtn setBackgroundImage:[UIImage imageNamed:imageNameArr[i]] forState:UIControlStateNormal];
        [_toolbarView addSubview:toolBarBtn];
        
        UILabel*bottomLabel=[[UILabel alloc]initWithFrame:CGRectMake((i+1)*spaceWidth+30*i, 35, 30, 15)];
        bottomLabel.text=bottomTitleArr[i];
        bottomLabel.textColor=[UIColor colorWithRed:130.0/255 green:130.0/255 blue:130.0/255 alpha:1.0];
        bottomLabel.textAlignment=NSTextAlignmentCenter;
        bottomLabel.font=[UIFont systemFontOfSize:10.0];
        [_toolbarView addSubview:bottomLabel];
    }
}
//获取视频时长
- (CGFloat) getVideoLength:(NSURL *)URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}
//压缩视频
- (void) convertVideoWithModel:(NSURL *) path
{
    [SVProgressHUD showWithStatus:@"视频转码中..."];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@%i.mp4",str,2];
    NSString *outputPath = [[PublicMethod getDocumentVideoPath] stringByAppendingPathComponent:fileName];
//    _videoUrl=[NSURL fileURLWithPath:path];
   outputPath =[NSString stringWithFormat:@"file://%@",outputPath ];
    //转码配置
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:path options:nil];
    AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputURL = [NSURL fileURLWithPath:outputPath];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exportSession.status;
        switch (exportStatus)
        {
            case AVAssetExportSessionStatusFailed:
            {
//                NSError *exportError = exportSession.error;
//                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                [self uploadMyVideo];
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                
                
                _videoUrl=[NSURL URLWithString:outputPath];
                [self uploadMyVideo];
                
//                AVAsset *asset = [AVAsset assetWithURL:_videoUrl];
//                NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//                if([tracks count] > 0)
//                {
//                    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
//                    CGAffineTransform t = videoTrack.preferredTransform;//这里的矩阵有旋转角度，转换一下即可
//                    
//                    NSLog(@"CGAffineTransform=%@",t);
//                    NSLog(@"=====hello  width:%f===height:%f",videoTrack.naturalSize.width,videoTrack.naturalSize.height);//
//                }
            }
        }
    }];
}
-(NSString*)getTimeFormat:(CGFloat)second
{
    int vsecond=  second;
    int min=vsecond/60;
    int sec=vsecond%60;
    NSString*minString=[NSString stringWithFormat:@"%i",min];
    NSString*secString=[NSString stringWithFormat:@"%i",sec];
    if(min<10)
    {
        minString=[NSString stringWithFormat:@"0%i",min];
    }
    if(sec<10)
    {
        secString=[NSString stringWithFormat:@"0%i",sec];
    }
    NSString *timeStr=[NSString stringWithFormat:@"%@:%@",minString,secString];
    return timeStr;
}
//添加视频缩略图
-(void)setUpVideoSubViews:(NSURL*)url
{
    UIImage *bgImg = [self thumbnailImageForVideo: url atTime:1];
    
    if(bgImg)
    {
        _videoUrl=url;
        
        _videoImageView=[[UIImageView alloc]init];
        _videoImageView.frame=CGRectMake(15, CGRectGetMaxY(_textView.frame)+15, MainScreenW/2, MainScreenW/2);
        _videoImageView.clipsToBounds = YES;
        _videoImageView.contentMode=UIViewContentModeScaleAspectFill;
        _videoImageView.userInteractionEnabled = YES;
        [_editv addSubview:_videoImageView];
        
        _videoImageView.image=bgImg;
        
        NSString*videoTime=[self getTimeFormat:[self getVideoLength:url ]];
        
        NSString*videoSize=@"";
        
        NSArray*arr=@[videoSize,videoTime];
        
        for(NSInteger i=0;i<2;i++)
        {
            UILabel*timeAndSizeLabel=[[UILabel alloc]initWithFrame:CGRectMake(_videoImageView.frame.size.width/2*i+5, _videoImageView.frame.size.height-22, _videoImageView.frame.size.width/2-15, 20)];
            timeAndSizeLabel.textColor=[UIColor whiteColor];
            timeAndSizeLabel.font=[UIFont systemFontOfSize:15];
            timeAndSizeLabel.text=arr[i];
            if(i==1)
            {
                timeAndSizeLabel.textAlignment=NSTextAlignmentRight;
            }
            [_videoImageView addSubview:timeAndSizeLabel];
        }
        UIButton*btnvideoPlay = [[UIButton alloc] initWithFrame:_videoImageView.bounds];
        [btnvideoPlay setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
        [btnvideoPlay addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
        [_videoImageView addSubview:btnvideoPlay];
        
        UIButton *deleteVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteVideo.frame = CGRectMake(_videoImageView.frame.size.width-20, 0, 20, 20);
        deleteVideo.backgroundColor = [UIColor clearColor];
        [deleteVideo setBackgroundImage:[UIImage imageNamed:@"deleteinput"] forState:UIControlStateNormal];
        [deleteVideo addTarget:self action:@selector(deleteVideoEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_videoImageView addSubview:deleteVideo];
        
//       [self nineGrid];
        CGFloat width = (MainScreenW-40)/3;
        CGFloat widthSpace = 5;
        CGFloat heightSpace = 5;
        
        for(int i=0;i<_imageArray.count;i++)
        {
            
            UIImageView*imageView=[self.view  viewWithTag:500+i];
            
            imageView.frame=CGRectMake(15+(width+widthSpace)*(i%3), (i/3)*(width+heightSpace) + CGRectGetMaxY(_textView.frame)+15+MainScreenW/2+10, width, width);
            if (i == _imageArray.count - 1)
            {
                if (_imageArray.count % 3 == 0) {
                    
                    _addPic.frame = CGRectMake(15, CGRectGetMaxY(imageView.frame) + heightSpace, (MainScreenW-40)/3, (MainScreenW-40)/3);
                    
                } else
                {
                    _addPic.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + widthSpace, CGRectGetMinY(imageView.frame), (MainScreenW-40)/3, (MainScreenW-40)/3);
                }
            }
        }
        if((MainScreenH-64+5)<(165+MainScreenW/2+10+(_imageArray.count / 3+1)*width))
        {
            _editv.contentSize=CGSizeMake(0, 165+MainScreenW/2+10+(_imageArray.count / 3+1)*width);
        }
    }
}
//删除视频
-(void)deleteVideoEvent:(UIButton*)btn
{
    for (UIView*view in [_videoImageView subviews])
    {
        [view removeFromSuperview];
    }
    [_videoImageView removeFromSuperview];
    
     [self deleteMyCacheVideo];
        [self nineGrid];
}

-(void)deleteMyCacheVideo
{
    if(_videoUrl)
    {
        _videoUrl=nil;
        _videoUploadUrlString=nil;
        
        NSString *path = [PublicMethod getDocumentVideoPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *folderarry = [fileManager subpathsOfDirectoryAtPath:path error:nil];
        for (NSString*filePath in folderarry)
        {
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,filePath] error:nil];
        }
    }
}
//预览视频
-(void)playVideo
{
    if(_videoUrl)
    {
        AVPlayerViewController *avplayer = [[AVPlayerViewController alloc] init];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_videoUrl];
        AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
        
        avplayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        [player play];
        avplayer.player = player;
        [self presentViewController:avplayer animated:YES completion:nil];
    }
}
//工具栏按钮点击事件
-(void)toolBarBtnCliked:(UIButton*)btn
{
    switch (btn.tag)
    {
        case 100:
        {
            [self addPicEvent];
        }
            break;
        case 101:
        {
               if(_imageArray.count==9)
            {
                [self setUpAlertViewController:@"最多可以选择九张图片"];
            }
            else
            {
                [self pickPicture:UIImagePickerControllerSourceTypeCamera AndType:2];
            }
            
        }
            break;

        case 102:
        {
            if(_videoUrl)
            {
                [self setUpAlertViewController:@"最多可以选择一个视频"];
            }
            else
            {
                [self pickPicture:UIImagePickerControllerSourceTypePhotoLibrary AndType:1];
            }
            
        }
            break;
        case 103:
        {
            if(_videoUrl)
            {
                [self setUpAlertViewController:@"最多可以选择一个视频"];
            }
            else
            {
                [self pickPicture:UIImagePickerControllerSourceTypeCamera AndType:3];
            }
        }
            break;
        default:
            break;
    }
}

//跳相册或视频相册
-(void)pickPicture:(UIImagePickerControllerSourceType)sourceType AndType:(NSInteger)index
{
    
    switch (index) {
        case 3:
        {
            XXYImagePickerCon *imagePickerController = [[XXYImagePickerCon alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            imagePickerController.videoMaximumDuration = 120.0f;//120秒
            imagePickerController.videoQuality=UIImagePickerControllerQualityTypeMedium;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }
            break;
            case 2:
        {
            // 跳转到相机或相册页面
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }
            break;
        case 1:
        {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = sourceType;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            imagePickerController.videoMaximumDuration = 120.0f;//120秒
            imagePickerController.videoQuality=UIImagePickerControllerQualityTypeMedium;
            [self presentViewController:imagePickerController animated:YES completion:^{
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            }];

        }
            break;
        default:
            break;
    }
   }
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [picker dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark -   system UIImagePickerController  代理
//获取视频的路径
-(void)getFolderArry{
    
    NSString *path = [PublicMethod getDocumentVideoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *folderarry = [fileManager subpathsOfDirectoryAtPath:path error:nil];
    //NSLog(@"folderarry=%@",folderarry);
    if([_videoUrl isEqual:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",path,folderarry[folderarry.count-1]]]])
    {
//        [self uploadMyVideo];
        
        //  后台执行：
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
                [self convertVideoWithModel:_videoUrl];
                
                
//                [self uploadMyVideo];
                    });

        
    }
}
//获取图片或者视频
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // NSLog(@"type==%@",[info objectForKey:UIImagePickerControllerMediaType]);
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
    {
        UIImage  *img = [info objectForKey:UIImagePickerControllerEditedImage];
        [_imageArray addObject:img];
        [self uploadMyPicture:img and:_upLoadSucess andTotal:_upLoadSucess];
//        [self nineGrid];
    }
    else if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"])
    {
        
        NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];        
        if([mediaType isEqualToString:(NSString *)kUTTypeMovie])
        {
            NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            NSString *path = [[PublicMethod getDocumentVideoPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",[PublicMethod getPicName]]];
            
            _videoUrl=[NSURL fileURLWithPath:path];
            
            [data writeToFile:path atomically:YES];
           // NSLog(@"writePath=%@",path);
            [self getFolderArry];
        }
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [picker dismissViewControllerAnimated:YES completion:^{}];
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
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_textView resignFirstResponder];
}
//添加"+"按钮
-(void)setUpAddPicBtn
{
    [_addPic removeFromSuperview];
    // + pic
    _addPic = [UIButton buttonWithType:UIButtonTypeCustom];
    _addPic.frame = CGRectMake(15, CGRectGetMaxY(_textView.frame)+15, (MainScreenW-40)/3, (MainScreenW-40)/3);
    _addPic.layer.borderColor=XXYBgColor.CGColor;
    _addPic.layer.borderWidth=1.0;

    //[_addPic setBackgroundColor:[UIColor lightGrayColor]];
    [_addPic setBackgroundImage:[UIImage imageNamed:@"addfile"] forState:UIControlStateNormal];
    //[_addPic setImage:[UIImage imageNamed:@"addfile"] forState:UIControlStateNormal];
    [_addPic addTarget:self action:@selector(addPicEvent) forControlEvents:UIControlEventTouchUpInside];
    [_editv addSubview:_addPic];
}
#pragma mark - UIbutton event

- (void)addPicEvent
{
    if (_imageArray.count >= 9)
    {
        [self setUpAlertViewController:@"最多只能上传9张图片"];
        //NSLog(@"最多只能上传9张图片");
    } else {
        [self selectPictures];
    }
}
// 本地相册选择多张照片
- (void)selectPictures
{
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 9-_imageArray.count;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = NO;
    picker.delegate = self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
                              {
                                  if ([[(ALAsset *)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
                                  {
                                      NSTimeInterval duration = [[(ALAsset *)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                                      
                                      return duration >= 5;
                                  } else {
                                      return YES;
                                  }
                              }];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

//删除图片 9宫格图片布局
- (void)nineGrid
{
    for (UIImageView *imgv in _editv.subviews)
    {
        if ([imgv isKindOfClass:[UIImageView class]])
        {
            [imgv removeFromSuperview];
        }
    }
    CGFloat width = (MainScreenW-40)/3;
    CGFloat widthSpace = 5;
    CGFloat heightSpace = 5;
    
    NSInteger count = _imageArray.count;
    
    _imageArray.count > 9 ? (count = 9) : (count = _imageArray.count);
    
    if(count==9||count==0)
    {
        [_addPic removeFromSuperview];
    }
    else
    {
        [self setUpAddPicBtn];
    }
    
    CGFloat videoHight=0;
    
    if(_videoUrl)
    {
       [self setUpVideoSubViews:_videoUrl];
        videoHight=MainScreenW/2+10;
    }
    else
    {
        videoHight=0;
    }
    if(count>0)
    for (int i=0; i<count; i++)
    {
        
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(15+(width+widthSpace)*(i%3), (i/3)*(width+heightSpace) + CGRectGetMaxY(_textView.frame)+15, width, width)];
        imgv.frame=CGRectMake(15+(width+widthSpace)*(i%3), (i/3)*(width+heightSpace) + CGRectGetMaxY(_textView.frame)+15+videoHight, width, width);
        imgv.image = _imageArray[i];
        imgv.clipsToBounds = YES;
        imgv.tag=500+i;
        
        UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selPicClicked:)];
        [imgv addGestureRecognizer:tapGesturRecognizer];

        imgv.contentMode=UIViewContentModeScaleAspectFill;
        imgv.userInteractionEnabled = YES;
        [_editv addSubview:imgv];
        
        UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
        delete.frame = CGRectMake(width-16, 0, 16, 16);
        delete.backgroundColor = [UIColor clearColor];
        [delete setBackgroundImage:[UIImage imageNamed:@"deleteinput"] forState:UIControlStateNormal];
        [delete addTarget:self action:@selector(deleteEvent:) forControlEvents:UIControlEventTouchUpInside];
        delete.tag = 10+i;
        [imgv addSubview:delete];
        
        if (i == _imageArray.count - 1)
        {
            if (_imageArray.count % 3 == 0) {
                _addPic.frame = CGRectMake(15, CGRectGetMaxY(imgv.frame) + heightSpace, (MainScreenW-40)/3, (MainScreenW-40)/3);
            } else
            {
                _addPic.frame = CGRectMake(CGRectGetMaxX(imgv.frame) + widthSpace, CGRectGetMinY(imgv.frame), (MainScreenW-40)/3, (MainScreenW-40)/3);
            }
            
        }
    }
        if((MainScreenH-64+5)<(165+videoHight+(_imageArray.count / 3+1)*width))
    {
        _editv.contentSize=CGSizeMake(0, 165+videoHight+(_imageArray.count / 3+1)*width);
    }
}
//上传图片成功之后九宫格布局
-(void)setUpnineGrid:(NSInteger)index andImg:(UIImage*)image
{
    CGFloat width = (MainScreenW-40)/3;
    CGFloat widthSpace = 5;
    CGFloat heightSpace = 5;
    
    NSInteger count = index;
    
    CGFloat videoHight=0;
    if(_videoUrl)
    {
        videoHight=MainScreenW/2+10;
    }
    else
    {
        videoHight=0;
    }
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(15+(width+widthSpace)*(count%3), (count/3)*(width+heightSpace) + CGRectGetMaxY(_textView.frame)+15, width, width)];
    imgv.frame=CGRectMake(15+(width+widthSpace)*(count%3), (count/3)*(width+heightSpace) + CGRectGetMaxY(_textView.frame)+15+videoHight, width, width);
    imgv.image = image;
    imgv.clipsToBounds = YES;
    imgv.tag=500+index;
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selPicClicked:)];
    [imgv addGestureRecognizer:tapGesturRecognizer];
    
    imgv.contentMode=UIViewContentModeScaleAspectFill;
    imgv.userInteractionEnabled = YES;
    [_editv addSubview:imgv];
    
    UIButton *delete = [UIButton buttonWithType:UIButtonTypeCustom];
    delete.frame = CGRectMake(width-16, 0, 16, 16);
    delete.backgroundColor = [UIColor clearColor];
    [delete setBackgroundImage:[UIImage imageNamed:@"deleteinput"] forState:UIControlStateNormal];
    [delete addTarget:self action:@selector(deleteEvent:) forControlEvents:UIControlEventTouchUpInside];
    delete.tag = 10+index;
    [imgv addSubview:delete];
    
    if((count+1)==9||(count+1)==0)
    {
        [_addPic removeFromSuperview];
    }
    else
    {
        [self setUpAddPicBtn];
    }
    
    if ((count+1) % 3 == 0) {
        _addPic.frame = CGRectMake(15, CGRectGetMaxY(imgv.frame) + heightSpace, (MainScreenW-40)/3, (MainScreenW-40)/3);
    }
    else
    {
        _addPic.frame = CGRectMake(CGRectGetMaxX(imgv.frame) + widthSpace, CGRectGetMinY(imgv.frame), (MainScreenW-40)/3, (MainScreenW-40)/3);
    }
    if((MainScreenH-64+5)<(165+videoHight+(_imageArray.count / 3+1)*width))
    {
        _editv.contentSize=CGSizeMake(0, 165+videoHight+(_imageArray.count / 3+1)*width);
    }
}
//上传图片
-(void)uploadMyPicture:(UIImage*)image and:(NSInteger)index andTotal:(NSInteger)totalIndex
{
    
    UIButton*subbtn=[self.view viewWithTag:802];
    subbtn.userInteractionEnabled=NO;
    [subbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    NSString*urlString=[NSString stringWithFormat:@"%@/student/pg/streamNROP?sid=%@",BaseUrl,userSidString];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
            [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                [SVProgressHUD showWithStatus:@"上传图片中..."];
                
                 if ([image isKindOfClass:[UIImage class]])
                {
                    // 设置上传图片的名字
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMddHHmmss";
                    NSString *str = [formatter stringFromDate:[NSDate date]];
                    NSString *fileName = [NSString stringWithFormat:@"%@%i.jpg",str,index];
                    
                    NSData *fileData = UIImageJPEGRepresentation(image, 0.5);
                    if (fileData != nil)
                    {
                        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"image/jpg"];
                    }
                }
            
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
//            NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSString*codeStr=objString[@"code"];
            
            if([objString[@"message"] isEqualToString:@"success"]&&codeStr.integerValue==0)
            {
                
                if(index==totalIndex)
                {
                    [SVProgressHUD showSuccessWithStatus:@"上传成功"];
                    _progressValue=0;
                }
                _upLoadSucess++;
              NSString*  urlPathString=[NSString stringWithFormat:@"%@/%@",objString[@"data"][@"urlPrefix"],objString[@"data"][@"relativePath"]];
                [self.picPathArr addObject:urlPathString];
//                NSLog(@"picarr=%@",self.picPathArr);
                [self setUpnineGrid:_upLoadSucess-1 andImg:image];
                
                UIButton*subbtn=[self.view viewWithTag:802];
                subbtn.userInteractionEnabled=YES;
                [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"上传失败"];
                _progressValue=0;
                [_imageArray removeObject:image];
                UIButton*subbtn=[self.view viewWithTag:802];
                subbtn.userInteractionEnabled=YES;
                [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
            
            [SVProgressHUD showSuccessWithStatus:@"上传失败"];
            _progressValue=0;
            
            [_imageArray removeObject:image];
            UIButton*subbtn=[self.view viewWithTag:802];
            subbtn.userInteractionEnabled=YES;
            [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }];
}
//上传视频
-(void)uploadMyVideo
{
    UIButton*subbtn=[self.view viewWithTag:802];
    subbtn.userInteractionEnabled=NO;
    [subbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    NSString*urlString=[NSString stringWithFormat:@"%@/student/pg/vedioAvThumb?sid=%@",BaseUrl,userSidString];
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@%i.mp4",str,1];
        
       NSData*fileData=[NSData dataWithContentsOfURL:_videoUrl];
        
//        NSData* fileData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:_videoUrl] returningResponse:NULL error:NULL];

        
        if (fileData != nil)
        {
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"video/quicktime"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
//        self.progress=uploadProgress;
//        self.progress = [NSProgress progressWithTotalUnitCount:10000.0];
//        self.progress.completedUnitCount += 100.0;
//        
//        _progressValue=self.progress.fractionCompleted+_progressValue;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 在主线程中更新 UI
//            [SVProgressHUD showProgress: _progressValue/3.0 status:@"上传视频中..."];
//        });
        [SVProgressHUD showWithStatus:@"上传视频中..."];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
       NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            _progressValue=0;
            
            _videoUploadUrlString=[NSString stringWithFormat:@"%@/%@",objString[@"data"][@"urlPrefix"],objString[@"data"][@"relativePath"]];
            
            [self setUpVideoSubViews:_videoUrl];
            UIButton*subbtn=[self.view viewWithTag:802];
            subbtn.userInteractionEnabled=YES;
            [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"上传失败"];
            _progressValue=0;
            _videoUrl=nil;
            _videoUploadUrlString=nil;

            UIButton*subbtn=[self.view viewWithTag:802];
            subbtn.userInteractionEnabled=YES;
            [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        
         [SVProgressHUD showSuccessWithStatus:@"上传失败"];
        _progressValue=0;
        _videoUrl=nil;
        _videoUploadUrlString=nil;

        UIButton*subbtn=[self.view viewWithTag:802];
        subbtn.userInteractionEnabled=YES;
        [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }];
}


//预览图片跳转
-(void)selPicClicked:(UITapGestureRecognizer*)tap
{
    UIView*view=[tap view];
    NSInteger picIndex=view.tag;
    XXYPreviewPicturesController*previewCon=[[XXYPreviewPicturesController alloc]init];
    previewCon.dataArray=_imageArray;
    previewCon.picIndex=picIndex;
    [self presentViewController:previewCon animated:NO completion:nil];
}
// 删除照片
- (void)deleteEvent:(UIButton *)sender
{
    UIButton *btn = (UIButton *)sender;
    [_imageArray removeObjectAtIndex:btn.tag-10];
    [self.picPathArr  removeObjectAtIndex:btn.tag-10];
    _upLoadSucess--;
//    NSLog(@"deletepicarr=%@",self.picPathArr);
    [self nineGrid];
}
#pragma mark - ZYQAssetPickerController Delegate
//获取图片
- (void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSMutableArray*array=[NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       for (int i=0; i<assets.count; i++)
                       {
                           ALAsset *asset = assets[i];
                           UIImage *tempImg = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                           [_imageArray addObject:tempImg];
                           [array addObject:tempImg];
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           // [self nineGrid];
                           for (int i=0;i<array.count;i++)
                           {
                               UIImage*image=array[i];
                               [self uploadMyPicture:image and:i andTotal:array.count-1];
                           }
                       });
                       
                   });
}
#pragma makr - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *toBeString = textView.text;
    
    if (toBeString.length == 0) {
        _placeholderLabel.text = @"在此编辑内容!";
    } else {
        _placeholderLabel.text = @"";
    }
    NSString *lang = [(UITextInputMode*)[[UITextInputMode activeInputModes] firstObject] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length >= 255)
            {
                textView.text = [toBeString substringToIndex:255];
            }
         } // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else
        {
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length >= 255)
        {
            textView.text = [toBeString substringToIndex:255];
        }
    }
}
-(void)setUpAlertViewController:(NSString*)str
{
    if([str isEqualToString:@"发表成功"])
    {
        [_textView resignFirstResponder];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if([self.reloadDelegate respondsToSelector:@selector(reloadNewDataOfPublished)])
            {
                [self.reloadDelegate reloadNewDataOfPublished];
            }
        }];
    }
    else
    {
        UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertCon animated:YES completion:nil];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
    }
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
        UIButton*subbtn=[self.view viewWithTag:802];
        subbtn.userInteractionEnabled=YES;
        [subbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }];
    alert = nil;
}
//导航栏初始化子控件
-(void)setUpTitleView
{
    UIView*titleBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 64)];
    titleBgView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [self.view addSubview:titleBgView];
    
    UIButton*cancelBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame=CGRectMake(15, 20, 50, 44);
    cancelBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [titleBgView addSubview:cancelBtn];
    
    
    UIButton*confirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.frame=CGRectMake(MainScreenW-65, 20, 50, 44);
    confirmBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [confirmBtn setTitle:@"发表" forState:UIControlStateNormal];
    confirmBtn.tag=802;
    [confirmBtn addTarget:self action:@selector(confirmBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [titleBgView addSubview:confirmBtn];
    
}
//发布校园动态
-(void)confirmBtnCliked:(UIButton*)btn
{
//    NSData*data=[NSData dataWithContentsOfURL:_videoUrl];
   // NSLog(@"videoFileData=%@",data);
    
    UIButton*subbtn=[self.view viewWithTag:802];
    subbtn.userInteractionEnabled=NO;
    [subbtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];

    if(self.index)
    {
        
        
        NSString*urlString=[NSString stringWithFormat:@"%@/student/pg/saveDiscuss",BaseUrl];
        _textView.text= [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(_textView.text.length==0)
        {
            [self setUpAlertViewController:@"评论内容不能为空"];
        }

       else if(self.actId)
        [manager POST:urlString parameters:@{@"sid":userSidString,@"actId":self.actId,@"content":_textView.text} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [self setUpAlertViewController:@"发表成功"];
                
            }
            else
            {
                [self setUpAlertViewController:@"发表失败"];
            }


        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self setUpAlertViewController:@"发表失败"];
        }];
    }
    else
    {
        NSMutableDictionary*parametersDict=[NSMutableDictionary dictionary];
        _textView.text= [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(_textView.text.length>0)
        {
            parametersDict[@"content"]=_textView.text;
        }
        if (_picPathArr.count>0)
        {
            NSString*uploadPicString=@"";
            for (NSString*imgUrl in _picPathArr)
            {
                uploadPicString=[NSString stringWithFormat:@"%@,%@",uploadPicString,imgUrl];
            }
            uploadPicString=[uploadPicString substringWithRange:NSMakeRange(1, uploadPicString.length-1)];
            parametersDict[@"imgUrls"]=uploadPicString;
        }
        if(_videoUploadUrlString)
        {
            parametersDict[@"vedioUrl"]=_videoUploadUrlString;
        }
//        NSLog(@"dict=%@",parametersDict);
        NSString*urlString=[NSString stringWithFormat:@"%@/student/pg/sendPgAct2?sid=%@",BaseUrl,userSidString];
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if(_textView.text.length>0||_picPathArr.count>0||_videoUploadUrlString)
            //,@"vedioUrl":_videoUploadUrlString
            [manager POST:urlString parameters:parametersDict progress:^(NSProgress * _Nonnull uploadProgress) {
            }
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);

                id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if([objString[@"message"] isEqualToString:@"success"])
                {
                    [self setUpAlertViewController:@"发表成功"];
                    //删除缓存的视频
                    [self deleteMyCacheVideo];
                }
                else
                {
                    [self setUpAlertViewController:@"发表失败"];
                }

            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self setUpAlertViewController:@"发表失败"];
            }];
        else
        {
            [self setUpAlertViewController:@"内容不能为空"];
        }
    }
}
-(void)cancelBtnCliked:(UIButton*)btn
{
    [_textView resignFirstResponder];
    //删除沙盒缓存的视频
    [self deleteMyCacheVideo];
//    NSString *path = [PublicMethod getDocumentVideoPath];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *folderarry = [fileManager subpathsOfDirectoryAtPath:path error:nil];
//    for (NSString*filePath in folderarry)
//    {
//        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,filePath] error:nil];
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

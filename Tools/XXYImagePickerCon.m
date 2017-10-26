#import "XXYImagePickerCon.h"
#import "DeviceOrientation.h"
#import <CoreMotion/CoreMotion.h>

@interface XXYImagePickerCon ()<UIImagePickerControllerDelegate,DeviceOrientationDelegate>
{
    DeviceOrientation *deviceMotion;
}

@property(nonatomic,strong)UIView*bgView;
@property(nonatomic,strong)UILabel*titleLabel;
@property(nonatomic,strong)UIImageView*bgImageView;
@property(nonatomic,strong)UIButton*conButton;
@property(nonatomic,strong)CMMotionManager  *cmmotionManager;

@end

@implementation XXYImagePickerCon

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设备旋转通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    [self.view addSubview:self.bgView];
    [self addBgPic];
    
    if(![self.cmmotionManager isDeviceMotionAvailable])
    {
        deviceMotion = [[DeviceOrientation alloc]initWithDelegate:self];
        [deviceMotion startMonitor];
    }
}
-(UIView*)bgView
{
    if(!_bgView)
    {
        //CGRectMake(0, 0, MainScreenW, MainScreenH-100)
        _bgView=_bgView= [[UIView alloc]initWithFrame:self.view.bounds];
        _bgView.backgroundColor=[UIColor clearColor];
        
        _conButton=[UIButton buttonWithType:UIButtonTypeSystem];
        _conButton.frame=CGRectMake(100, MainScreenH-100, MainScreenW-200, 100);
        [_conButton addTarget:self action:@selector(conbtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        _conButton.userInteractionEnabled=NO;
        [_bgView addSubview:_conButton];
        
        UIButton*cancalebtn=[UIButton buttonWithType:UIButtonTypeSystem];
        cancalebtn.frame=CGRectMake(0, MainScreenH-100, 100, 100);
        [cancalebtn addTarget:self action:@selector(btnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:cancalebtn];
    }
    return _bgView;
}
-(void)addBgPic
{
    _conButton.userInteractionEnabled=NO;
    

    [_titleLabel removeFromSuperview];
    [_bgImageView removeFromSuperview];
    
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 110, MainScreenW,40)];
    _titleLabel.text=@"亲,请把屏幕横过来拍摄";
    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.textColor=[UIColor whiteColor];
    [_bgView addSubview:_titleLabel];
    
    _bgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, 150, MainScreenW-100, MainScreenW-100)];
    _bgImageView.image=[UIImage imageNamed:@"record_rotation"];
    [_bgView addSubview:_bgImageView];
}
-(void)conbtnCliked:(UIButton*)btn
{
    [self startVideoCapture];
    [_bgView removeFromSuperview];
}
-(void)btnCliked:(UIButton*)btn
{
    [self dismissViewControllerAnimated:YES completion:^{
        [deviceMotion stop];
    }];
}
-(void)removeBgPic
{
    [_titleLabel removeFromSuperview];
    [_bgImageView removeFromSuperview];
}
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation{
    UIDevice *device = [UIDevice currentDevice] ;
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            //NSLog(@"屏幕朝上平躺");
            [self addBgPic];
            break;
            
        case UIDeviceOrientationFaceDown:
            //NSLog(@"屏幕朝下平躺");
            [self addBgPic];
            break;
            
        case UIDeviceOrientationUnknown:
            //NSLog(@"未知方向");
            [self addBgPic];
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        {
            //NSLog(@"home键在右");
            _conButton.userInteractionEnabled=YES;

            [self removeBgPic];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight:
            
        {
            //NSLog(@"home键在左");
            _conButton.userInteractionEnabled=YES;

            [self removeBgPic];
        }
            break;
            
        case UIDeviceOrientationPortrait:
        {
            //NSLog(@"home键在下");
            [self addBgPic];
        }
            break;
        
        case UIDeviceOrientationPortraitUpsideDown:
        {
            //NSLog(@"home键在上");
            [self addBgPic];
            
            
        }
            break;
        default:
           // NSLog(@"无法辨识");
            [self addBgPic];
            break;
    }
   }
- (void)directionChange:(TgDirection)direction {
    
    switch (direction) {
        case TgDirectionPortrait:
            
            //NSLog(@"protrait");
            [self addBgPic];
            break;
        case TgDirectionDown:
            
            //NSLog(@"down");
            [self addBgPic];
            break;
        case TgDirectionRight:
            _conButton.userInteractionEnabled=YES;
            
            [self removeBgPic];
            //NSLog(@"right");
            
            break;
        case TgDirectionleft:
            _conButton.userInteractionEnabled=YES;
            
            [self removeBgPic];
            //NSLog(@"left");
            
            break;
            
        default:
            break;
    }
}

-(void)dealloc
{
    [deviceMotion stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

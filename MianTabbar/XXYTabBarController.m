#import "XXYTabBarController.h"
#import "XXYHomeController.h"
#import "XXYMeController.h"
#import "XXYPlaygroundController.h"
#import "XXYSOSController.h"
#import "XXYNavigationController.h"
#import "UIImage+XXYImage.h"
#import "BSTabBar.h"
#import "BSHttpRequest.h"
#import<CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
static NSInteger count;
@interface XXYTabBarController ()<BSTabBarDelegate,UINavigationControllerDelegate,UITextViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager*_locationManager;
    CLLocationCoordinate2D _coordinate;
}
@property (nonatomic,retain)NSMutableArray *items;
@property (nonatomic,strong)BSTabBar *bstabBar;
@property(nonatomic,strong)UIView*sosView;
@property(nonatomic,strong)UIView*bgSosView;
@property(nonatomic,strong)UIView*bgIconImageView;
@property(nonatomic,strong)UITextView*contentTextView;
@property(nonatomic,strong)UILabel*placeHoderLabel;
@property(nonatomic,strong)UIButton*sosBtn;
@property(nonatomic,strong)UILabel*safeTimeLabel;

@end
@implementation XXYTabBarController
#pragma mark 本类或子类初始化时调用且只调用一次

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count=0;
    [self setUpTabBar];
    [self setUpChildControllers];
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
}
- (BSTabBar *)bstabBar
{
    if (_bstabBar==nil) {
        _bstabBar = [[BSTabBar alloc] initWithFrame:self.tabBar.bounds];
    }
    return _bstabBar;
}

-(void)setUpTabBar
{
    //替换掉系统的tabBar
    self.bstabBar.backgroundColor= [UIColor whiteColor];
    self.bstabBar.alpha = 0.9;
    self.bstabBar.delegate = self;
    //移除系统自带的tabBar
    //[self.tabBar removeFromSuperview];
    [self.tabBar addSubview:self.bstabBar];
}

- (NSMutableArray *)items
{
    if (_items==nil)
    {
        _items = [NSMutableArray array];
    }
    return _items;
}

//UITabBarButton
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //移除系统自带的UITabBarButton
    for (UIView *view in self.tabBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [view removeFromSuperview];
        }
    }
}
- (void)setUpChildControllers
{
    NSArray *controllerArray = @[@"XXYHomeController",@"XXYStudyController",@"XXYPlaygroundController",@"XXYMeController"];
    NSArray *imageArray = @[@"tabbar_home",@"tabbar_message_center",@"tabbar_discover",@"tabbar_profile"];
    NSArray *imageSelectedArray = @[@"tabbar_home_selected",@"tabbar_message_center_selected",@"tabbar_discover_selected",@"tabbar_profile_selected"];
    
    NSArray *titleArray = @[@"首页",@"班群",@"操场",@"我"];
    for (NSInteger i=0; i<4; i++) {
        UIViewController *vc = [[NSClassFromString(controllerArray[i]) alloc] init];
        [self addOneChildController:vc image:[UIImage imageNamed:imageArray[i]] selectedImage:[UIImage imageWithOriginalNamed:imageSelectedArray[i]] title:titleArray[i] badgeValue:@"0"];
    }
    //NSLog(@"count = %li", self.viewControllers.count);
    //传递tabBarItems
    _bstabBar.items = self.items;
}

//添加一个子视图控制器
- (void)addOneChildController:(UIViewController *)vc image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title badgeValue:(NSString *)badge
{
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selectedImage;
    vc.tabBarItem.title = title;
    //vc.tabBarItem.badgeValue  = badge;
    [self.items addObject:vc.tabBarItem];
    
    XXYNavigationController *nav = [[XXYNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

//设置选中的视图
- (void)tabBarDidClicked:(BSTabBar *)tabBar selectedIndex:(NSInteger)selectedIndex
{
    if(selectedIndex==100)
    {
        for (UIView*view in [_bgSosView subviews])
        {
            [view removeFromSuperview];
        }
        [_bgSosView removeFromSuperview];
    }
   else if(selectedIndex==101)
    {
        [self setUpLocationManager];
        [self setUpSosView];
        [self getWarningTime];
        //判断定位功能是否使能
        if([CLLocationManager locationServicesEnabled])
        {
        }
        else
        {
            [self setUpAlertController:@"定位服务没有启用,请启用定位功能"];
        }
    }
    else
    {
        self.selectedIndex = selectedIndex;
    }
}
-(void)setUpSosView
{
    //背景视图
    _bgSosView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH-56)];
    _bgSosView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_bgSosView];
    
    //主视图
    _sosView=[[UIView alloc]initWithFrame:CGRectMake(30, _bgSosView.frame.size.height-MainScreenH*3/4, MainScreenW-60, MainScreenH*3/4)];
    _sosView.backgroundColor=[UIColor whiteColor];
    [_bgSosView addSubview:_sosView];
    //上面两个设置为圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_sosView.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _sosView.bounds;
    maskLayer.path = maskPath.CGPath;
    _sosView.layer.mask = maskLayer;
    
    //绿色背景
    _bgIconImageView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, _sosView.frame.size.width, _sosView.frame.size.height/2)];
    _bgIconImageView.backgroundColor=[UIColor colorWithRed:70.0/255 green:171.0/255 blue:15.0/255 alpha:1.0];
    [_sosView addSubview:_bgIconImageView];
    
    //到家签到label
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(15, 0,80, 50)];
    label.text=@"到家签到";
    label.textColor=[UIColor whiteColor];
    [_bgIconImageView addSubview:label];
    
    //预计到达时间label
    _safeTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 0,_sosView.frame.size.width-80-40, 50)];
    _safeTimeLabel.text=@"预计到达时间: -- ";
    _safeTimeLabel.textAlignment=NSTextAlignmentRight;
    _safeTimeLabel.textColor=[UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.8];
    _safeTimeLabel.font=[UIFont systemFontOfSize:12];
    [_bgIconImageView addSubview:_safeTimeLabel];
    
    //设置安全时间按钮
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(_sosView.frame.size.width-35, 15,20, 20);
    [btn setImage:[UIImage imageNamed:@"safe-setting"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(safeSettingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgIconImageView addSubview:btn];
    
    //我到家了按钮
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(_sosView.frame.size.width*1/4, 50, _sosView.frame.size.width*1/2, _sosView.frame.size.width*1/2)];
    imageView.layer.cornerRadius=_sosView.frame.size.width*1/4;
    imageView.image=[UIImage imageNamed:@"safe-home-btn"];
    UITapGestureRecognizer * pictureTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAvatarView:)];
    imageView.userInteractionEnabled=YES;
    [imageView addGestureRecognizer:pictureTap];
    [_bgIconImageView addSubview:imageView];
    
    //呼救,小报告 两个按钮
    NSArray*btnNameArray=@[@"呼救",@"小报告"];
    for(int i=0;i<2;i++)
    {
        UIButton*sosBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        sosBtn.frame=CGRectMake(_sosView.frame.size.width/2*i, _sosView.frame.size.height/2, _sosView.frame.size.width/2, 50);
        [sosBtn setTitle:btnNameArray[i] forState:UIControlStateNormal];
        sosBtn.tag=50+i;
        if(i==0)
        {
            [sosBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
        else
        {
            [sosBtn setTitleColor:[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
        sosBtn.titleLabel.font=[UIFont systemFontOfSize:18];
        
        [sosBtn addTarget:self action:@selector(sosBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [_sosView addSubview:sosBtn];
    }
    
    //下划线label
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};
    CGSize size=[@"呼救" sizeWithAttributes:attrs];
    //UILabel*labelLine=[[UILabel alloc]initWithFrame:CGRectMake((_sosView.frame.size.width/2-(_sosView.frame.size.width/4-25))/2, _sosView.frame.size.height/2+40, (_sosView.frame.size.width/4-25), 2)];
    UILabel*labelLine=[[UILabel alloc]initWithFrame:CGRectMake((_sosView.frame.size.width/2-size.width)/2, _sosView.frame.size.height/2+40, size.width, 2)];
    labelLine.tag=200;
    labelLine.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [_sosView addSubview:labelLine];
    
    //内容的TextView
    _contentTextView=[[UITextView alloc]initWithFrame:CGRectMake(15, _sosView.frame.size.height/2+65, _sosView.frame.size.width-30, (_sosView.frame.size.height/2-70)/2-20)];
    _contentTextView.layer.borderColor=[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0].CGColor;
    _contentTextView.layer.borderWidth=1;
    _contentTextView.layer.cornerRadius=5;
    _contentTextView.font=[UIFont systemFontOfSize:14];
    _contentTextView.delegate=self;
    _contentTextView.backgroundColor=[UIColor colorWithRed:236.0/255 green:240.0/255 blue:242.0/255 alpha:1.0];
    _contentTextView.textColor=[UIColor colorWithRed:169.0/255 green:169.0/255 blue:169.0/255 alpha:1.0];
    [_sosView addSubview:_contentTextView];
    
    //TextView的提示label
    _placeHoderLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 0, _contentTextView.frame.size.width-10, 40)];
    _placeHoderLabel.numberOfLines=0;
    _placeHoderLabel.textColor=[UIColor colorWithRed:169.0/255 green:169.0/255 blue:169.0/255 alpha:1.0];
    _placeHoderLabel.text = @"如果你遇到紧急情况,请输入详细的内容,100个字以内";
    _placeHoderLabel.enabled=NO;
    _placeHoderLabel.alpha=0.5;
    _placeHoderLabel.font=[UIFont systemFontOfSize:14];
    [_contentTextView addSubview:_placeHoderLabel];
    
    //求救按钮
    _sosBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _sosBtn.frame=CGRectMake(15, _sosView.frame.size.height/2+70+(_sosView.frame.size.height/2-70)/2, _sosView.frame.size.width-30, 40);
    _sosBtn.layer.cornerRadius=5;
    _sosBtn.tag=60;
    [_sosBtn setBackgroundColor:[UIColor colorWithRed:255.0/255 green:102.0/255 blue:31.0/255 alpha:1.0]];
    [_sosBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sosBtn setTitle:@"发送求救信息" forState:UIControlStateNormal];
    _sosBtn.titleLabel.font=[UIFont systemFontOfSize:19];
    [_sosBtn addTarget:self action:@selector(sosAndReportBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_sosView addSubview:_sosBtn];
}
-(void)textViewDidChange:(UITextView *)textView
{
    self.contentTextView.text =  textView.text;
    if (textView.text.length == 0)
    {
        if(_sosBtn.tag==60)
        _placeHoderLabel.text = @"如果你遇到紧急情况,请输入详细的内容,100个字以内";
        else
           _placeHoderLabel.text = @"如果你有什么想对老师说,请输入详细的内容,100个字以内";
    }
    else
    {
        _placeHoderLabel.text = @"";
    }
    
    if (textView.text.length > 100)
    {
        textView.text = [textView.text substringToIndex:100];
    }
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
        _bgSosView.frame=CGRectMake(0,56-height, MainScreenW, MainScreenH-56);
    }];
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
        [UIView animateWithDuration:0.5 animations:^{
        // 设置view弹出来的位置
        _bgSosView.frame=CGRectMake(0,0, MainScreenW, MainScreenH-56);
    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_contentTextView resignFirstResponder];
}
//求救和小报告按钮点击事件
-(void)sosAndReportBtnClicked:(UIButton*)btn
{
    switch (btn.tag) {
        case 60:
        {
            [self sendHelpInfo];
        }
            break;
        case 61:
        {
            [self sendReportInfo];
        }
            break;
        default:
            break;
    }
}
//求救和小报告切换按钮点击事件
-(void)sosBtnCliked:(UIButton*)btn
{
    switch (btn.tag) {
        case 51:
        {
            _contentTextView.text=nil;
            [UIView animateWithDuration:0.2 animations:^{
            // 设置view弹出来的位置
                
                NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};
                CGSize size=[@"小报告" sizeWithAttributes:attrs];
                
            ((UILabel*)[self.view viewWithTag:200]).frame=CGRectMake((_sosView.frame.size.width/2-size.width)/2+_sosView.frame.size.width/2, _sosView.frame.size.height/2+40, size.width, 2);
        }];
            [btn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [((UIButton*)[self.view viewWithTag:50]) setTitleColor:[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_sosBtn setTitle:@"发送小报告" forState:UIControlStateNormal];
            _placeHoderLabel.text=@"如果你有什么想对老师说,请输入详细的内容,100个字以内";
            _sosBtn.tag=61;
        }
            break;
        case 50:
        {
            _contentTextView.text=nil;
            [UIView animateWithDuration:0.2 animations:^{
                // 设置view弹出来的位置
                
                NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:17]};
                CGSize size=[@"呼救" sizeWithAttributes:attrs];

                ((UILabel*)[self.view viewWithTag:200]).frame=CGRectMake((_sosView.frame.size.width/2-size.width)/2, _sosView.frame.size.height/2+40, size.width, 2);
            }];
            [btn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [((UIButton*)[self.view viewWithTag:51]) setTitleColor:[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0] forState:UIControlStateNormal];
            
            [_sosBtn setTitle:@"发送求救信息" forState:UIControlStateNormal];
            _placeHoderLabel.text=@"如果你遇到紧急情况,请输入详细的内容,100个字以内";
            _sosBtn.tag=60;
        }
            break;
        default:
            break;
    }
}
//我到家了 按钮点击事件
-(void)tapAvatarView:(UITapGestureRecognizer*)tap
{
     [self sendArrivedHomeInfo];
}
//安全时间设置按钮点击事件
-(void)safeSettingBtnClicked:(UIButton*)btn
{
    XXYSOSController*vc=[[XXYSOSController alloc]init];
    [self presentViewController:vc animated:NO completion:nil];

}
//发送求救
-(void)sendHelpInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/sos/msg/send"];
    
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"longitude":[NSString stringWithFormat:@"%f",_coordinate.longitude],@"latitude":[NSString stringWithFormat:@"%f",_coordinate.latitude],@"content":_contentTextView.text} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
      [self setUpAlertController:objString[@"message"]];
           } failure:^(NSError *error) {
    }];
}
//发送我到家了信息
-(void)sendArrivedHomeInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/safe/msg/send"];
    //coordinate.latitude,coordinate.longitude
    //NSLog(@"11=%@,22==%@",[NSString stringWithFormat:@"%f",_coordinate.longitude],[NSString stringWithFormat:@"%f",_coordinate.latitude]);
    if(_coordinate.longitude&&_coordinate.latitude&&userSidString)
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"longitude":[NSString stringWithFormat:@"%f",_coordinate.longitude],@"latitude":[NSString stringWithFormat:@"%f",_coordinate.latitude],@"content":@""} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [self setUpAlertController:objString[@"message"]];
        
    } failure:^(NSError *error) {
    }];
}
//设置地理位置管理器
-(void)setUpLocationManager
{
    _locationManager=[[CLLocationManager alloc]init];
    //判断受权状态
    if([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedAlways)
    {
        [_locationManager requestAlwaysAuthorization];
    }
    //设置为kCLDistanceFilterNone,位置每秒更新一次
    _locationManager.distanceFilter=kCLDistanceFilterNone;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    //设置代理
    _locationManager.delegate=self;
    [_locationManager startUpdatingLocation];
}
//代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation*location=[locations lastObject];
    _coordinate=location.coordinate;
//    NSLog(@"%f,%f",coordinate.latitude,coordinate.longitude);
//    NSLog(@"%@",location);
}
//发送小报告
-(void)sendReportInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/sneaking/msg/send"];
    
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"content":_contentTextView.text} success:^(id responseObject){
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self setUpAlertController:@"发送成功"];
        }
        else
        {
            [self setUpAlertController:@"发送失败"];
        }
    } failure:^(NSError *error) {
    }];
}
//获取安全时间
-(void)getWarningTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/sos/msg/getWarningTime"];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        //{"code":0,"message":"success","data":{"expectTime":"10:00:00","timeOut":1800}}
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString*dateString=objString[@"data"][@"expectTime"];
        if([dateString isEqualToString:@""])
        _safeTimeLabel.text=[NSString stringWithFormat:@"%@%@",@"预计到达时间: -- ",dateString];
        else
            
        _safeTimeLabel.text=[NSString stringWithFormat:@"%@%@",@"预计到达时间:",dateString];
    } failure:^(NSError *error) {
    }];
}
//设置弹框
-(void)setUpAlertController:(NSString*)string
{
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:@"提示" message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

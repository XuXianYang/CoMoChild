#import "XXYAbandonCaloriesDetailController.h"
#import "XXYBackButton.h"
#import "XXYPublishDynamicController.h"
#import "XXYBurnCaloriesController.h"
#import "BSHttpRequest.h"
#import "UIImageView+WebCache.h"

#import <UShareUI/UShareUI.h>


@interface XXYAbandonCaloriesDetailController ()<UMSocialShareMenuViewDelegate>

@property(nonatomic,strong)UIImageView*iconImageView;


@end

@implementation XXYAbandonCaloriesDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.navigationItem.title=@"酷么公益";
    self.view.backgroundColor=[UIColor whiteColor];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton*shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:[UIImage imageNamed:@"icon_share_nav"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.frame=CGRectMake(0, 0, 30, 30);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:shareBtn];
    
    [self setUpSubViews];
    [self loadUserIcon];
    
    
    //设置用户自定义的平台
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),
                                               @(UMSocialPlatformType_WechatTimeLine),
                                               @(UMSocialPlatformType_WechatFavorite),
                                               @(UMSocialPlatformType_QQ),
                                               @(UMSocialPlatformType_Qzone),
                                               @(UMSocialPlatformType_Sina)
                                               ]];
    //设置分享面板的显示和隐藏的代理回调
    [UMSocialUIManager setShareMenuViewDelegate:self];

}
-(void)loadUserIcon
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:objString[@"data"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
        
    } failure:^(NSError *error) {}];
}
-(void)setUpSubViews
{
    UIImageView*adImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenW*3/4)];
    adImageView.contentMode=UIViewContentModeScaleAspectFill;
    adImageView.clipsToBounds = YES;
    adImageView.image=[UIImage imageNamed:@"benefit_bg"];
    [self.view addSubview:adImageView];
    
    //NSLog(@"width=%.2f",MainScreenW-240);
    
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2, 50, 100, 100)];
    _iconImageView.layer.cornerRadius=50;
    _iconImageView.layer.masksToBounds=YES;
    if(self.iconImage)
    _iconImageView.image=self.iconImage;
    [adImageView addSubview:_iconImageView];
    
    UILabel*thankLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 150, MainScreenW-40, MainScreenW*3/4-150)];
    thankLabel.text=@"感谢您的帮助\n- -  酷么公益  - -";
    thankLabel.numberOfLines=0;
    thankLabel.textAlignment=NSTextAlignmentCenter;
    thankLabel.textColor=[UIColor colorWithRed:255.0/255 green:19.0/255 blue:16.0/255 alpha:1.0];
    thankLabel.font=[UIFont systemFontOfSize:19];
    [adImageView addSubview:thankLabel];
    
   // NSLog(@"%@  %@  %@",self.money,self.myCalories,self.comName);
    if(!self.money)
    {
        self.money=@"00";
    }
    if(!self.money)
    {
        self.myCalories=@"00";
    }
    if(!self.comName)
    {
        self.comName=@"xxx";
    }
    
    NSArray*nameArr=@[@"本次捐卡",[NSString stringWithFormat:@"%i千卡",[self.myCalories integerValue]/1000],[NSString stringWithFormat:@"%@为您的爱心随机捐出%@块钱",self.comName,self.money],@"点击右上角,邀请小伙伴一起来"];
    
    for(int i=0;i<4;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]init];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.text=nameArr[i];
        
        switch (i)
        {
            case 0:
            {
                titleLabel.textColor=[UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
                titleLabel.font=[UIFont systemFontOfSize:12];
                
                titleLabel.frame=CGRectMake(50, MainScreenW*3/4+15, MainScreenW-100, [nameArr[i] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}].height);
                
            }
                break;
            case 1:
            {
                titleLabel.font=[UIFont systemFontOfSize:30];
                titleLabel.textColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
                titleLabel.frame=CGRectMake(50, MainScreenW*3/4+30+[nameArr[i-1] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}].height, MainScreenW-100, [nameArr[i] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30]}].height);
            }
                break;
            case 2:
            {
                titleLabel.font=[UIFont systemFontOfSize:18];
                titleLabel.numberOfLines=0;
                titleLabel.frame=CGRectMake( 15, MainScreenW*3/4+45+[nameArr[i-2] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}].height+[nameArr[i-1] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30]}].height, MainScreenW-30, 50);
            }
                break;
            case 3:
            {
                titleLabel.font=[UIFont systemFontOfSize:13];
                titleLabel.textColor=[UIColor colorWithRed:192.0/255 green:192.0/255 blue:192.0/255 alpha:1.0];
                
                titleLabel.frame=CGRectMake( 15, MainScreenW*3/4+110+[nameArr[i-3] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}].height+[nameArr[i-2] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:30]}].height, MainScreenW-30, [nameArr[i] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]}].height);
            }
                break;

            default:
                break;
        }
        [self.view addSubview:titleLabel];
    }
}
-(void)shareBtnClicked:(UIButton*)btn
{
    [self showBottomNormalView];
//    XXYPublishDynamicController*pubCon=[[XXYPublishDynamicController alloc]init];
//    [self presentViewController:pubCon animated:YES completion:nil];
}
- (void)showBottomNormalView
{
    //加入copy的操作
    //@see http://dev.umeng.com/social/ios/进阶文档#6
    [UMSocialUIManager addCustomPlatformWithoutFilted:UMSocialPlatformType_UserDefine_Begin+2
                                     withPlatformIcon:[UIImage imageNamed:@"kumo_share_icon"]
                                     withPlatformName:@"酷么校园"];
//
    [UMSocialShareUIConfig shareInstance].sharePageGroupViewConfig.sharePageGroupViewPostionType = UMSocialSharePageGroupViewPositionType_Bottom;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageItemStyleType = UMSocialPlatformItemViewBackgroudType_None;
#ifdef UM_Swift
    [UMSocialSwiftInterface showShareMenuViewInWindowWithPlatformSelectionBlockWithSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary* userInfo) {
#else
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
#endif
            //在回调里面获得点击的
            if (platformType == UMSocialPlatformType_UserDefine_Begin+2) {
               // NSLog(@"点击演示添加Icon后该做的操作");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    XXYPublishDynamicController*publishCon=[[XXYPublishDynamicController alloc]init];
                    publishCon.shareIndex=2;
                    publishCon.shareString=[NSString stringWithFormat:@"我在酷么公益捐赠了 %@ 卡路里,帮助了%@,快来和我一起参与吧!",self.myCalories,self.comName];
                    [self presentViewController:publishCon animated:YES completion:nil];
                });
            }
            else{
                [self runShareWithType:platformType];
            }
        }];
}
- (void)runShareWithType:(UMSocialPlatformType)type
{
//    UMShareTypeViewController *VC = [[UMShareTypeViewController alloc] initWithType:type];
//    [self.navigationController pushViewController:VC animated:YES];
    [self shareWebPageToPlatformType:type];
}
//网页分享
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
    {
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        
        //创建网页内容对象
        //NSString* thumbURL =  UMS_THUMB_IMAGE;
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"我锻炼 我公益 我快乐" descr:@"公益也可以做运动,大家快来和我一起运动吧!" thumImage:[UIImage imageNamed:@"calorie_share_icon"]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary*userInfo=[defaults objectForKey:@"userInfo"];
       // NSLog(@"%@",userInfo);
        if(self.comName&&self.money&&self.myCalories)
        {
//            NSString*urlString=[NSString stringWithFormat:@"http://www.comoclass.com/sharechari.html?com=%@&cal=%@&img=%@",[NSString stringWithFormat:@"%@为您的爱心随机捐出%@块钱",self.comName,self.money],[NSString stringWithFormat:@"%li千卡",[self.myCalories integerValue]/1000 ],userInfo[@"user"][@"avatarUrl"]];
            
            NSString*urlString=[NSString stringWithFormat:@"https://opus.comoclass.com/homepage/sharechari.html?com=%@&cal=%@&img=%@",[NSString stringWithFormat:@"%@捐出%@块钱",@"希流斯",self.money],[NSString stringWithFormat:@"%li千卡",[self.myCalories integerValue]/1000 ],userInfo[@"user"][@"avatarUrl"]];
            
            //设置网页地址
        urlString= [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        shareObject.webpageUrl = urlString;
            //shareObject.webpageUrl = @"http://www.comoclass.com/sharechari.html";
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
        }
#ifdef UM_Swift
        [UMSocialSwiftInterface shareWithPlattype:platformType messageObject:messageObject viewController:self completion:^(UMSocialShareResponse * data, NSError * error) {
#else
            //调用分享接口
            [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
#endif
                if (error)
                {
                    UMSocialLogInfo(@"************Share fail with error %@*********",error);
                }
                else
                {
                    if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                        UMSocialShareResponse *resp = data;
                        //分享结果消息
                        UMSocialLogInfo(@"response message is %@",resp.message);
                        //第三方原始返回的数据
                        UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                        
                    }else{
                        UMSocialLogInfo(@"response data is %@",data);
                    }
                }
                [self alertWithError:error];
            }];
}
- (void)alertWithError:(NSError *)error
{
            NSString *result = nil;
            if (!error)
            {
                result = [NSString stringWithFormat:@"分享成功!"];
            }
            else{
                NSMutableString *str = [NSMutableString string];
                if (error.userInfo)
                {
                    for (NSString *key in error.userInfo)
                    {
                        [str appendFormat:@"%@ = %@\n", key, error.userInfo[key]];
                    }
                }
                if (error)
                {
                    result = [NSString stringWithFormat:@"分享失败: %d\n%@",(int)error.code, str];
                }
                else
                {
                    result = [NSString stringWithFormat:@"分享失败!"];
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:result
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
}

-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

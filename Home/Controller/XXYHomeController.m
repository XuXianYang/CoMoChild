#import "XXYHomeController.h"
#import"XXYTimeTableController.h"
#import "XXYSubjectCoursewareController.h"
#import "XXYHomeworkController.h"
#import "XXYTestFluidController.h"
#import "XXYMyToolsViewController.h"
#import"XXYClassAnnouncementsController.h"
#import "UIColor+Wonderful.h"
#import "SXMarquee.h"
#import "BSHttpRequest.h"
#import "XXYBurnCaloriesController.h"
#import "XXYMatchController.h"
#import"XXYJoinSchoolController.h"
@interface XXYHomeController ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView*scrollView;
@property(nonatomic,strong)UIPageControl*pageControl;
@property(nonatomic,strong)UIScrollView*adScrollView;
@property(nonatomic,strong)UIView*announcementView;
@property(nonatomic,strong)SXMarquee*sxMarquee;
@property(nonatomic,assign)CGFloat adHeight;

@end

@implementation XXYHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=@"";
    self.view.backgroundColor=XXYBgColor;
    
    [self getNewAnnouncementData];
    [self setUpSubViews];
    [self setUpNewButtons];
}
-(void)getUpNewUserInfoData:(UIViewController*)vc
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSDictionary*userInfoDict=[defaults objectForKey:@"joinClass"];
    
    if(userInfoDict[@"classId"]&&userInfoDict[@"schoolId"])
    {
        [self.navigationController pushViewControllerWithAnimation:vc];

    }
    else
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary*dict=objString[@"data"][@"studentInfo"];
        NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
        [defaultss setObject:dict forKey:@"joinClass"];

        if(dict[@"classId"]&&dict[@"schoolId"])
        {
            [self.navigationController pushViewControllerWithAnimation:vc];

        }
        else
        {
            [self setUpAlertController:@"请先加入班级~"];
        }
           } failure:^(NSError *error) {}];
}
-(void)viewDidAppear:(BOOL)animated
{
    self.navigationItem.title=@"";
    //状态栏颜色为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_sxMarquee start];
}
-(void)setUpNewButtons
{
    for(int i=0;i<7;i++)
    {
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(10, ((MainScreenW-20)*138/353+5)*i-64+10, MainScreenW-20, (MainScreenW-20)*138/353) ;
        btn.tag=200+i;
        [btn addTarget:self  action:@selector(newBtnClicked:)
      forControlEvents:UIControlEventTouchUpInside];
        
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"jpg-course%i",i+1]]  forState:UIControlStateNormal];
        [self.scrollView addSubview:btn];
    }
}
-(void)newBtnClicked:(UIButton*)btn
{
NSArray*controllersArr=@[@"XXYTimeTableController",@"XXYSubjectCoursewareController",@"XXYHomeworkController",@"XXYTestFluidController",@"XXYMyToolsViewController",@"XXYBurnCaloriesController",@"XXYMatchController"];
    UIViewController*vc=[[NSClassFromString(controllersArr[btn.tag-200]) alloc]init];
    vc.hidesBottomBarWhenPushed=YES;
    
    if(btn.tag<=204)
    {
        [self getUpNewUserInfoData:vc];
    }
    else
    {
        
        [self.navigationController pushViewControllerWithAnimation:vc];
    }
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [action1 setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
    [alertCon addAction:action1];

    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
       
        XXYJoinSchoolController*joinCon=[[XXYJoinSchoolController alloc]init];
        [self presentViewController:joinCon animated:YES completion:nil];
    }];
    [action setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alertCon addAction:action];
    [self presentViewController:alertCon animated:YES completion:nil];
}

-(void)setUpSubViews
{
    
    CGFloat adHeight=0;
    if([[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        adHeight=300;
    }
    else
    {
        adHeight=150;
    }

    _adHeight=adHeight;
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,adHeight+40, MainScreenW, MainScreenH-adHeight-40-49)];
    _scrollView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    //_scrollView.bounces=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.delegate=self;
    //CGFloat btnH=(MainScreenH-64-49-MainScreenW*2/5-15)/2;
    //CGFloat scrolloViewH=161+btnH+5+(btnH-5)/2+(btnH-5)/2+70;
    
    _scrollView.contentSize=CGSizeMake(0,((MainScreenW-20)*138/353+5)*7+10-64+10);
    
    [self.view addSubview:_scrollView];

//    //广告
    NSArray*imageNameArray=@[@"banner_2",@"banner1",@"homeslide3"];
    _adScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, adHeight)];
    _adScrollView.backgroundColor=[UIColor lightGrayColor];
    _adScrollView.pagingEnabled=YES;
    _adScrollView.showsHorizontalScrollIndicator=NO;
    _adScrollView.bounces=NO;
    _adScrollView.scrollEnabled=YES;
    _adScrollView.contentSize=CGSizeMake(MainScreenW*imageNameArray.count, 0);
    _adScrollView.delegate=self;
    _adScrollView.tag=100;
    [self.view addSubview:_adScrollView];
    
    for(int i=0;i<imageNameArray.count;i++)
    {
        UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*MainScreenW, 0, MainScreenW, adHeight)];
        imageView.tag=460+i;
        imageView.clipsToBounds=YES;
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.image=[UIImage imageNamed:imageNameArray[i]];
        imageView.userInteractionEnabled = YES;
        [_adScrollView addSubview:imageView];
    }
    
    [_adScrollView scrollRectToVisible:CGRectMake(_adScrollView.frame.size.width, 0, _adScrollView.frame.size.width, _adScrollView.frame.size.height) animated:YES];
    
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(100,adHeight-30, MainScreenW-200, 30)];
    _pageControl.numberOfPages=imageNameArray.count;
    _pageControl.currentPage=0;
    _pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
    _pageControl.pageIndicatorTintColor=[UIColor blueColor];
    [self.view addSubview:_pageControl];

    
    _announcementView=[[UIView alloc]initWithFrame:CGRectMake(0, adHeight, MainScreenW, 40)];
    _announcementView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_announcementView];
    
    UILabel*maskLabel=[[UILabel alloc]initWithFrame:CGRectMake(5, 10, 80, 20)];
    maskLabel.text=@" 班级公告";
    maskLabel.font=[UIFont systemFontOfSize:15];
    maskLabel.textColor=[UIColor blueColor];
    maskLabel.layer.borderColor=[UIColor blueColor].CGColor;
    maskLabel.layer.borderWidth=1.0;
    maskLabel.textAlignment=NSTextAlignmentCenter;
    [_announcementView addSubview:maskLabel];
    
}

-(void)getNewAnnouncementData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/announcement/latest"];
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
           // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray*dataArray=objString[@"data"];
            if(dataArray.count>0)
            {
                NSDictionary*dict=dataArray[0];
                NSString*string=[NSString stringWithFormat:@"%@:%@",dict[@"title"],dict[@"content"]];
                [self setUpSXMarquee:string];
            }
            else
                
            {
                [self setUpSXMarquee:@"班级公告:重大消息,点击查看班级公告!"];
            }
            } failure:^(NSError *error) {
                [self setUpSXMarquee:@"班级公告:重大消息,点击查看班级公告!"];
        }];
}
-(void)setUpSXMarquee:(NSString*)title
{
    [_sxMarquee removeFromSuperview];
    _sxMarquee = [[SXMarquee alloc]initWithFrame:CGRectMake(90, 10, MainScreenW-95, 20) speed:4 Msg:title bgColor:[UIColor lightBLue] txtColor:[UIColor whiteColor]];
    [_sxMarquee changeMarqueeLabelFont:[UIFont systemFontOfSize:15]];
    [_sxMarquee changeTapMarqueeAction:^{
        
                XXYClassAnnouncementsController*annoCon=[[XXYClassAnnouncementsController alloc]init];
        annoCon.hidesBottomBarWhenPushed=YES;
        [self getUpNewUserInfoData:annoCon];
        
    }];
    [_sxMarquee start];
    [_announcementView addSubview:_sxMarquee];
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag==100)
    {
        NSInteger index=scrollView.contentOffset.x/scrollView.frame.size.width;
        self.pageControl.currentPage=index;
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   // NSLog(@"hight=%.2f",scrollView.contentOffset.y);
    
    if(scrollView==_scrollView)
    {
        if(scrollView.contentOffset.y<-64)
        {
            _adScrollView.frame=CGRectMake(0, 0, MainScreenW, _adHeight-scrollView.contentOffset.y-64);
            _announcementView.frame=CGRectMake(0, _adHeight-scrollView.contentOffset.y-64, MainScreenW, 40);
            _pageControl.frame=CGRectMake(100,_adHeight-30-scrollView.contentOffset.y-64, MainScreenW-200, 30);
            for(int i=0;i<3;i++)
            {
                UIImageView*imageView=[self.view viewWithTag:460+i];
                imageView.frame=CGRectMake(i*MainScreenW, 0, MainScreenW, _adHeight-scrollView.contentOffset.y-64);
            }
        }
    }
   }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

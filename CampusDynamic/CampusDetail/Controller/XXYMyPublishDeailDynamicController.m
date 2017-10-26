#import "XXYMyPublishDeailDynamicController.h"
#import "XXYBackButton.h"
#import <UIImageView+WebCache.h>

#import "XXYCamDyController.h"
@interface XXYMyPublishDeailDynamicController ()

@end

@implementation XXYMyPublishDeailDynamicController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpSubViews];
}
-(void)setUpSubViews
{
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"我的发布";
    
    //返回按钮
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    //全部
    XXYCamDyController *allVc = [[XXYCamDyController alloc] init];
    allVc.getUrl=kmyPublishDynamicUrl;
    [self addChildViewController:allVc];
    allVc.view.frame =self.view.bounds;
    [self.view addSubview:allVc.view];
    
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"内存不足");
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];

    // Dispose of any resources that can be recreated.
}


@end

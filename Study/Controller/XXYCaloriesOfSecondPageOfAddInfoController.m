#import "XXYCaloriesOfSecondPageOfAddInfoController.h"
#import "XXYBackButton.h"
@interface XXYCaloriesOfSecondPageOfAddInfoController ()

@end

@implementation XXYCaloriesOfSecondPageOfAddInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"广告详情";
    self.view.backgroundColor=[UIColor whiteColor];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIWebView *webView= [[UIWebView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    [self.view addSubview:webView];
    NSString*urlString=@"http://www.comoclass.com";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    webView.userInteractionEnabled=YES;
    webView.scrollView.scrollEnabled = YES;
    webView.scrollView.bounces=NO;
    [webView loadRequest:request];

}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

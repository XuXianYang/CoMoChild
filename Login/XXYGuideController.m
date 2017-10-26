#import "XXYGuideController.h"
#import "XXYLoginController.h"
#import "XXYRegisterController.h"
@interface XXYGuideController ()<UIScrollViewDelegate>

@property(nonatomic,strong)UIScrollView*guideScrollView;

@property(nonatomic,strong)UIButton*guideRegisterBtn;
@property(nonatomic,strong)UIButton*guideLoginBtn;

@property(nonatomic,strong)UIPageControl*pageControl;
@end
@implementation XXYGuideController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpGuideScrollowView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setUpBtns];

}
-(void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];//cyruspublicios201703060959258680
}
-(void)setUpGuideScrollowView
{
    
    CGFloat sHeight=0.0;
    if(MainScreenW*22/15>MainScreenH*3/4-20)
    {
        sHeight=MainScreenH*3/4+40;
    }
    else
    {
        sHeight=MainScreenW*22/15;
    }

    _guideScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, -44, MainScreenW, sHeight)];
    _guideScrollView.bounces=NO;
    _guideScrollView.pagingEnabled=YES;
    _guideScrollView.scrollEnabled=YES;
    
    _guideScrollView.contentSize=CGSizeMake(MainScreenW*3, 0);
    _guideScrollView.showsHorizontalScrollIndicator=NO;
    _guideScrollView.delegate=self;
    [self.view addSubview:_guideScrollView];
    
    for(int i=0;i<3;i++)
    {
        UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*MainScreenW, 0, MainScreenW, sHeight)];
        imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"slide%i.jpg",4+i]];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode=UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [_guideScrollView addSubview:imageView];
    }
    
   
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(100,MainScreenH*3/4-20, MainScreenW-200, 30)];
    _pageControl.numberOfPages=3;
    _pageControl.currentPage=0;
    _pageControl.currentPageIndicatorTintColor=[UIColor orangeColor];
    _pageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
    [self.view addSubview:_pageControl];

}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index=scrollView.contentOffset.x/scrollView.frame.size.width;
    self.pageControl.currentPage=index;
}
-(void)setUpBtns
{

    _guideLoginBtn=[[UIButton alloc]initWithFrame:CGRectMake((MainScreenW-30)/2+20, MainScreenH*3/4+50, (MainScreenW-30)/2, 50)];
    _guideLoginBtn.layer.cornerRadius=5;
    _guideLoginBtn.layer.borderWidth=1;
    _guideLoginBtn.layer.borderColor=[UIColor orangeColor].CGColor;
    [_guideLoginBtn setBackgroundColor:[UIColor whiteColor]];
    [_guideLoginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_guideLoginBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [_guideLoginBtn addTarget:self action:@selector(loginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _guideLoginBtn.userInteractionEnabled=YES;
    [self.view addSubview:_guideLoginBtn];

    
    _guideRegisterBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, MainScreenH*3/4+50, (MainScreenW-30)/2, 50)];
    _guideRegisterBtn.layer.cornerRadius=5;
    _guideRegisterBtn.layer.borderColor=[UIColor orangeColor].CGColor;
    [_guideRegisterBtn setBackgroundColor:[UIColor orangeColor]];
    [_guideRegisterBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_guideRegisterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_guideRegisterBtn addTarget:self action:@selector(registerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _guideRegisterBtn.userInteractionEnabled=YES;
    [self.view addSubview:_guideRegisterBtn];
}
-(void)loginBtnClicked:(UIButton*)btn
{
    XXYLoginController*loginCon=[[XXYLoginController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:loginCon];
}
-(void)registerBtnClicked:(UIButton*)btn
{
    XXYRegisterController*registerBtn=[[XXYRegisterController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:registerBtn];

}
@end

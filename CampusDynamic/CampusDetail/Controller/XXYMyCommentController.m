#import "XXYMyCommentController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYMyPraiseTableView.h"
//#import "XXYCommentDetailController.h"
#import "XXYCamDyDetailController.h"
@interface XXYMyCommentController ()<XXYTurnNextPageDelegate,XXYReloadDataDelegate>
@property(nonatomic,strong)UIScrollView*bgScrollView;
@property(nonatomic,strong)UIButton*praiseMeBtn;
@property(nonatomic,strong)UIButton*myPraiseBtn;

@end

@implementation XXYMyCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=XXYBgColor;
    
    //返回按钮
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self setUpNavigationTitleBtn];
    
    [self setUpCommentTableView];
    
}
-(void)sendToReloadData
{
    for(NSInteger i=0;i<2;i++)
    {
        XXYMyPraiseTableView*myPraiseTableView=[self.view viewWithTag:10+i];
        [myPraiseTableView addRefreshLoadMore];
    }
}
-(void)turnNextPage:(NSString *)dynamicId
{
    XXYCamDyDetailController*com=[[XXYCamDyDetailController alloc]init];
    com.actId=dynamicId;
    com.reloadDelegate=self;
    com.messIndex=1;
    [self.navigationController pushViewControllerWithAnimation:com];
}
-(void)setUpCommentTableView
{
    NSArray*urlArr=@[kCommentMeUrl,kMyCommentUrl];
    for (NSInteger i=0;i<2;i++ )
    {
        XXYMyPraiseTableView*myPraiseTableView= [XXYMyPraiseTableView contentTableView];
        myPraiseTableView.getDataUrl=urlArr[i];
        myPraiseTableView.backgroundColor=XXYBgColor;
        myPraiseTableView.turnDelegate=self;
        myPraiseTableView.tag=10+i;
        myPraiseTableView.frame=CGRectMake(MainScreenW*i, 0, _bgScrollView.frame.size.width, _bgScrollView.frame.size.height);
        [myPraiseTableView addRefreshLoadMore];
        [_bgScrollView addSubview:myPraiseTableView];
    }
}

-(void)setUpNavigationTitleBtn
{
    UIView*titleBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 4, 150, 36)];
    titleBgView.layer.cornerRadius=5;
    titleBgView.layer.borderWidth=1;
    titleBgView.layer.borderColor=[UIColor whiteColor].CGColor;
    titleBgView.backgroundColor=[UIColor clearColor];
    self.navigationItem.titleView=titleBgView;
    
    NSArray*nameArr=@[@"所有评论",@"我发布的"];
    for(NSInteger i=0;i<2;i++)
    {
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
        btn.tag=100+i;
        btn.frame=CGRectMake(75*i, 0, 75, 36);
        [btn addTarget:self action:@selector(titleBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:nameArr[i] forState:UIControlStateNormal];
        if(i==0)
        {
            //左边两个设置为圆角
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:btn.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerTopLeft cornerRadii:CGSizeMake(5, 5)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = btn.bounds;
            maskLayer.path = maskPath.CGPath;
            btn.layer.mask = maskLayer;
            btn.titleLabel.font=  [UIFont boldSystemFontOfSize:15.0];
            
            [btn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
            
            _myPraiseBtn=btn;
        }
        else
        {
            //上面两个设置为圆角
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:btn.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = btn.bounds;
            maskLayer.path = maskPath.CGPath;
            btn.layer.mask = maskLayer;
            btn.titleLabel.font=  [UIFont systemFontOfSize:15];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _praiseMeBtn=btn;
        }
        [titleBgView addSubview:btn];
    }
    _bgScrollView=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    _bgScrollView.contentSize=CGSizeMake(MainScreenW*2, 0);
    _bgScrollView.scrollEnabled=NO;
    [self.view addSubview:_bgScrollView];
    
}
-(void)titleBtnCliked:(UIButton*)btn
{
    switch (btn.tag) {
        case 100:
        {
            [UIView animateWithDuration:0.2 animations:^{
                _bgScrollView.contentOffset=CGPointMake(0, 0);
                [_myPraiseBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                [_myPraiseBtn setBackgroundColor:[UIColor whiteColor]];
                _myPraiseBtn.titleLabel.font=  [UIFont boldSystemFontOfSize:15.0];
                _praiseMeBtn.titleLabel.font=  [UIFont systemFontOfSize:15];
                
                
                [_praiseMeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_praiseMeBtn setBackgroundColor:[UIColor clearColor]];
                
            }];
            
        }
            break;
        case 101:
        {
            [UIView animateWithDuration:0.2 animations:^{
                _bgScrollView.contentOffset=CGPointMake(MainScreenW, 0);
                
                [_myPraiseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_myPraiseBtn setBackgroundColor:[UIColor clearColor]];
                _praiseMeBtn.titleLabel.font=  [UIFont boldSystemFontOfSize:15.0];
                _myPraiseBtn.titleLabel.font=  [UIFont systemFontOfSize:15];
                
                [_praiseMeBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                [_praiseMeBtn setBackgroundColor:[UIColor whiteColor]];
                
            }];
            
        }
            break;
            
        default:
            break;
    }
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

#import "XXYBackButton.h"
#import "XXYCheckMoreRankingListController.h"
#import "XXYRankingListModel.h"
#import "XXYRankingListTableView.h"
#import "BSHttpRequest.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
@interface XXYCheckMoreRankingListController ()

@property(nonatomic,strong)XXYRankingListTableView*rangingListTableView;
@property(nonatomic,strong)UILabel*myNumLabel;
@property(nonatomic,strong)UILabel*myNamelabel;
@property(nonatomic,strong)UILabel*myCloriesLabel;
@property(nonatomic,strong)UIImageView*myIcon;
@property(nonatomic,retain)NSDictionary*myInfoDict;

@end

@implementation XXYCheckMoreRankingListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"本月排行榜";
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _myInfoDict=[defaults objectForKey:@"userInfo"];
    
    [self setUpTabView];
    
    [self setUpSubViews];
   
}
-(void)setUpSubViews
{
    UIView*titleBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    titleBgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:titleBgView];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 49, MainScreenW, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:216.0/255 green:216.0/255 blue:216.0/255 alpha:1.0];
    [titleBgView addSubview:lineView];
    
    UIImageView*iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, 10, 30, 30)];
    iconImageView.layer.cornerRadius=15;
    iconImageView.layer.masksToBounds=YES;
    iconImageView.image=[UIImage imageNamed:@"head_bj"];
    [titleBgView addSubview:iconImageView];
    _myIcon=iconImageView;
    
    NSArray*titleArr=@[@"100以外",@"暂无",@"00"];
    if(_myInfoDict[@"user"][@"realName"])
    {
        titleArr=@[@"100以外",_myInfoDict[@"user"][@"realName"],@"00"];
    }
    for(int i=0;i<3;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]init];
        titleLabel.text=titleArr[i];
        if(i==0)
        {
            titleLabel.frame=CGRectMake(0, 10, 50, 30);
            titleLabel.textAlignment=NSTextAlignmentCenter;
            titleLabel.textColor=[UIColor colorWithRed:104.0/255 green:104.0/255 blue:104.0/255 alpha:1.0];
            titleLabel.font=[UIFont systemFontOfSize:13];
            
            _myNumLabel=titleLabel;
        }
        else if (i==1)
        {
            titleLabel.frame=CGRectMake(100, 10, 60, 30);
            titleLabel.textColor=[UIColor colorWithRed:104.0/255 green:104.0/255 blue:104.0/255 alpha:1.0];
            titleLabel.font=[UIFont systemFontOfSize:13];
            _myNamelabel=titleLabel;
        }
        else
        {
            titleLabel.frame=CGRectMake(MainScreenW-120, 10, 100, 30);
            titleLabel.textAlignment=NSTextAlignmentRight;
            titleLabel.textColor=[UIColor colorWithRed:28.0/255 green:148.0/255 blue:244.0/255 alpha:1.0];
            titleLabel.font=[UIFont systemFontOfSize:14];
            _myCloriesLabel=titleLabel;
        }
        [titleBgView addSubview:titleLabel];
    }
}
-(void)setUpTabView
{
    _rangingListTableView= [XXYRankingListTableView contentTableView];
    _rangingListTableView.frame=CGRectMake(0, 50, MainScreenW, MainScreenH-64-50);
    //[_rangingListTableView setSeparatorInset:UIEdgeInsetsZero];
    //_rangingListTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;
    _rangingListTableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    _rangingListTableView.backgroundColor=[UIColor whiteColor];
    
    UIView*headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 10)];
    headerView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    _rangingListTableView.tableHeaderView=headerView;
    _rangingListTableView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_rangingListTableView];

    [self addRefreshLoadMore];
}
//添加刷新加载更多
-(void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.rangingListTableView.mj_header = header;
}

-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*myUserId=[NSString stringWithFormat:@"%@",_myInfoDict[@"user"][@"id"]];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findRanking"];
    
    if(userSidString&&myUserId)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject) {
        
         //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.rangingListTableView.mj_header endRefreshing];

        //先清空数据源
        [self.rangingListTableView.rankingListDataList removeAllObjects];
         id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArray=obj[@"data"];
        for (int i=0;i<dataArray.count;i++)
        {
            NSDictionary*dict=dataArray[i];
            if([myUserId  isEqualToString:[NSString stringWithFormat:@"%@",dict[@"userId"]]])
            {
                _myNumLabel.text=[NSString stringWithFormat:@"%i",i+1];
                _myNamelabel.text=dict[@"user"][@"username"];
                _myCloriesLabel.text=[NSString stringWithFormat:@"%@",dict[@"totalCalorie"]];
                [_myIcon sd_setImageWithURL:[NSURL URLWithString:dict[@"user"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"icon-clustered"]];
            }
            XXYRankingListModel*model=[[XXYRankingListModel alloc]init];
            model.rankingListNum=[NSString stringWithFormat:@"%i",i+1];
            model.rankingListName=dict[@"user"][@"username"];
            model.rankingListOfCalories=[NSString stringWithFormat:@"%@",dict[@"totalCalorie"]];
            model.rankingListIcon=dict[@"user"][@"avatarUrl"];
            [self.rangingListTableView.rankingListDataList addObject:model];
        }
        [self.rangingListTableView reloadData];
    } failure:^(NSError *error) {
        [self.rangingListTableView.mj_header endRefreshing];
    }];
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
}
@end

#import "XXYPublicBenefitRecordController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYPublicBenefitRecordModel.h"
#import "XXYPublicBenefitRecordCell.h"
#import "MJRefresh.h"
#import "XXYAbandonCaloriesDetailController.h"
@interface XXYPublicBenefitRecordController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _currentPage;
}

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UILabel*totalCaloriesLabel;
@property(nonatomic,strong)UIImageView*imageView;

@end

@implementation XXYPublicBenefitRecordController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"公益记录";
    self.view.backgroundColor=XXYBgColor;
    _currentPage=1;
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpTableView];
    [self addRefreshLoadMore];
}
//添加刷新加载更多
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [header beginRefreshing];
    
    self.tableView.mj_header = header;
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    
}
-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
//    NSInteger currentPa=(self.tableView.contentOffset.y+self.tableView.frame.size.height-70)/(100*10)+1;
//    if(currentPa==_currentPage)
//    {
//        _currentPage=currentPa;
//        return;
//    }
//    else
//    {
//        _currentPage=currentPa;
//    }
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/charirecord/list"];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
           _currentPage=_currentPage+1; 
        }
        else
        {
           [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        }
        for (NSDictionary*dict in dataArr)
        {
            XXYPublicBenefitRecordModel*model=[[XXYPublicBenefitRecordModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        [self.tableView.mj_footer endRefreshing];
    }];
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/charirecord/list"];
    
    _currentPage=2;
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        
        if(array.count<1)
        {
            [self setUpNoMessageView];
            self.tableView.tableFooterView=nil;
        }
        else
        {
            [_imageView removeFromSuperview];
        }
        
        for (NSDictionary*dict in array)
        {
            XXYPublicBenefitRecordModel*model=[[XXYPublicBenefitRecordModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)setUpNoMessageView
{
    [_imageView removeFromSuperview];
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, MainScreenH/2-64-(MainScreenW-100)/2, MainScreenW-100, MainScreenW-100)];
    _imageView.image=[UIImage imageNamed:@"msg_bg"];
    [self.tableView addSubview:_imageView];
}

-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=[UIColor whiteColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYPublicBenefitRecordCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
    
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(0, -MainScreenH, MainScreenW, MainScreenH)];
    bgView.backgroundColor = XXYBgColor;
    [self.tableView addSubview:bgView];
    
    UIView*headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    headerView.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.tableView.tableHeaderView=headerView;
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 40, MainScreenW, 10)];
    view.backgroundColor=[UIColor whiteColor];
    [headerView addSubview:view];
    _totalCaloriesLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, MainScreenW-40, 40)];
    _totalCaloriesLabel.font=[UIFont systemFontOfSize:12];
    NSString*textStr=@"您已经累计捐出00块钱";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textStr];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,7)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(textStr.length-3,2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:247.0/255 green:142.0/255 blue:50.0/255 alpha:1.0] range:NSMakeRange(7,textStr.length-9 )];
    
    _totalCaloriesLabel.attributedText = string;
    
    [headerView addSubview:_totalCaloriesLabel];
    
    UIView*footerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 20)];
    footerView.backgroundColor=[UIColor whiteColor];
    self.tableView.tableFooterView=footerView;
    
    UIImageView*footerImageView=[[UIImageView alloc]initWithFrame:CGRectMake(20, 0, 10, 10)];
    footerImageView.image=[UIImage imageNamed:@"calorie_timershaft2"];
    [footerView addSubview:footerImageView];

    [self loadTotalCalories];
}
-(void)loadTotalCalories
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/charirecord/findTotalCharitableCalorie"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        
        NSString*dataStr=[NSString stringWithFormat:@"您本月已经累计捐出%.1f大卡",([objString[@"data"] floatValue])/1000 ];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dataStr];
        
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,9)];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(dataStr.length-3,2)];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:247.0/255 green:142.0/255 blue:50.0/255 alpha:1.0] range:NSMakeRange(9,dataStr.length-11)];

        _totalCaloriesLabel.attributedText = string;
    } failure:^(NSError *error) {}];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,MainScreenW, MainScreenH-64) style:UITableViewStylePlain];
        
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
    }
    return _dataList;
}
#pragma mark -tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYPublicBenefitRecordCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dataModel=self.dataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor=[UIColor whiteColor];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYPublicBenefitRecordModel*model=self.dataList[indexPath.row];
    XXYAbandonCaloriesDetailController*detailCon=[[XXYAbandonCaloriesDetailController alloc]init];
    detailCon.myCalories=model.calorieVal;
    detailCon.comName=model.comName;
    detailCon.money=model.countFor;
    [self.navigationController pushViewControllerWithAnimation:detailCon];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

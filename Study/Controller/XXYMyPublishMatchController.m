#import "XXYMyPublishMatchController.h"
#import "XXYMatchListCell.h"
#import "XXYMatchListModel.h"
#import "MJRefresh.h"
#import "BSHttpRequest.h"
#import "XXYMatchDetailController.h"
#import "XXYBackButton.h"
@interface XXYMyPublishMatchController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _currentPage;
}
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIImageView*imageView;

@end

@implementation XXYMyPublishMatchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"我的约战";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    _currentPage=1;
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
    
//    NSInteger currentPa=(self.tableView.contentOffset.y+self.tableView.frame.size.height)/(70*10)+1;
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
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/listMatch4Me"];
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
        for (NSDictionary*dict in dataArr )
        {
            XXYMatchListModel*model=[[XXYMatchListModel alloc]initWithDictionary:dict error:nil];
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
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/listMatch4Me"];
    _currentPage=2;
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
         //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        if(array.count<1)
        {
            [self setUpNoMessageView];
        }
        else
        {
            [_imageView removeFromSuperview];
        }

        for (NSDictionary*dict in array)
        {
            XXYMatchListModel*model=[[XXYMatchListModel alloc]initWithDictionary:dict error:nil];
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
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 5)];
    view.backgroundColor=[UIColor clearColor];
    self.tableView.tableHeaderView=view;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYMatchListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
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
    return  self.dataList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMatchListCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dataModel=self.dataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMatchListModel*model=self.dataList[indexPath.row];
    XXYMatchDetailController*detailCon=[[XXYMatchDetailController alloc]init];
    detailCon.getId=[NSString stringWithFormat:@"%@",model.uid];
    detailCon.index=1;
    [self.navigationController pushViewController:detailCon animated:YES];
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
}
@end

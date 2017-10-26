#import "XXYClassAnnouncementsController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"

#import "XXYClassAnnouncementModel.h"
#import "XXYClassAnnouncementCell.h"
#import "MJRefresh.h"

#import "XXYClassAnnouncementDetailController.h"
@interface XXYClassAnnouncementsController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _currentPage;
}
@property(nonatomic,retain)NSMutableArray*dataList;

@property(nonatomic,retain)NSMutableArray*dataCacheArray;


@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIView*nothingView;

@end

@implementation XXYClassAnnouncementsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    self.navigationItem.title=@"公告列表";
    
    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

    _currentPage=2;
    
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
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/announcement/list"];
    
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
             _currentPage++;
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"annourcementDataCache" WithPath:@"annourcementData.plist"];
        }
        else
        {
          [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        }
        for (NSDictionary*dict in dataArr)
        {
            XXYClassAnnouncementModel*model=[[XXYClassAnnouncementModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self.tableView.mj_footer endRefreshing];
//        [SVProgressHUD showSuccessWithStatus:@"没有更多内容了"];
        [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
    }];

}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/announcement/list"];
    
    _currentPage=2;

    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
 
            [self.tableView.mj_header endRefreshing];
            //先清空数据源
            [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSArray*array=objString[@"data"];
        
        if(array.count<=0)
        {
            [self setUpNoHomeworkOfSubViews];
        }
        else
        {
            [_nothingView removeFromSuperview];
        }

          self.dataCacheArray=[NSMutableArray arrayWithArray:array];
        
            for (NSDictionary*dict in array)
            {
                XXYClassAnnouncementModel*model=[[XXYClassAnnouncementModel alloc]initWithDictionary:dict error:nil];
                [self.dataList addObject:model];
            }
        
        [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"annourcementDataCache" WithPath:@"annourcementData.plist"];
        
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
            [self.dataList removeAllObjects];
            NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"annourcementDataCache" WithPath:@"annourcementData.plist"];
            for (NSDictionary*dict in array)
            {
                XXYClassAnnouncementModel*model=[[XXYClassAnnouncementModel alloc]initWithDictionary:dict error:nil];
                [self.dataList addObject:model];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }];
    
}
-(void)setUpNoHomeworkOfSubViews
{
    [_nothingView removeFromSuperview];
    CGFloat height=self.tableView.frame.size.height;
    CGFloat width=self.tableView.frame.size.width;
    
    _nothingView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [self.tableView addSubview:_nothingView];
    CGFloat hight=(height-width/2)/3;
    //320*260
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(width/4, hight, width/2,width/2*5/7)];
    imageView.image=[UIImage imageNamed:@"no_network"];
    [_nothingView addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, hight+width/2*5/7, width-100,50)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:16];
    label.text=@"暂无公告内容";
    [_nothingView addSubview:label];
}


-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    //    self.tableView.bounces=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYClassAnnouncementCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(5,0,MainScreenW-10, MainScreenH-64) style:UITableViewStylePlain];
        
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
-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
}
#pragma mark -tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XXYClassAnnouncementCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    
    cell.dataModel=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layer.cornerRadius = 5;
    
//    cell.contentView.layer.cornerRadius = 10.0f;
//    cell.contentView.layer.borderWidth = 0.5f;
//    cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
//    cell.contentView.layer.masksToBounds = YES;
//    
//    cell.layer.shadowColor = [UIColor darkGrayColor].CGColor;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    cell.layer.shadowRadius = 4.0f;
//    cell.layer.shadowOpacity = 0.5f;
//    cell.layer.masksToBounds = NO;
//    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYClassAnnouncementModel*model=self.dataList[indexPath.section];
    //文字
    CGFloat textMaxW = [UIScreen mainScreen].bounds.size.width - 2 * 10;
    CGSize textMaxSize = CGSizeMake(textMaxW, MAXFLOAT);
    CGSize textSize = [model.content boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size;
   CGFloat cellHeight = textSize.height + 45;

    return cellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-20, 10)];
    view.backgroundColor=XXYBgColor;
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYClassAnnouncementDetailController*detailCon=[[XXYClassAnnouncementDetailController alloc]init];
    XXYClassAnnouncementModel*model=self.dataList[indexPath.section];
    detailCon.announcementModel=model;
    [self.navigationController pushViewControllerWithAnimation:detailCon];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
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
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

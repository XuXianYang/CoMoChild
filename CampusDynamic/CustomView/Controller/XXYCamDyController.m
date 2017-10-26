#import "XXYCamDyController.h"
#import "XXYCampusDynamicCell.h"
#import "XXYCampusDynamicFrame.h"
#import "XXYCampusDynamicModel.h"
#import "BSHttpRequest.h"
#import <MJRefresh/MJRefresh.h>
#import "XXYPublishDynamicController.h"
#import <UIImageView+WebCache.h>
#import "XXYCamDyDetailController.h"
#import <AFNetworking.h>

#import "YYFPSLabel.h"
#import <MJExtension/MJExtension.h>

static BOOL SDImageCacheOldShouldDecompressImages = YES;
static BOOL SDImagedownloderOldShouldDecompressImages = YES;

@interface XXYCamDyController ()<UITableViewDelegate,UITableViewDataSource,XXYReloadNewDataDelegate,XXYPushDetailDelegate,XXYReloadDataDelegate>
{
    NSInteger _currentPage;
}
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,retain)NSMutableArray*dataCacheArray;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIView*nothingView;

@property (nonatomic, strong) YYFPSLabel *fpsLabel;


@end

@implementation XXYCamDyController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentPage=2;
    [self setUpSubViews];
    [self setUpTableView];
    [self addRefreshLoadMore];
    
    _fpsLabel = [YYFPSLabel new];
    [_fpsLabel sizeToFit];
    _fpsLabel.frame=CGRectMake(10, self.view.bounds.size.height-180, 50, 50);
    _fpsLabel.alpha = 0;
    [self.view addSubview:_fpsLabel];
}
-(void)loadView
{
    [super loadView];
    SDImageCache *canche = [SDImageCache sharedImageCache];
    SDImageCacheOldShouldDecompressImages = canche.shouldDecompressImages;
    canche.shouldDecompressImages = NO;
    
    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    SDImagedownloderOldShouldDecompressImages = downloder.shouldDecompressImages;
    downloder.shouldDecompressImages = NO;
}
//添加刷新加载更多
- (void)addRefreshLoadMore
{
    
//    NSMutableArray *headerImages = [NSMutableArray array];
//    for (int i = 1; i <= 20; i++) {
//        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"hasNoContent%d",i]];
//        [headerImages addObject:image];
//    }
//    MJRefreshGifHeader *gifHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
//        //下拉刷新要做的操作.
//        [self loadNewData];
//    }];
//    gifHeader.stateLabel.hidden = YES;
//    gifHeader.lastUpdatedTimeLabel.hidden = YES;
    
//    [gifHeader setImages:headerImages forState:MJRefreshStateIdle];
//    //[gifHeader setImages:headerImages forState:MJRefreshStateRefreshing];
//    
//    [gifHeader setImages:headerImages duration:3 forState:MJRefreshStateRefreshing];
//    _tableView.mj_header = gifHeader;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    self.tableView.mj_footer.automaticallyHidden = YES;
    
}
-(void)turnNextPageFromToolsView:(XXYCampusDynamicFrame *)campusFrame
{
    XXYCamDyDetailController *commentVc = [[XXYCamDyDetailController alloc] init];
    commentVc.hidesBottomBarWhenPushed=YES;
    commentVc.reloadDelegate=self;
    commentVc.campusDynamicFrame = campusFrame;
    [self.navigationController pushViewControllerWithAnimation:commentVc];

}
-(void)deleteMyDynamicAndreload:(NSString*)dynamicId
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/deletePgAct"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sid"] = userSidString;
    parameters[@"actId"] = [NSNumber numberWithInt:[dynamicId intValue]];
    [manager POST:requestUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self loadNewData];
        }
        else
        {
            SVProgressHUD.minimumDismissTimeInterval=1.0  ;
            SVProgressHUD.maximumDismissTimeInterval=1.5  ;
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}
-(void)reloadNewDataOfPublished
{
    [self loadNewData];
}
-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/listPgAct"];
    
    if(self.getUrl)
    {
        requestUrl=self.getUrl;
    }
    NSString*cacheKeyString=[requestUrl substringWithRange:NSMakeRange(requestUrl.length-10, 10)];

    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@20} success:^(id responseObject){
        
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
            _currentPage++;
            
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:cacheKeyString WithPath:[NSString stringWithFormat:@"%@.plist",cacheKeyString]];
        }
        else
        {
            [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        }
        
        NSMutableArray *statusFrameArray = [NSMutableArray array];
        for (NSDictionary*dict in dataArr)
        {
            XXYCampusDynamicModel*model=[[XXYCampusDynamicModel alloc]init];
            
            model.dynamicId = dict[@"id"];
            model.userId = dict[@"userId"];
            model.name = dict[@"userDto"][@"username"];
            model.profile_image= dict[@"userDto"][@"avatarUrl"];
            model.text = dict[@"content"];;
            model.ding =((NSString*) dict[@"zanCount"]).integerValue;
            model.comment = ((NSString*)dict[@"discussCount"]).integerValue;
            model.created_at = [NSString stringWithFormat:@"%@:00",dict[@"strCreateAt"]];
            model.isZan4Me=((NSString*) dict[@"isZan4Me"]).boolValue;
            model.vedioUrl = dict[@"vedioUrl"];
            NSArray*imageArray=dict[@"imgs"];
            
            model.picCount = [NSNumber numberWithInteger:imageArray.count].integerValue;
            model.imageArray=imageArray;
            
            XXYCampusDynamicFrame*frame=[[XXYCampusDynamicFrame alloc]init];
            
            frame.dataModel=model;
            
            [statusFrameArray addObject:frame];
        }
        [self.dataList addObjectsFromArray:statusFrameArray];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        //[SVProgressHUD showSuccessWithStatus:@"没有更多内容了"];
        [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
    }];
}
-(void)clickedOfBeginRefresh{}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/listPgAct"];
    if(self.getUrl)
    {
        requestUrl=self.getUrl;
    }
    NSString*cacheKeyString=[requestUrl substringWithRange:NSMakeRange(requestUrl.length-10, 10)];
    _currentPage=2;
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageSize":@20} success:^(id responseObject){
//        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        NSMutableArray *statusFrameArray = [NSMutableArray array];
        for (NSDictionary*dict in dataArr)
        {
            XXYCampusDynamicModel*model=[[XXYCampusDynamicModel alloc]init];
            model.dynamicId = dict[@"id"];
            model.userId = dict[@"userId"];
            model.name = dict[@"userDto"][@"username"];
            model.profile_image= dict[@"userDto"][@"avatarUrl"];
            model.text = dict[@"content"];;
            model.ding =((NSString*) dict[@"zanCount"]).integerValue;
            model.comment = ((NSString*)dict[@"discussCount"]).integerValue;
            model.created_at = [NSString stringWithFormat:@"%@:00",dict[@"strCreateAt"]];
            model.isZan4Me=((NSString*) dict[@"isZan4Me"]).boolValue;
            model.vedioUrl = dict[@"vedioUrl"];
            NSArray*imageArray=dict[@"imgs"];
            
            model.picCount = [NSNumber numberWithInteger:imageArray.count].integerValue;
            model.imageArray=imageArray;
            
            XXYCampusDynamicFrame*frame=[[XXYCampusDynamicFrame alloc]init];
            
            frame.dataModel=model;
            
            [statusFrameArray addObject:frame];
        }
        [self.dataList insertObjects:statusFrameArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statusFrameArray.count)]];
        [self.dataCacheArray insertObjects:dataArr atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statusFrameArray.count)]];
        [BSHttpRequest archiverObject:self.dataCacheArray ByKey:cacheKeyString WithPath:[NSString stringWithFormat:@"%@.plist",cacheKeyString]];

        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:cacheKeyString WithPath:[NSString stringWithFormat:@"%@.plist",cacheKeyString]];
        NSMutableArray *statusFrameArray = [NSMutableArray array];
        for (NSDictionary*dict in array)
        {
            
            XXYCampusDynamicModel*model=[[XXYCampusDynamicModel alloc]init];
            model.dynamicId = dict[@"id"];
            model.userId = dict[@"userId"];
            model.name = dict[@"userDto"][@"username"];
            model.profile_image= dict[@"userDto"][@"avatarUrl"];
            model.text = dict[@"content"];;
            model.ding =((NSString*) dict[@"zanCount"]).integerValue;
            model.comment = ((NSString*)dict[@"discussCount"]).integerValue;
            model.created_at = [NSString stringWithFormat:@"%@:00",dict[@"strCreateAt"]];
            model.isZan4Me=((NSString*) dict[@"isZan4Me"]).boolValue;
            model.vedioUrl = dict[@"vedioUrl"];
            NSArray*imageArray=dict[@"imgs"];
            
            model.picCount = [NSNumber numberWithInteger:imageArray.count].integerValue;
            model.imageArray=imageArray;
            
            XXYCampusDynamicFrame*frame=[[XXYCampusDynamicFrame alloc]init];
            
            frame.dataModel=model;
            
            [statusFrameArray addObject:frame];
        }
        [self.dataList insertObjects:statusFrameArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, statusFrameArray.count)]];
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    //self.tableView.showsVerticalScrollIndicator=NO;
    //注册Cell
    [self.tableView registerClass:[XXYCampusDynamicCell class] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        
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
    XXYCampusDynamicCell*cell= [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.pushDelegate=self;
    cell.campusFrame=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return ((XXYCampusDynamicFrame *)self.dataList[indexPath.section]).cellHeight;
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
    XXYCamDyDetailController *commentVc = [[XXYCamDyDetailController alloc] init];
    commentVc.hidesBottomBarWhenPushed=YES;
    commentVc.reloadDelegate=self;
    commentVc.campusDynamicFrame = self.dataList[indexPath.section];
    [self.navigationController pushViewControllerWithAnimation:commentVc];
}
-(void)sendToReloadData
{
    [self loadNewData];
}
-(void)setUpSubViews
{
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"校园动态";
    //发布
    UIButton*publishDynamicBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    publishDynamicBtn.frame=CGRectMake(0, 0, 30, 30);
    [publishDynamicBtn setImage:[UIImage imageNamed:@"school_ttb_pls"] forState:UIControlStateNormal];
    [publishDynamicBtn addTarget:self action:@selector(publishDynamicBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:publishDynamicBtn];
}
-(void)publishDynamicBtnCliked:(UIButton*)btn
{
    XXYPublishDynamicController*pubCon=[[XXYPublishDynamicController alloc]init];
    pubCon.reloadDelegate=self;
    [self presentViewController:pubCon animated:YES completion:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //清理缓存 放在这个个方法中调用频率过快
//    //[[SDImageCache sharedImageCache] clearMemory];
//    [self.tableView endUpdates];
//}
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    //清理缓存
//    // [[SDImageCache sharedImageCache] clearMemory];
//}
//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    [self.tableView beginUpdates];
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (_fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
        
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    
    SDImageCache *canche = [SDImageCache sharedImageCache];
    canche.shouldDecompressImages = SDImageCacheOldShouldDecompressImages;

    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    downloder.shouldDecompressImages = SDImagedownloderOldShouldDecompressImages;
    
    self.dataList=nil;
    [self.tableView reloadData];
    [self loadNewData];
}
@end

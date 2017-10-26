#import "XXYCourseWareListController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYCourseWareCell.h"
#import "XXYCourseWareListModel.h"
#import "MJRefresh.h"
#import "XMNetworking.h"

@interface XXYCourseWareListController ()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
{
    /*
     UIDocumentInteractionController是iOS 很早就出来的一个功能。但由于平时很少用到，压根就没有听说过它。而我们忽略的缺是一个功能强大的”文档阅读器”。
     UIDocumentInteractionController主要由两个功能，一个是文件预览，另一个就是调用iPhoneh里第三方相关的app打开文档（注意这里不是根据url scheme 进行识别，而是苹果的自动识别）
     */
    UIDocumentInteractionController *_documentController; //文档交互控制器
    NSInteger _currentPage;
}
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIView*nothingView;
@property(nonatomic,retain)NSMutableArray*dataCacheArray;
@end
@implementation XXYCourseWareListController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"课件列表";
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    
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
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/course/material/list"];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"courseId":self.courseId,@"type":self.courseType,@"beginDate":self.startDate,@"endDate":self.endDate,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
            _currentPage++;
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"courseWareDataCache" WithPath:@"courseWareData.plist"];
        }
        else
        {
            [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        }
        for (NSDictionary*dict in dataArr)
        {
            XXYCourseWareListModel*model=[[XXYCourseWareListModel alloc]initWithDictionary:dict error:nil];
            model.courseName=dict[@"course"][@"name"];
            model.teacherName=dict[@"teacher"][@"realName"];
            model.attachmentName=dict[@"attachment"][@"name"];
            model.attachmentUrl=dict[@"attachment"][@"url"];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
        //[SVProgressHUD showSuccessWithStatus:@"没有更多内容了"];
        [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
    }];
}
-(void)loadNewData
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/course/material/list"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    _currentPage=2;
    
    //NSLog(@"self.courseType=%@,,self.courseId=%@  %@  %@",self.courseType,self.courseId,self.startDate,self.endDate);
    
    if(self.courseType&&self.courseId&&self.startDate&&self.endDate)
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"courseId":self.courseId,@"type":self.courseType,@"beginDate":self.startDate,@"endDate":self.endDate} success:^(id responseObject){
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
            
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*array=objString[@"data"];
        
        for (NSDictionary*dict in array)
        {
            XXYCourseWareListModel*model=[[XXYCourseWareListModel alloc]initWithDictionary:dict error:nil];
            model.courseName=dict[@"course"][@"name"];
            model.teacherName=dict[@"teacher"][@"realName"];
            model.attachmentName=dict[@"attachment"][@"name"];
            model.attachmentUrl=dict[@"attachment"][@"url"];
            [self.dataList addObject:model];
        }
            
            self.dataCacheArray=[NSMutableArray arrayWithArray:array];
             [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"courseWareDataCache" WithPath:@"courseWareData.plist"];
    
            [self.tableView reloadData];
           if(self.dataList.count<=0)
           {
               [self setUpNoHomeworkOfSubViews];
           }
            else
            {
                for(UIView *view in [_nothingView subviews])
                {
                    [view removeFromSuperview];
                }
                [_nothingView removeFromSuperview];
            }
    } failure:^(NSError *error) {
        [self.dataList removeAllObjects];
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"courseWareDataCache" WithPath:@"courseWareData.plist"];
        for (NSDictionary*dict in array)
        {
            XXYCourseWareListModel*model=[[XXYCourseWareListModel alloc]initWithDictionary:dict error:nil];
            model.courseName=dict[@"course"][@"name"];
            model.teacherName=dict[@"teacher"][@"realName"];
            model.attachmentName=dict[@"attachment"][@"name"];
            model.attachmentUrl=dict[@"attachment"][@"url"];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    }];
    else
    {
        [self setUpNoHomeworkOfSubViews];
        [self.tableView.mj_header endRefreshing];
    }
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
    label.text=@"暂无课件内容";
    [_nothingView addSubview:label];
}

-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYCourseWareCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(15,0,MainScreenW-30, MainScreenH-64) style:UITableViewStylePlain];
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
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYCourseWareCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dataModel=self.dataList[indexPath.section];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 30)];
    view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYCourseWareListModel*model=self.dataList[indexPath.section];
    if(model.attachmentUrl)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:documentsDirectory];
        NSString *path;
        NSString*fileName=[self turnUrlStringToFileName:model.attachmentUrl];
        NSString*index=@"0";
        while ((path = [dirEnum nextObject]) != nil)
        {
            if([path isEqualToString:fileName])
            {
                NSString*baseurl = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
                [self openFileWithPathString:[NSString stringWithFormat:@"%@%@",baseurl,fileName]];
                index=@"1";
            }
        }
        if([index isEqualToString:@"0"])
        {
           // NSLog(@"00path:%@", path);
           [self demoDownloadRequest:model.attachmentUrl];
        }
    }
}
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    //注意：此处要求的控制器，必须是它的页面view，已经显示在window之上了
    return self;
}
//下载文件
- (void)demoDownloadRequest:(NSString*)urlString{
    dispatch_queue_t q_concurrent = dispatch_queue_create("my_concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_sync(q_concurrent, ^{
            
            [XMCenter sendRequest:^(XMRequest *request) {
                
                [SVProgressHUD showWithStatus:@"下载中..."];
                request.url = urlString;
                request.downloadSavePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
                request.requestType = kXMRequestDownload;
            } onProgress:^(NSProgress *progress)
             {
                 if (progress)
                 {
                     [SVProgressHUD showWithStatus:@"下载中..."];
                }
             } onSuccess:^(id responseObject) {
                 
                 [SVProgressHUD dismiss];
                 if(responseObject)
                 {
                     NSString*urlString=[self turnUrlStringToFileName:[NSString stringWithFormat:@"%@",responseObject]];
                     
                     NSString*baseurl = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
                     
                     [self openFileWithPathString:[NSString stringWithFormat:@"%@%@",baseurl,urlString]];
                 }
             } onFailure:^(NSError *error) {
                 [SVProgressHUD dismiss];
             }];
            
           
        });
}
-(NSString*)turnUrlStringToFileName:(NSString*)urlString
{
    NSString*turnString=@"";
    if(urlString)
    {
        NSArray*array=[[NSString stringWithFormat:@"%@",urlString] componentsSeparatedByString:@"/"];
        //NSString*baseurl = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
        if(array.count>1)
        {
            NSString*string=[NSString stringWithFormat:@"%@",array[array.count-1]];
            
            turnString=[string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return turnString;
}
-(void)openFileWithPathString:(NSString*)filePath
{
    if(filePath)
    {
        NSURL*url=[NSURL fileURLWithPath:filePath];
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
        [_documentController setDelegate:self];
        //当前APP打开  需实现协议方法才可以完成预览功能
        [_documentController presentPreviewAnimated:YES];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

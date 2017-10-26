#import "XXYPriasePeopleTableView.h"
#import"XXYPraisePeopleCell.h"
#import "XXYCommentModel.h"
#import "BSHttpRequest.h"
#import <MJRefresh/MJRefresh.h>
@interface XXYPriasePeopleTableView ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UIImageView*imageView;

@end

@implementation XXYPriasePeopleTableView

+ (XXYPriasePeopleTableView *)contentTableView
{
    XXYPriasePeopleTableView *contentTV = [[XXYPriasePeopleTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    contentTV.backgroundColor = [UIColor clearColor];
    contentTV.dataSource = contentTV;
    contentTV.separatorStyle=UITableViewCellSeparatorStyleNone;
    contentTV.delegate = contentTV;
    return contentTV;
}
//添加刷新加载更多
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [header beginRefreshing];
    
    self.mj_header = header;
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    
    
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    self.mj_footer.automaticallyHidden = YES;
    
}
-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/getPageZan"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"actId":self.actId,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        [self.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArray=objString[@"data"];
        
        if(dataArray.count>0)
        {
            _currentPage++;
        }
        CGFloat totalHight=0;
        
        for (XXYCommentModel*model  in self.dataList)
        {
            totalHight+=model.cellHeight;
        }
        for (NSDictionary*dict in dataArray)
        {
            XXYCommentModel*model=[[XXYCommentModel alloc]init];
            model.ID=dict[@"id"];
            model.actId=dict[@"actId"];
            model.srcId=dict[@"srcId"];
            model.username=dict[@"userDto"][@"username"];
            model.realName=dict[@"userDto"][@"realName"];
            model.avatarUrl=dict[@"userDto"][@"avatarUrl"];
            
            totalHight+=model.cellHeight;
            
            [self.dataList addObject:model];
        }
        if([self.sendDelegate respondsToSelector:@selector(sendPraisehight:)])
        {
            [self.sendDelegate sendPraisehight:totalHight];
        }
        [self reloadData];
    } failure:^(NSError *error) {
        [self.mj_footer endRefreshing];
    }];
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    _currentPage=2;
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/getPageZan"];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"actId":self.actId,@"pageNum":@1,@"pageSize":@10} success:^(id responseObject) {
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        [self.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArray=obj[@"data"];
        if(dataArray.count<1)
        {
            [self setUpNoMessageView];
        }
        else
        {
            [_imageView removeFromSuperview];
        }
        
        CGFloat totalHight=0;
        
        for (NSDictionary*dict in dataArray)
        {
            XXYCommentModel*model=[[XXYCommentModel alloc]init];
            
            model.ID=dict[@"id"];
            model.actId=dict[@"actId"];
            model.srcId=dict[@"srcId"];
            model.username=dict[@"userDto"][@"username"];
            model.realName=dict[@"userDto"][@"realName"];
            model.avatarUrl=dict[@"userDto"][@"avatarUrl"];
            
            totalHight+=model.cellHeight;
            
            [self.dataList addObject:model];
        }
        
        if(totalHight==0)
        {
            totalHight=150;
        }
        
        if(self.index)
        {
            if([self.sendDelegate respondsToSelector:@selector(sendPraisehight:)])
            {
                [self.sendDelegate sendPraisehight:totalHight];
            }
        }
        
        [self reloadData];
        
    } failure:^(NSError *error) {
        [self.mj_header endRefreshing];
        
    }];
    
}
-(void)setUpNoMessageView
{
    [_imageView removeFromSuperview];
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, 0, MainScreenW-100, MainScreenW-100)];
    _imageView.image=[UIImage imageNamed:@"dynamic_nonice"];
    [self addSubview:_imageView];
}

-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
    }
    return _dataList;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self registerNib:[UINib nibWithNibName:@"XXYPraisePeopleCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CellId"];
    
    XXYPraisePeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId" forIndexPath:indexPath];
    
    cell.dataModel=self.dataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 55;
    
}

@end

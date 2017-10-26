#import "XXYTimeShaftTableView.h"
#import "XXYTimeShaftCell.h"
#import "XXYTimeShartModel.h"
#import "MJRefresh.h"
#import "BSHttpRequest.h"
@interface XXYTimeShaftTableView ()<UITableViewDataSource, UITableViewDelegate>
@end

@implementation XXYTimeShaftTableView

+ (XXYTimeShaftTableView *)contentTableView
{
    XXYTimeShaftTableView *contentTV = [[XXYTimeShaftTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    contentTV.backgroundColor = [UIColor clearColor];
    contentTV.dataSource = contentTV;
    contentTV.separatorStyle=UITableViewCellSeparatorStyleNone;
    contentTV.delegate = contentTV;
    return contentTV;
}
//添加刷新加载更多
-(void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.mj_header = header;
}
-(void)loadNewData
{
    
    for (int i=0 ;i<10;i++)
    {
        XXYTimeShartModel*model=[[XXYTimeShartModel alloc]init];
        model.calorieTime=[NSString stringWithFormat:@"1月%i日 16:00:00",i];
        model.calorieTotalnNum=[NSString stringWithFormat:@"%i",(i+10)*5];
        [self.timeInfoDataList addObject:model];
    }
    [self reloadData];
    [self.mj_header endRefreshing];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString*userSidString=[defaults objectForKey:@"userSid"];
//    
//    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/course/schedule/list"];
//    
//    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject) {
//        
//        [self.mj_header endRefreshing];
//        
//        //先清空数据源
//       // [self.courseDataList removeAllObjects];
//        
//        
//        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        
//        
//        
//        
//        [self reloadData];
//        
//    } failure:^(NSError *error) {
//        [self.mj_header endRefreshing];
//        
//    }];
    
}

-(NSMutableArray*)timeInfoDataList
{
    if(!_timeInfoDataList)
    {
        _timeInfoDataList=[NSMutableArray array];
    }
    return _timeInfoDataList;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.timeInfoDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self registerNib:[UINib nibWithNibName:@"XXYTimeShaftCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"timeShaftCellId"];
      XXYTimeShaftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeShaftCellId" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    cell.dataModel=self.timeInfoDataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 32.5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 50;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 17.5;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 20)];
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(34, 0, 2, 17.5)];
    lineView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [view addSubview:lineView];
    view.backgroundColor=[UIColor clearColor];
    return view;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 20)];
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(34, 0, 2, 17.5)];
    lineView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [view addSubview:lineView];
    
    UIImageView *endView=[[UIImageView alloc]initWithFrame:CGRectMake(27.5, 17.5, 15, 15)];
    endView.image=[UIImage imageNamed:@"calorie_timershaft2"];
    [view addSubview:endView];
    view.backgroundColor=[UIColor clearColor];
    return view;
}
@end

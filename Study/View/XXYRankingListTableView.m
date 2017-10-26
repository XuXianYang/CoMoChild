#import "XXYRankingListTableView.h"
#import "MJRefresh.h"
#import "BSHttpRequest.h"
#import "XXYRankingListModel.h"
#import "XXYRankingListCell.h"

@interface XXYRankingListTableView ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation XXYRankingListTableView

+ (XXYRankingListTableView *)contentTableView
{
    XXYRankingListTableView *contentTV = [[XXYRankingListTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSDictionary*userInfoDict=[defaults objectForKey:@"userInfo"];
    //NSLog(@"info=%@",userInfoDict);
    NSString*myUserId=[NSString stringWithFormat:@"%@",userInfoDict[@"user"][@"id"]];
    
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findRanking"];
    
    
    if(userSidString&&myUserId)
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject) {
    
           // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            [self.mj_header endRefreshing];
            //先清空数据源
            [self.rankingListDataList removeAllObjects];
    
            id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSArray*dataArray=obj[@"data"];
            
            for (int i=0;i<dataArray.count;i++)
            {
                NSDictionary*dict=dataArray[i];
                
                if([myUserId  isEqualToString:[NSString stringWithFormat:@"%@",dict[@"userId"]]])
                {
                    self.rankingListOfNum=[NSString stringWithFormat:@"当前排名: %i",i+1];
                }
                
                if(i<=2)
                {
                    XXYRankingListModel*model=[[XXYRankingListModel alloc]init];
                    model.rankingListNum=[NSString stringWithFormat:@"%i",i+1];
                    model.rankingListName=dict[@"user"][@"username"];
                    model.rankingListOfCalories=[NSString stringWithFormat:@"%@",dict[@"totalCalorie"]];
                    model.rankingListIcon=dict[@"user"][@"avatarUrl"];
                    [self.rankingListDataList addObject:model];
                }
            }
            
            [self reloadData];
    
        } failure:^(NSError *error) {
            [self.mj_header endRefreshing];
    
        }];
    
}

-(NSMutableArray*)rankingListDataList
{
    if(!_rankingListDataList)
    {
        _rankingListDataList=[NSMutableArray array];
    }
    return _rankingListDataList;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.rankingListDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self registerNib:[UINib nibWithNibName:@"XXYRankingListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"rankingListCellId"];
    
    XXYRankingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rankingListCellId" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor clearColor];
    
    cell.dataModel=self.rankingListDataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(self.rankingListIndex)
    {
       return 50;
    }
    else
    {
       return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 50;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.rankingListIndex)
    {
        return 50;
    }
    else
    {
        return 0;
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.rankingListIndex)
    {
        UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-30, 50)];
        view.backgroundColor=[UIColor clearColor];
        
        UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(5, 49, MainScreenW-40, 1)];
        lineView.backgroundColor=[UIColor colorWithRed:216.0/255 green:216.0/255 blue:216.0/255 alpha:1.0];
        [view addSubview:lineView];
        
        if(self.rankingListOfNum==nil)
        {
            self.rankingListOfNum=[NSString stringWithFormat:@"当前排名:100名以外"];
        }
        NSArray*titleArr=@[@"本月排行榜",self.rankingListOfNum];
        for(int i=0;i<2;i++)
        {
            UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20+100*i, 10, 100+(MainScreenW-270)*i, 30)];
            titleLabel.text=titleArr[i];
            titleLabel.font=[UIFont systemFontOfSize:15];
            titleLabel.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
            if(i==1)
            {
                titleLabel.textAlignment=NSTextAlignmentRight;
            }
            [view addSubview:titleLabel];
        }
        return view;
    }
    else
    {
        return nil;
    }
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    if(self.rankingListIndex)
    {
        UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-30, 50)];
        view.backgroundColor=[UIColor clearColor];

        UIButton*moreBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame=CGRectMake(MainScreenW-150, 0, 100, 50);
        moreBtn.titleLabel.textAlignment=NSTextAlignmentRight;
        moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        moreBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        [moreBtn setTitle:@"查看更多>>" forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:moreBtn];
        return view;
    }
    else
    {
        return nil;
    }
}
-(void)moreBtnClicked:(UIButton*)btn
{
    if([self.checkMoreDelegate respondsToSelector:@selector(checkMoreClicked)])
    {
        [self.checkMoreDelegate checkMoreClicked];
    }

}
@end

#import "XXYMyPraiseTableView.h"
#import"XXYMyPraiseCell.h"
#import "XXYMyPraiseModel.h"
#import "BSHttpRequest.h"
#import <MJRefresh/MJRefresh.h>
#import <AVFoundation/AVFoundation.h>

@interface XXYMyPraiseTableView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign)NSInteger currentPage;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UIImageView*imageView;

@end
@implementation XXYMyPraiseTableView

+ (XXYMyPraiseTableView *)contentTableView
{
    XXYMyPraiseTableView *contentTV = [[XXYMyPraiseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    contentTV.backgroundColor = XXYBgColor;
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
    NSDictionary*userInfoDict=[defaults objectForKey:@"userInfo"];

    
    
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    
    
    [BSHttpRequest GET:self.getDataUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        
        [self.mj_footer endRefreshing];
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArray=objString[@"data"];
        if(dataArray.count>0)
        {
            _currentPage++;
        }
        else
        {
            [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        }
        for (NSDictionary*dict in dataArray)
        {
            XXYMyPraiseModel*model=[[XXYMyPraiseModel alloc]init];
            if([self.getDataUrl isEqualToString:kCommentMeUrl]  )
            {
                model.uIcon=dict[@"srcUser"][@"avatarUrl"];
                model.uName=dict[@"srcUser"][@"username"];
                model.uTime=[NSString stringWithFormat:@"%@:00",dict[@"discussStrCreate"]];
                model.uContent=dict[@"discussConent"];
                model.dynamicId=dict[@"id"];
                model.uVideoUrl=dict[@"vedioUrl"];
                if(dict[@"imgs"])
                {
                    model.uImage=dict[@"imgs"][0];
                    model.hasImg=1;
                    
                }
                else
                {
                    model.uImage=userInfoDict[@"user"][@"avatarUrl"];
                }
                model.uMyontent=dict[@"content"];
                model.uMyName=[NSString stringWithFormat:@"%c%@",'@',userInfoDict[@"user"][@"username"]];
            }
            else if([self.getDataUrl isEqualToString:kPraiseMeUrl])
            {
                model.uIcon=dict[@"srcUser"][@"avatarUrl"];
                model.uName=dict[@"srcUser"][@"username"];
                model.uTime=[NSString stringWithFormat:@"%@:00",dict[@"zanStrCreate"]];
                model.uContent=@"赞了我!";
                model.dynamicId=dict[@"id"];
                
                model.uVideoUrl=dict[@"vedioUrl"];
                if(dict[@"imgs"])
                {
                    model.uImage=dict[@"imgs"][0];
                    model.hasImg=1;
                    
                }
                else
                {
                    model.uImage=userInfoDict[@"user"][@"avatarUrl"];
                    
                }
                model.uMyontent=dict[@"content"];
                model.uMyName=[NSString stringWithFormat:@"%c%@",'@',userInfoDict[@"user"][@"username"]];
            }
            else if([self.getDataUrl isEqualToString:kMyCommentUrl])
            {
                
                model.uIcon=userInfoDict[@"user"][@"avatarUrl"];
                model.uName=userInfoDict[@"user"][@"username"];
                model.uTime=[NSString stringWithFormat:@"%@:00",dict[@"strCreateAt"]];
                model.uContent=dict[@"discussConent"];
                model.dynamicId=dict[@"id"];
                model.uVideoUrl=dict[@"vedioUrl"];
                if(dict[@"imgs"])
                {
                    model.uImage=dict[@"imgs"][0];
                    model.hasImg=1;
                    
                }
                else
                {
                    model.uImage=userInfoDict[@"user"][@"avatarUrl"];
                }
                model.uMyontent=dict[@"content"];
                model.uMyName=[NSString stringWithFormat:@"%c%@",'@',userInfoDict[@"user"][@"username"]];
            }

            [self.dataList addObject:model];
        }
                [self reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        [self.mj_footer endRefreshing];
    }];
}

-(void)setUpNoMessageView
{
    [_imageView removeFromSuperview];
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, MainScreenH/2-64-(MainScreenW-100)/2, MainScreenW-100, MainScreenW-100)];
    _imageView.image=[UIImage imageNamed:@"msg_bg"];
    [self addSubview:_imageView];
}

-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSDictionary*userInfoDict=[defaults objectForKey:@"userInfo"];
    _currentPage=2;
    
    [BSHttpRequest GET:self.getDataUrl parameters:@{@"sid":userSidString,@"pageNum":@1,@"pageSize":@10} success:^(id responseObject) {
        
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
        
     for (NSDictionary*dict in dataArray)
        {
            XXYMyPraiseModel*model=[[XXYMyPraiseModel alloc]init];
            
            if([self.getDataUrl isEqualToString:kCommentMeUrl])
            {
                model.uIcon=dict[@"srcUser"][@"avatarUrl"];
                model.uName=dict[@"srcUser"][@"username"];
                model.uTime=[NSString stringWithFormat:@"%@:00",dict[@"discussStrCreate"]];
                model.uContent=dict[@"discussConent"];
                model.dynamicId=dict[@"id"];
                model.uVideoUrl=dict[@"vedioUrl"];

                if(dict[@"imgs"])
                {
                    model.uImage=dict[@"imgs"][0];
                    model.hasImg=1;

                }
                else
                {
                    model.uImage=userInfoDict[@"user"][@"avatarUrl"];
                }
                model.uMyontent=dict[@"content"];
                model.uMyName=[NSString stringWithFormat:@"%c%@",'@',userInfoDict[@"user"][@"username"]];
            }
            else if([self.getDataUrl isEqualToString:kPraiseMeUrl])
            {
                model.uIcon=dict[@"srcUser"][@"avatarUrl"];
                model.uName=dict[@"srcUser"][@"username"];
                model.uTime=[NSString stringWithFormat:@"%@:00",dict[@"zanStrCreate"]];
                model.uContent=@"赞了我!";
                model.dynamicId=dict[@"id"];
                model.uVideoUrl=dict[@"vedioUrl"];

                if(dict[@"imgs"])
                {
                    model.uImage=dict[@"imgs"][0];
                    model.hasImg=1;

                }
                else
                {
                    model.uImage=userInfoDict[@"user"][@"avatarUrl"];
                }
                model.uMyontent=dict[@"content"];
                model.uMyName=[NSString stringWithFormat:@"%c%@",'@',userInfoDict[@"user"][@"username"]];
            }
            else if([self.getDataUrl isEqualToString:kMyCommentUrl])
            {
                
                model.uIcon=userInfoDict[@"user"][@"avatarUrl"];
                model.uName=userInfoDict[@"user"][@"username"];
                model.uTime=[NSString stringWithFormat:@"%@:00",dict[@"strCreateAt"]];
                model.uContent=dict[@"lastDiscussContent"];
                model.dynamicId=dict[@"id"];
                model.uVideoUrl=dict[@"vedioUrl"];

                if(dict[@"imgs"])
                {
                    model.uImage=dict[@"imgs"][0];
                    model.hasImg=1;

                }
                else
                {
                    model.uImage=userInfoDict[@"user"][@"avatarUrl"];
                }
                model.uMyontent=dict[@"content"];
                model.uMyName=[NSString stringWithFormat:@"%c%@",'@',userInfoDict[@"user"][@"username"]];
            }
        [self.dataList addObject:model];
        }
        [self reloadData];
    } failure:^(NSError *error) {
        [self.mj_header endRefreshing];
    }];
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
    return self.dataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self registerNib:[UINib nibWithNibName:@"XXYMyPraiseCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CellId"];
    
    XXYMyPraiseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor whiteColor];
    
    cell.dataModel=self.dataList[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMyPraiseModel*model=self.dataList[indexPath.section];
    if(model.cellHeight)
    {
        return model.cellHeight;
    }
    else
    {
        return 150;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XXYMyPraiseModel*model=self.dataList[indexPath.section];
    
    //NSLog(@"id==%@",model.dynamicId);
    if([self.turnDelegate respondsToSelector:@selector(turnNextPage:)])
    {
        [self.turnDelegate turnNextPage:model.dynamicId];
    }

}

@end

#import "XXYCaloriesUnitTableView.h"
@interface XXYCaloriesUnitTableView()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)NSMutableArray*dataList;

@end
@implementation XXYCaloriesUnitTableView

+ (XXYCaloriesUnitTableView *)contentTableView
{
    XXYCaloriesUnitTableView *contentTV = [[XXYCaloriesUnitTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    contentTV.backgroundColor = [UIColor clearColor];
    contentTV.dataSource = contentTV;
    contentTV.separatorStyle=UITableViewCellSeparatorStyleNone;
    contentTV.delegate = contentTV;
    return contentTV;
}

-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray arrayWithArray:@[@"热量单位卡路里,简称卡.",@"1大卡=1千卡=1000卡路里=1000卡",@"1千卡/1大卡=4.184千焦(KJ)",@"1千焦=1000焦耳",@"1卡=4.182焦耳"]];
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
    
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryNone;
    
    cell.textLabel.text=self.dataList[indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:13];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 40;
    
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-30, 50)];
    view.backgroundColor=[UIColor whiteColor];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(15, 39, MainScreenW-45, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:216.0/255 green:216.0/255 blue:216.0/255 alpha:0.5];
    [view addSubview:lineView];
    
    UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, 100, 30)];
    titleLabel.text=@"Tips";
    titleLabel.font=[UIFont systemFontOfSize:15];
    titleLabel.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [view addSubview:titleLabel];
    return view;
}

@end

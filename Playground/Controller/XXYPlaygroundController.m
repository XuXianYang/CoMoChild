   #import "XXYPlaygroundController.h"
#import "XXYGroupChatController.h"
#import "BSHttpRequest.h"
#import "XXYGroupChatListCell.h"
#import "UIView+XXYBageValue.h"
#import "UITabBar+XXYBageValue.h"
@interface XXYPlaygroundController ()<UITableViewDelegate,UITableViewDataSource,RCMessageContentView>
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@end
@implementation XXYPlaygroundController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title=@"班群";
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    
    [self setUpTableView];
    [self getData];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)name:RCKitDispatchMessageNotification
     object:nil];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)didReceiveMessageNotification:(NSNotification *)notification
{
    RCMessage*message=notification.object;
    NSInteger idOfIndex;
    for(NSInteger i=0;i<self.dataList.count;i++)
    {
        NSDictionary*model=self.dataList[i];
        if([model[@"imGroupId"] isEqualToString:message.targetId])
        {
            idOfIndex=i;
            NSIndexPath *index = [NSIndexPath indexPathForRow:idOfIndex inSection:0];
            XXYGroupChatListCell*cell=[self.tableView cellForRowAtIndexPath:index];
            [cell.titleLabel showViewBadgeOnItemIndex:idOfIndex                                  ];
            return;
        }
    }
}
-(void)getData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/im/user/group/list"];
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
             //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            [self.dataList removeAllObjects];
            NSArray*array=objString[@"data"];
            
            if(array.count==0)
            {
                [self setUpNoclassView];
            }
            for (NSDictionary*dict in array)
            {
                NSMutableDictionary*dictInfo=[NSMutableDictionary dictionary];
                dictInfo[@"id"]=dict[@"id"];
                dictInfo[@"name"]=dict[@"name"];
                dictInfo[@"type"]=dict[@"type"];
                dictInfo[@"imGroupId"]=dict[@"imGroupId"];
                [self.dataList addObject:dictInfo];
            }
            
            [BSHttpRequest archiverObject:self.dataList ByKey:@"chatGroupListCache" WithPath:@"chatGroupList.plist"];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [self.dataList removeAllObjects];
            self.dataList =[BSHttpRequest unarchiverObjectByKey:@"chatGroupListCache" WithPath:@"chatGroupList.plist"];
            [self.tableView reloadData];
        }];
    
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.bounces=NO;
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.editing=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYGroupChatListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"mycellId"];
}
-(void)setUpNoclassView
{
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, MainScreenH/2-64-(MainScreenW-100)/2, MainScreenW-100, MainScreenW-100)];
    imageView.image=[UIImage imageNamed:@"no_class_bg"];
    [self.view addSubview:imageView];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,MainScreenW, MainScreenH-49-64) style:UITableViewStylePlain];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYGroupChatListCell*cell=[tableView dequeueReusableCellWithIdentifier:@"mycellId" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary*model=self.dataList[indexPath.row];
    cell.titleLabel.text=model[@"name"];
  
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYGroupChatListCell*cell=[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.titleLabel hideViewBadgeOnItemIndex:indexPath.row];
    [self.navigationController.tabBarController.tabBar hideTabBarBadgeOnItemIndex:0];
    //新建一个聊天会话View Controller对象
    XXYGroupChatController *chat = [[XXYGroupChatController alloc]init];
    chat.hidesBottomBarWhenPushed=YES;
    //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
    chat.conversationType = ConversationType_GROUP;
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    NSDictionary*dict=self.dataList[indexPath.row];
    
    chat.targetId =[NSString stringWithFormat:@"%@",dict[@"imGroupId"]];
    //设置聊天会话界面要显示的标题
    chat.title = dict[@"name"];
    //显示聊天会话界面
    [self.navigationController pushViewController:chat animated:YES];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

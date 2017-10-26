#import"XXYBackButton.h"
#import "XXYMatchMessageController.h"
#import "XXYMatchMessageCell.h"
#import "XXYMyPublishDeailDynamicController.h"
#import "XXYMyPraiseController.h"
#import "XXYMyCommentController.h"
@interface XXYMatchMessageController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@end

@implementation XXYMatchMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.navigationItem.title=@"消息";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self setUpTableView];
}
-(void)setUpTableView
{
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor=[UIColor whiteColor];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.bounces=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYMatchMessageCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
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
        _dataList=[NSMutableArray arrayWithArray:@[@"我的发布",@"评论",@"赞"]];
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
    XXYMatchMessageCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.index=indexPath.row;
    cell.titleLabel.text=self.dataList[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            XXYMyPublishDeailDynamicController*con=[[XXYMyPublishDeailDynamicController alloc]init];
            con.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewControllerWithAnimation:con];
        }
            break;
        case 1:
        {
            XXYMyCommentController*con=[[XXYMyCommentController alloc]init];
            con.hidesBottomBarWhenPushed=YES;

            [self.navigationController pushViewControllerWithAnimation:con];
        }
            break;
        case 2:
        {
            XXYMyPraiseController*con=[[XXYMyPraiseController alloc]init];
            con.hidesBottomBarWhenPushed=YES;

            [self.navigationController pushViewControllerWithAnimation:con];
        }
            break;
        default:
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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

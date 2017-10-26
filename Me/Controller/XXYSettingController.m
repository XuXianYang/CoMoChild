#import "XXYSettingController.h"
#import"XXYBackButton.h"
#import "XXYSettingDetailController.h"

#import"XXYProfileSettingCell.h"

#import "BSHttpRequest.h"
#import <RongIMKit/RongIMKit.h>
#import "AppDelegate.h"
#import"XXYMatchMessageController.h"
#import"XXYJoinSchoolController.h"
@interface XXYSettingController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)NSArray*dataList;
@property(nonatomic,strong)UITableView*tableView;

@property(nonatomic,strong)UIButton*cancelBtn;


@end

@implementation XXYSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"设置";

    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    
    [self.view addSubview:self.tableView];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.bounces=NO;
    self.tableView.scrollEnabled=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYProfileSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
    
    [self setUpCancelBtn];

}
-(void)setUpCancelBtn
{
    _cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame=CGRectMake(20,350,MainScreenW-40,50);
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cancelBtn.layer.cornerRadius=5;
    [_cancelBtn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
    [_cancelBtn setTitle:@"退出" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelBtn];
    
}
-(void)clickCancelBtn:(UIButton*)btn
{
    
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"退出当前账号" message:@"退出账号可能会使用户缓存数据全部清空,确定退出?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [action1 setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
    
    [alertCon addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"loginOut"];    }];
    [action2 setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alertCon addAction:action2];
    [self presentViewController:alertCon animated:YES completion:nil];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,MainScreenW, 300) style:UITableViewStylePlain];
        _tableView.backgroundColor=[UIColor clearColor];
    }
    return _tableView;
}
-(NSArray*)dataList
{
    if(!_dataList)
    {
        _dataList=@[@0,@1,@2,@3,@4,@5];
    }
    return _dataList;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYProfileSettingCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSNumber*num=self.dataList[indexPath.row];
    cell.index=[num integerValue];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYSettingDetailController*detailCon=[[XXYSettingDetailController alloc]init];
    detailCon.index=indexPath.row;
    switch (indexPath.row)
    {
        case 0:
        {
//            XXYJoinSchoolController*messCon=[[XXYJoinSchoolController alloc]init];
//            [self presentViewController:messCon animated:YES completion:nil];
            [self getUpNewUserInfoData];
        }
            break;
        case 1:
        {
            XXYMatchMessageController*messCon=[[XXYMatchMessageController alloc]init];
            [self.navigationController pushViewControllerWithAnimation:messCon];
        }
            break;
        case 2:
            detailCon.titleName=@"修改密码";
            [self.navigationController pushViewControllerWithAnimation:detailCon];
            break;
        case 3:
            detailCon.titleName=@"修改姓名";
            [self.navigationController pushViewControllerWithAnimation:detailCon];
            break;
        case 4:
            detailCon.titleName=@"修改昵称";
            [self.navigationController pushViewControllerWithAnimation:detailCon];
            break;

        case 5:
            detailCon.titleName=@"关于我们";
            [self.navigationController pushViewControllerWithAnimation:detailCon];
            break;
        default:
            break;
    }
}
-(void)getUpNewUserInfoData
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSDictionary*userInfoDict=[defaults objectForKey:@"joinClass"];
    
    if(userInfoDict[@"classId"]&&userInfoDict[@"schoolId"])
    {
        [self setUpAlertController:@"已经加入班级了~"];
    }
    else
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
            //        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSDictionary*dict=objString[@"data"][@"studentInfo"];
            NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
            [defaultss setObject:dict forKey:@"joinClass"];
            
            if(dict[@"classId"]&&dict[@"schoolId"])
            {
                [self setUpAlertController:@"已经加入班级了~"];
            }
            else
            {
                XXYJoinSchoolController*messCon=[[XXYJoinSchoolController alloc]init];
                [self presentViewController:messCon animated:YES completion:nil];
            }
        } failure:^(NSError *error) {}];
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
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
}
@end

#import "XXYAbandonCaloriesController.h"
#import "XXYBackButton.h"
#import "XXYPublishDynamicController.h"
#import "BSHttpRequest.h"
#import"XXYPublicBenefitRecordController.h"
#import "MJRefresh.h"
#import"XXYAbandonCaloriesDetailController.h"
#import "UIImageView+WebCache.h"
@interface XXYAbandonCaloriesController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,retain)NSMutableArray*organizationDataArray;
@property(nonatomic,retain)NSMutableArray*projectDataArray;
@property(nonatomic,strong)UIView*bgView;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,strong)UILabel* titleLabel;
@property(nonatomic,strong)UIImageView* iconImageView;

@property(nonatomic,strong)UILabel* caloriesLabel;

@property(nonatomic,retain)NSDictionary* comDict;
@property(nonatomic,retain)NSDictionary* itemIdDict;

@end

@implementation XXYAbandonCaloriesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"酷么公益";
    self.view.backgroundColor=[UIColor whiteColor];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpSubViews];
    
    [self loadUserIcon];
    
   }
-(void)loadUserIcon
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
    
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
          [_iconImageView sd_setImageWithURL:[NSURL URLWithString:objString[@"data"][@"avatarUrl"]] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    } failure:^(NSError *error) {}];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, MainScreenH, MainScreenW, 0) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)organizationDataArray
{
    if(!_organizationDataArray)
    {
        _organizationDataArray=[NSMutableArray array];
    }
    return _organizationDataArray;
}
-(NSMutableArray*)projectDataArray
{
    if(!_projectDataArray)
    {
        _projectDataArray=[NSMutableArray array];
    }
    return _projectDataArray;
}

-(void)setUpSubViews
{
    UIImageView*adImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenW*3/4)];
    adImageView.contentMode=UIViewContentModeScaleAspectFill;
    adImageView.clipsToBounds = YES;
    adImageView.image=[UIImage imageNamed:@"benefit_bg"];
    [self.view addSubview:adImageView];
    
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-50)/2, MainScreenW*3/4-25, 50, 50)];
    _iconImageView.layer.cornerRadius=25;
    _iconImageView.layer.masksToBounds=YES;
    _iconImageView.image=[UIImage imageNamed:@"head_bj"];
    [self.view addSubview:_iconImageView];
    
    UIButton*abandonCaloriesBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    abandonCaloriesBtn.frame=CGRectMake(60, MainScreenW*3/4+40, MainScreenW-120,35);
    abandonCaloriesBtn.layer.borderWidth=1;
    abandonCaloriesBtn.layer.borderColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0].CGColor;
    [abandonCaloriesBtn setTitleColor:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [abandonCaloriesBtn addTarget:self action:@selector(abandonCaloriesBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    abandonCaloriesBtn.layer.cornerRadius=17.5;
    [abandonCaloriesBtn setTitle:@"马上捐卡" forState:UIControlStateNormal];
    [self.view addSubview:abandonCaloriesBtn];
    
    
    NSString*dataStr=@"消耗 20000 卡路里可将卡路里捐出";
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dataStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:178.0/255 green:178.0/255 blue:178.0/255 alpha:1.0] range:NSMakeRange(0,2)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:178.0/255 green:178.0/255 blue:178.0/255 alpha:1.0] range:NSMakeRange(dataStr.length-11,11)];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:247.0/255 green:142.0/255 blue:50.0/255 alpha:1.0] range:NSMakeRange(2,dataStr.length-13)];
    
    CGSize size=[dataStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    
    
    for(int i=0;i<2;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]init];
        titleLabel.font=[UIFont systemFontOfSize:14];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        switch (i)
        {
            case 0:
            {
                titleLabel.frame=CGRectMake((MainScreenW-size.width)/2, MainScreenW*3/4+90, size.width, size.height);
                titleLabel.attributedText = string;

            }
                break;
            case 1:
            {
                titleLabel.textColor=[UIColor clearColor];
                titleLabel.frame=CGRectMake(60, MainScreenW*3/4+105+size.height*2, MainScreenW-120,0);
                _caloriesLabel=titleLabel;
            }
                break;
            default:
                break;
        }
        [self.view addSubview:titleLabel];
    }

    UIButton*moreRecordBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    moreRecordBtn.frame=CGRectMake(60, MainScreenW*3/4+105+size.height, MainScreenW-120,size.height);
    [moreRecordBtn addTarget:self action:@selector(moreRecordBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [moreRecordBtn setTitleColor:[UIColor colorWithRed:178.0/255 green:178.0/255 blue:178.0/255 alpha:1.0] forState:UIControlStateNormal];
    moreRecordBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [moreRecordBtn setTitle:@"我的公益记录>>" forState:UIControlStateNormal];
    [self.view addSubview:moreRecordBtn];
}
-(void)abandonCaloriesBtnCliked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findTodayTotalCal"];
    //NSLog(@"sid=%@",userSidString);
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSNumber*totalCalories=objString[@"data"];
        
        _caloriesLabel.text=[NSString stringWithFormat:@"%@",totalCalories];
        
        if([totalCalories floatValue]>=20000)
        {
            [self setUpPublicBenefitOrganizationView];
        }
        else
        {
            [self setUpAlertViewController:@"今天消耗的卡路里不够哦!,再接再厉吧~"];
        }
        
    } failure:^(NSError *error) {
        [self setUpAlertViewController:@"捐卡失败!,请稍后尝试!"];
    }];
}
-(void)setUpTableView
{
    [_bgView addSubview:self.tableView];
    self.tableView.delegate=self;
    self.tableView.layer.cornerRadius=5;
    self.tableView.dataSource=self;
    self.tableView.backgroundColor=[UIColor whiteColor];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    [self addRefreshLoadMore];
}

//添加刷新加载更多
-(void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
}
-(void)loadNewData
{
    switch (self.index) {
        case 1:
            [self loadPublicBenefitOrganizationData];
            break;
        case 2:
            [self loadPublicBenefitProjectData:_comDict[@"id"]];
            break;
            
        default:
            break;
    }
}
-(void)setUpPublicBenefitOrganizationView
{
    self.index=1;
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW,MainScreenH-64)];
    _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.view addSubview:_bgView];
    
    [self setUpTableView];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame=CGRectMake(0, _bgView.frame.size.height-330, MainScreenW, 330);
    }];
}
-(void)loadPublicBenefitOrganizationData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/charitable/charitablecom/list"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":@1,@"pageSize":@50} success:^(id responseObject){
        
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        [self.organizationDataArray removeAllObjects];
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
            NSArray*dataArray=objString[@"data"];
            for(int i=0;i<dataArray.count;i++)
            {
                NSDictionary*comInfo=dataArray[dataArray.count-i-1];
                [self.organizationDataArray addObject:comInfo];
            }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];

    }];
}
-(void)loadPublicBenefitProjectData:(NSString*)comId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@/%@",BaseUrl,@"/charitable/charitablepro/list",comId];
    //NSLog(@"sid=%@",userSidString);
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":@1,@"pageSize":@10} success:^(id responseObject){
        // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        [self.projectDataArray removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*dataArray=objString[@"data"];
        for(int i=0;i<dataArray.count;i++)
        {
            NSDictionary*proInfo=dataArray[i];
            [self.projectDataArray addObject:proInfo];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];

    }];
}
-(void)setUpPublicBenefitProjectView:(NSString*)comId
{
    self.index=2;
    [UIView animateWithDuration:0.5 animations:^{
        // 设置view弹出来的位置
        
        self.tableView.frame=CGRectMake(35, 65, MainScreenW-70, MainScreenH-64-65-80);
        _titleLabel.frame=CGRectMake(80, 0, self.tableView.frame.size.width-160, 50);
       
    }];
    _titleLabel.text=@"公益项目";
    [self loadPublicBenefitProjectData:comId];
}
-(void)setUpComfirmAbandonView
{
    self.index=0;
    self.tableView.bounces=NO;
    [self.projectDataArray removeAllObjects];
    [self.tableView reloadData];
    
    UIView*bgSubViews=[[UIView alloc]initWithFrame:CGRectMake(0, 50, self.tableView.frame.size.width, self.tableView.frame.size.height-50)];
    bgSubViews.backgroundColor=[UIColor clearColor];
    bgSubViews.tag=100;
    [self.tableView addSubview:bgSubViews];
    
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:36]};
    CGSize size=[_caloriesLabel.text sizeWithAttributes:attrs];
    UILabel*caloriesLabel=[[UILabel alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width-size.width)/2, 50, size.width, size.height)];
    caloriesLabel.font=[UIFont systemFontOfSize:36];
    caloriesLabel.textAlignment=NSTextAlignmentCenter;
    caloriesLabel.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    caloriesLabel.text=_caloriesLabel.text;
    [bgSubViews addSubview:caloriesLabel];
    
    CGSize nameLabelSize=[@"卡路里" sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    
    UILabel*nameLabel=[[UILabel alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width-size.width)/2+size.width, 45+size.height-nameLabelSize.height, size.width, nameLabelSize.height)];
    nameLabel.text=@"卡路里";
    nameLabel.textColor=[UIColor colorWithRed:79.0/255 green:79.0/255 blue:79.0/255 alpha:1.0];
    nameLabel.font=[UIFont systemFontOfSize:13];
    [bgSubViews addSubview:nameLabel];
    
    UILabel*comLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 100+size.height, self.tableView.frame.size.width-40, 50)];
    comLabel.numberOfLines=2;
    comLabel.text=[NSString stringWithFormat:@"%@将出资支持你的爱心",_comDict[@"name"]];
    comLabel.font=[UIFont systemFontOfSize:15];
    comLabel.textAlignment=NSTextAlignmentCenter;
    [bgSubViews addSubview:comLabel];
    
    UIButton*comfirmAbandonCaloriesBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    comfirmAbandonCaloriesBtn.frame=CGRectMake(50, 200+size.height, self.tableView.frame.size.width-100,35);
    comfirmAbandonCaloriesBtn.layer.borderWidth=1;
    comfirmAbandonCaloriesBtn.layer.borderColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0].CGColor;
    [comfirmAbandonCaloriesBtn setTitleColor:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [comfirmAbandonCaloriesBtn addTarget:self action:@selector(comfirmAbandonCaloriesBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    comfirmAbandonCaloriesBtn.layer.cornerRadius=17.5;
    [comfirmAbandonCaloriesBtn setTitle:@"确认捐出" forState:UIControlStateNormal];
    [bgSubViews addSubview:comfirmAbandonCaloriesBtn];

}
-(void)comfirmAbandonCaloriesBtnCliked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
   
    //NSLog(@"%@  %@  %@",_itemIdDict[@"costCalorie"],_itemIdDict[@"valueMoney"],_itemIdDict[@"id"]);
    if(_itemIdDict[@"costCalorie"]&&_itemIdDict[@"valueMoney"]&&_itemIdDict[@"id"])
    {
        
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/charirecord/add"];
        
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"calorieVal":[NSString stringWithFormat:@"%@",_itemIdDict[@"costCalorie"]],@"chariProId":[NSString stringWithFormat:@"%@",_itemIdDict[@"id"]],@"countFor":[NSString stringWithFormat:@"%@",_itemIdDict[@"valueMoney"]]} success:^(id responseObject){
            
            //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                XXYAbandonCaloriesDetailController*abandonDetailCon=[[XXYAbandonCaloriesDetailController alloc]init];
                abandonDetailCon.money=_itemIdDict[@"valueMoney"];
                abandonDetailCon.iconImage=_iconImageView.image;
                abandonDetailCon.comName=_comDict[@"name"];
                abandonDetailCon.myCalories=_itemIdDict[@"costCalorie"];
                [self.navigationController pushViewControllerWithAnimation:abandonDetailCon];
            }
        } failure:^(NSError *error) {
        }];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.index==1)
    {
       return self.organizationDataArray.count;
    }
    else
    {
        return self.projectDataArray.count;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType=UITableViewCellAccessoryNone;
    if(self.index==1)
    {
        NSDictionary*dict=self.organizationDataArray[indexPath.row];
        cell.textLabel.text=dict[@"name"];
        cell.detailTextLabel.text=nil;
    }
    else if(self.index==2)
    {
        NSDictionary*proDict=self.projectDataArray[indexPath.row];
        cell.textLabel.text=proDict[@"itemName"];
        cell.detailTextLabel.text=proDict[@"description"];
    }
    cell.textLabel.font=[UIFont systemFontOfSize:14];
    cell.detailTextLabel.font=[UIFont systemFontOfSize:11];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView*view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    UILabel*lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(5,49,self.tableView.frame.size.width-10, 1)];
    lineLabel.backgroundColor=[UIColor colorWithRed:178.0/255 green:178.0/255 blue:178.0/255 alpha:1.0];
    [view addSubview:lineLabel];
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(80, 0, self.tableView.frame.size.width-160, 50)];
    
    if(self.index==2)
    {
        _titleLabel.text=@"公益项目";
    }
   else if(self.index==1)
    {
        _titleLabel.text=@"公益机构";
    }
    else
    {
       _titleLabel.text=nil;
    }

    _titleLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.textColor=[UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    _titleLabel.font=[UIFont systemFontOfSize:16];
    [view addSubview:_titleLabel];
    
    UIButton*cancleBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    cancleBtn.frame=CGRectMake(15, 0, 60, 50);
    [cancleBtn setTitleColor:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(cancleBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [view addSubview:cancleBtn];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.index==1)
    {
        NSDictionary*dict=self.organizationDataArray[indexPath.row];
        [self setUpPublicBenefitProjectView:[NSString stringWithFormat:@"%@",dict[@"id"]]];
        _comDict=dict;
    }
    else if(self.index==2)
    {
         NSDictionary*dict=self.projectDataArray[indexPath.row];
        if([_caloriesLabel.text floatValue]<[dict[@"costCalorie"] floatValue])
        {
            [self setUpAlertViewController:@"你当前消耗的卡路里不够捐赠该项目,再接再厉哦~"];
        }
        else
        {
            _itemIdDict=dict;
            [self setUpComfirmAbandonView];
        }
    }
        
}
-(void)cancleBtnCliked:(UIButton*)btn
{
    self.index=1;
    [self.projectDataArray removeAllObjects];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        _tableView.frame=CGRectMake(0, MainScreenH, MainScreenW, 0);
    } completion:^(BOOL finished) {
        
        UIView*bgView=[self.view viewWithTag:100];
        for (UIView*view in [bgView subviews]) {
            [view removeFromSuperview];
        }
        [bgView removeFromSuperview];
        [_bgView removeFromSuperview];
    }];
}
-(void)viewDidDisappear:(BOOL)animated
{
    self.index=1;
    [self.projectDataArray removeAllObjects];
    UIView*bgView=[self.view viewWithTag:100];
    for (UIView*view in [bgView subviews]) {
        [view removeFromSuperview];
    }
    [bgView removeFromSuperview];
    [_bgView removeFromSuperview];
}
-(void)moreRecordBtnCliked:(UIButton*)btn
{
    XXYPublicBenefitRecordController*pubCon=[[XXYPublicBenefitRecordController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:pubCon];
}
-(void)setUpAlertViewController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [action setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
//    [alertCon addAction:action];
    [self presentViewController:alertCon animated:YES completion:nil];
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
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
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

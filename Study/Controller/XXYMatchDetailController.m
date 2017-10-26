#import "XXYMatchDetailController.h"
#import"XXYBackButton.h"
#import "XXYMatchDetailCell.h"
#import "BSHttpRequest.h"
#import"XXYMatchPeopleController.h"
#import "XXYPublishDynamicController.h"
@interface XXYMatchDetailController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,XXYReloadNewDataDelegate>

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIView*bgView;
@property(nonatomic,strong)UILabel*placeholderLabel;
@property(nonatomic,strong)UITextView*textView;
@property(nonatomic,strong)UIButton*acceptMatchBtn;
@property(nonatomic,strong)UIView*infoBgView;

@end

@implementation XXYMatchDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"约战详情";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    [self setUpSubViews];
    [self loadNewData];
    
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_textView resignFirstResponder];
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float height = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        // 设置view弹出来的位置
        
        _bgView.frame=CGRectMake(15, self.view.frame.size.height-height-70-MainScreenH*3/5, MainScreenW-30, MainScreenH*3/5);
        _textView.frame =CGRectMake(15, self.view.frame.size.height-height-40-15, MainScreenW-30, 40);
        _acceptMatchBtn.frame=CGRectMake(60, self.view.frame.size.height-height+15, MainScreenW-120,35);
    }];
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.5 animations:^{
        // 设置view弹出来的位置
        _bgView.frame=CGRectMake(15, 15, MainScreenW-30, MainScreenH*3/5);
        _textView.frame = CGRectMake(15, MainScreenH*3/5+30, MainScreenW-30, 40);
        _acceptMatchBtn.frame=CGRectMake(60, MainScreenH*3/5+90, MainScreenW-120,35);
    }];
}

-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@%@",BaseUrl,@"/student/match/listMatchDetail/",self.getId];
    if(self.getId)
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        [self.dataList removeAllObjects];
        
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        [self.dataList addObjectsFromArray:@[[NSString stringWithFormat:@"%@",objString[@"data"][@"strMTime"]],[NSString stringWithFormat:@"%@",objString[@"data"][@"mType"]],[NSString stringWithFormat:@"%@ / %@",objString[@"data"][@"joinNum"],objString[@"data"][@"numPeo"]],[NSString stringWithFormat:@"%@",objString[@"data"][@"address"]],[NSString stringWithFormat:@"%@",objString[@"data"][@"note"]]]];
        
        if([NSString stringWithFormat:@"%@",objString[@"data"][@"joinNum"]].integerValue >=[NSString stringWithFormat:@"%@",objString[@"data"][@"numPeo"]].integerValue&&self.index!=1)
        {
            [_acceptMatchBtn setTitleColor:[UIColor colorWithRed:182.0/255 green:182.0/255 blue:182.0/255 alpha:1.0] forState:UIControlStateNormal];
            _acceptMatchBtn.layer.borderColor=[UIColor clearColor].CGColor;
            _acceptMatchBtn.userInteractionEnabled=NO;
        }
        
        [self.tableView reloadData];
        [self loadNewTypeData:[NSString stringWithFormat:@"%@",objString[@"data"][@"mType"]]];
        
            } failure:^(NSError *error) {
    }];

}
-(void)loadNewTypeData:(NSString*)string
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/findAllOfSportsItem"];
    
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageSize":@50,@"pageNum":@1} success:^(id responseObject){
            
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray*dataArray=objString[@"data"];
            for (NSDictionary*dict in dataArray)
            {
                if([string isEqualToString:[NSString stringWithFormat:@"%@",dict[@"id"]]])
                {
                    [self.dataList replaceObjectAtIndex:1 withObject:dict[@"sName"]];
                    [self.tableView reloadData];
                    return ;
                }
            }
          } failure:^(NSError *error) {
        }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMatchDetailCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.index=indexPath.row;
    cell.detailLabel.text=self.dataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (MainScreenH*3/5-110-(MainScreenW-160)/2)/5;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString*indexStr=self.dataList[indexPath.row];
    
    switch (indexPath.row) {
        case 2:
        {
            XXYMatchPeopleController*matchPeopleCon=[[XXYMatchPeopleController alloc]init];
            matchPeopleCon.getId=self.getId;
            [self.navigationController pushViewControllerWithAnimation:matchPeopleCon];
        }
            break;
        case 3:
        {
            [self setUpViewOfDetailInfoData:indexStr andIndex:3];
        }
            break;

        case 4:
        {
            [self setUpViewOfDetailInfoData:indexStr andIndex:4];
        }
            break;

            
        default:
            break;
    }
}
-(void)setUpViewOfDetailInfoData:(NSString*)indexStr andIndex:(NSInteger)index
{
    _infoBgView=[[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_infoBgView];
    _infoBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapInfoBgView)];
    [_infoBgView addGestureRecognizer:tapGesturRecognizer];
    
    CGSize titleSize = [indexStr boundingRectWithSize:CGSizeMake(MainScreenW-60, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(30, 125+(MainScreenW-160)/2+(MainScreenH*3/5-110-(MainScreenW-160)/2)/5*index, MainScreenW-60, titleSize.height+20)];
    bgView.layer.cornerRadius=5;
    bgView.layer.masksToBounds=YES;
    bgView.backgroundColor=[UIColor whiteColor];
    [_infoBgView addSubview:bgView];
    
    UILabel*placeHoderLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 10, MainScreenW-90, titleSize.height)];
    placeHoderLabel.text=indexStr;
    placeHoderLabel.textColor=[UIColor blackColor];
    placeHoderLabel.font=[UIFont systemFontOfSize:14];
    placeHoderLabel.numberOfLines=0;
    [bgView addSubview:placeHoderLabel];
}
-(void)tapInfoBgView
{
    for (UIView*view in [_infoBgView subviews])
    {
        [view removeFromSuperview];
    };
    [_infoBgView removeFromSuperview];
}
-(void)setUpSubViews
{
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(15, 15, MainScreenW-30, MainScreenH*3/5)];
    _bgView.layer.cornerRadius=5;
    _bgView.backgroundColor=[UIColor whiteColor];
    
    _bgView.layer.borderColor=[UIColor clearColor].CGColor;
    _bgView.layer.shadowOffset = CGSizeMake(1,1);
    _bgView.layer.shadowOpacity = 0.1;
    _bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [self.view addSubview:_bgView];
    
    NSArray*picNameArr=@[@"match_red",@"match_blue"];
    for(int i=0;i<2;i++)
    {
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(15+i*(100+(MainScreenW-160)/2), 50, (MainScreenW-160)/2, (MainScreenW-160)/2)];
        imageView.image=[UIImage imageNamed:picNameArr[i]];
        
        [_bgView addSubview:imageView];
    }
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(15,100+(MainScreenW-160)/2-1,MainScreenW-60, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [_bgView addSubview:lineView];
    
    UILabel*vsLabel=[[UILabel alloc]initWithFrame:CGRectMake((MainScreenW-160)/2+15, 50, 100, (MainScreenW-160)/2)];
    vsLabel.text=@"v s";
    vsLabel.textAlignment=NSTextAlignmentCenter;
    vsLabel.textColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    vsLabel.font=[UIFont systemFontOfSize:30];
    [_bgView addSubview:vsLabel];
    
    [_bgView addSubview:self.tableView];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.bounces=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;

    [self.tableView registerNib:[UINib nibWithNibName:@"XXYMatchDetailCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
    
    if(self.index!=1)
    {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, MainScreenH*3/5+30, MainScreenW-30, 40)];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.layer.cornerRadius=5;
        _textView.font=[UIFont systemFontOfSize:12];
        _textView.delegate = self;
        _textView.textColor=[UIColor colorWithRed:182.0/255 green:182.0/255 blue:182.0/255 alpha:1.0];
        [self.view addSubview:_textView];
        
        // 提示字
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.frame =CGRectMake(15, 5, 200, 20);
        _placeholderLabel.text = @"输入应战者信息,50字以内";
        _placeholderLabel.textColor = [UIColor colorWithRed:182.0/255 green:182.0/255 blue:182.0/255 alpha:1.0];
        _placeholderLabel.font = [UIFont systemFontOfSize:12];
        _placeholderLabel.enabled = NO; // lable必须设置为不可用
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        [_textView addSubview:_placeholderLabel];
    }
    _acceptMatchBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _acceptMatchBtn.frame=CGRectMake(60, MainScreenH*3/5+90, MainScreenW-120,35);
    _acceptMatchBtn.layer.borderWidth=1;
    [_acceptMatchBtn setBackgroundColor:[UIColor whiteColor]];
    _acceptMatchBtn.layer.borderColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0].CGColor;
    [_acceptMatchBtn setTitleColor:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_acceptMatchBtn addTarget:self action:@selector(acceptMatchBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    _acceptMatchBtn.layer.cornerRadius=17.5;
    if(self.index==1)
    {
        [_acceptMatchBtn setTitle:@"精彩记录" forState:UIControlStateNormal];
    }
    else
    {
        [_acceptMatchBtn setTitle:@"应战" forState:UIControlStateNormal];
    }
    
    
    _acceptMatchBtn.layer.shadowOffset = CGSizeMake(1,1);
    _acceptMatchBtn.layer.shadowOpacity = 0.1;
    _acceptMatchBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [self.view addSubview:_acceptMatchBtn];
}
#pragma makr - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    _textView.text =  textView.text;
    if (textView.text.length > 50)
    {
        textView.text = [textView.text substringToIndex:50];
    }
    if (textView.text.length == 0) {
        _placeholderLabel.text = @"输入应战者信息,50字以内";
    } else {
        _placeholderLabel.text = @"";
    }
}
-(void)reloadNewDataOfPublished
{
    [self setUpAlertController:@"精彩分享成功"];
}
-(void)acceptMatchBtnCliked:(UIButton*)btn
{
    
    if(self.index==1)
    {
        XXYPublishDynamicController*publicCon=[[XXYPublishDynamicController alloc]init];
        publicCon.reloadDelegate=self;
        [self presentViewController:publicCon animated:YES completion:nil];
    }
    else
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString*userSidString=[defaults objectForKey:@"userSid"];
        
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/addMatchAccept"];
        
        _textView.text= [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if(_textView.text.length==0)
        {
            [self setUpAlertController:@"请输入应战信息!"];
        }
        else
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"matchId":self.getId,@"note":_textView.text} success:^(id responseObject){
            
            // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [self setUpAlertController:@"应战成功!"];
            }
            else if([objString[@"message"] hasPrefix:@"重复参加约战"]&&[codeString isEqualToString:@"11004"])
            {
                [self setUpAlertController:@"你已经应过战了,准备战斗吧!"];
            }
            else if([objString[@"message"] hasPrefix:@"约战人数已达到"]&&[codeString isEqualToString:@"11003"])
            {
                [self setUpAlertController:@"人数爆满了,试试其他约战吧!"];
            }
            else
            {
                [self setUpAlertController:@"应战失败!"];
            }
            
            
        } failure:^(NSError *error) {
            [self setUpAlertController:@"应战失败!"];
        }];
        
    }
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//    if([str isEqualToString:@"应战成功!"])
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    }];
//    [action setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
//    [alertCon addAction:action];
    [self presentViewController:alertCon animated:YES completion:nil];
    
    if([str isEqualToString:@"应战成功!"])
    {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
    }
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(otherCliecked:) userInfo:alertCon repeats:NO];
    }
}
-(void)otherCliecked:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
    }];
    alert = nil;
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
        if([self.reloadDelegate respondsToSelector:@selector(reloadMatchListOfPublished)])
        {
            [self.reloadDelegate reloadMatchListOfPublished];
        }
       [self.navigationController popViewControllerAnimated:YES];
    }];
    alert = nil;
}

-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,105+(MainScreenW-160)/2,MainScreenW-30, MainScreenH*3/5-110-(MainScreenW-160)/2) style:UITableViewStylePlain];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

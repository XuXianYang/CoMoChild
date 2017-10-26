#import "XXYBackButton.h"
#import "XXYSettingDetailController.h"
#import"BSHttpRequest.h"
#import"XXYWebViewController.h"
@interface XXYSettingDetailController ()<UITextFieldDelegate>
{
    UIAlertController *_alertCon;
}
@property(nonatomic,strong)UITextField*oldPasswordField;

@property(nonatomic,strong)UITextField*newsPasswordField;
@property(nonatomic,strong)UITextField*confirmpasswordTextField;

@property(nonatomic,strong)UIButton*confirmBtn;

@property(nonatomic,strong)UITextField*realNameField;
@property(nonatomic,strong)UITextField*studentNumField;
@property(nonatomic,strong)UITextField*nickNameField;

@property(nonatomic,strong)UIButton*saveBtn;
@end
@implementation XXYSettingDetailController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.titleName;
    self.view.backgroundColor=XXYBgColor;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    SVProgressHUD.minimumDismissTimeInterval=1.0  ;
    SVProgressHUD.maximumDismissTimeInterval=1.5  ;

    
    switch (self.index)
    {
        case 2:
            [self changePassword];
            [self setUpBtn];
            _confirmBtn.frame=CGRectMake(10, 45*5, MainScreenW-20, 45);
            break;
            
        case 3:
            [self personInfo];
            [self setUpBtn];
            break;
        case 4:
            [self setUpNickName];
            [self setUpBtn];
            _confirmBtn.frame=CGRectMake(10, 45*3, MainScreenW-20, 45);

            break;
        case 5:
            [self aboutUs];
            break;
        default:
            break;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [_oldPasswordField becomeFirstResponder];
    [_realNameField becomeFirstResponder];
    [_nickNameField becomeFirstResponder];

}
-(void)changePassword
{
    _oldPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(10,45, MainScreenW-20, 45)];
    _oldPasswordField.delegate=self;
    _oldPasswordField.placeholder=@"请输入旧的登录密码";
    UIView*oldView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _oldPasswordField.leftView=oldView;
    _oldPasswordField.leftViewMode=UITextFieldViewModeAlways;

    _oldPasswordField.backgroundColor=[UIColor whiteColor];
    _oldPasswordField.secureTextEntry=YES;
    _oldPasswordField.clearButtonMode =UITextFieldViewModeAlways;
    [_oldPasswordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_oldPasswordField];

    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, MainScreenW-20, 1)];
    lineView.backgroundColor=XXYBgColor;
    [_oldPasswordField addSubview:lineView];
    
    _newsPasswordField=[[UITextField alloc]initWithFrame:CGRectMake(10,90, MainScreenW-20, 45)];
    _newsPasswordField.delegate=self;
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _newsPasswordField.leftView=newView;
    _newsPasswordField.leftViewMode=UITextFieldViewModeAlways;

    _newsPasswordField.secureTextEntry=YES;
    _newsPasswordField.placeholder=@"请输入新的登录密码(最多16位)";
    _newsPasswordField.clearButtonMode =UITextFieldViewModeAlways;
    _newsPasswordField.backgroundColor=[UIColor whiteColor];
       [_newsPasswordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:_newsPasswordField];
    
    UIView*newlineView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, MainScreenW-20, 1)];
    newlineView.backgroundColor=XXYBgColor;
    [_newsPasswordField addSubview:newlineView];

    _confirmpasswordTextField=[[UITextField alloc]initWithFrame:CGRectMake(10,135, MainScreenW-20, 45)];
    _confirmpasswordTextField.delegate=self;
    UIView*conView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _confirmpasswordTextField.leftView=conView;
    _confirmpasswordTextField.leftViewMode=UITextFieldViewModeAlways;
    _confirmpasswordTextField.secureTextEntry=YES;
    _confirmpasswordTextField.placeholder=@"请再次确认新的登录密码";
    _confirmpasswordTextField.clearButtonMode =UITextFieldViewModeAlways;
    _confirmpasswordTextField.backgroundColor=[UIColor whiteColor];
    [_confirmpasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.view addSubview:_confirmpasswordTextField];
}
-(void)setUpBtn
{
    _confirmBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 180, MainScreenW-20, 45)];
    _confirmBtn.layer.cornerRadius=5;
    [_confirmBtn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
    
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
   [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    _confirmBtn.tag=self.index+120;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_newsPasswordField resignFirstResponder];
    [_oldPasswordField resignFirstResponder];
    [_realNameField resignFirstResponder];
    [_studentNumField resignFirstResponder];
    [_nickNameField resignFirstResponder];
    [_confirmpasswordTextField resignFirstResponder];
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.newsPasswordField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
        
    }
    if (textField == self.confirmpasswordTextField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
        
    }

    if (textField == self.oldPasswordField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
    }
    if (textField == self.realNameField)
    {
        if (textField.text.length >8)
        {
            textField.text = [textField.text substringToIndex:8];
        }
    }
    if (textField == self.studentNumField)
    {
        if (textField.text.length >20)
        {
            textField.text = [textField.text substringToIndex:20];
        }
    }
    if (textField == self.nickNameField)
    {
        if (textField.text.length >24)
        {
            textField.text = [textField.text substringToIndex:24];
        }
    }
}
-(void)confirmBtnCliked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*urlString;
    
    NSDictionary*parameters;
    
    if(btn.tag==122)
    {
        urlString=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/register/modifyPassword"];
        
        if(_oldPasswordField.text.length<6||_newsPasswordField.text.length<6||_confirmpasswordTextField.text.length<6)
        {
            [self setUpAlertController:@"密码最少为6位!"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else if ([XXYMyTools isEmpty:_oldPasswordField.text]||[XXYMyTools isEmpty:_newsPasswordField.text]||[XXYMyTools isEmpty:_confirmpasswordTextField.text])
        {
            [self setUpAlertController:@"密码不能含有空格等字符"];
            [self presentViewController:_alertCon animated:YES completion:nil];
            
        }
        else if (![_newsPasswordField.text isEqualToString:_confirmpasswordTextField.text])
        {
            [self setUpAlertController:@"密码不一致"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else
        {
            parameters=@{@"sid":userSidString,@"oldPassword":_oldPasswordField.text,@"newPassword":_newsPasswordField.text};
            
            [self postNewData:parameters AndUrl:urlString];
        }
    }
    if(btn.tag==123)
    {
        urlString=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info/update"];

        NSString*  realName=_realNameField.text;
        
        if(realName.length==0||[XXYMyTools isEmpty:_realNameField.text])
        {
            [self setUpAlertController:@"姓名不能为空或含有空格等字符"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else if ([XXYMyTools isChinese:_studentNumField.text]||[XXYMyTools isEmpty:_studentNumField.text])
        {
            [self setUpAlertController:@"学籍号不能含有空格,中文等字符"];
            [self presentViewController:_alertCon animated:YES completion:nil];

        }
        else
        {
            parameters=@{@"sid":userSidString,@"realName":realName,@"studentNo":_studentNumField.text};
            [self postNewData:parameters AndUrl:urlString];
        }
        
    }
    if(btn.tag==124)
    {
        urlString=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info/update"];
        
        if(_nickNameField.text.length<2||[XXYMyTools isEmpty:_nickNameField.text])
        {
            [self setUpAlertController:@"昵称为2~24个字符,不能包含空格等字符"];
             [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else
        {
            [self getUserRealName:urlString];
        }
    }
}

-(void)getUserRealName:(NSString*)url
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary*parameters;
        if(objString[@"data"][@"realName"])
        {
            parameters=@{@"sid":userSidString,@"realName":objString[@"data"][@"realName"],@"username":_nickNameField.text};
            [self postNewData:parameters AndUrl:url];
        }
        else
        {
            [self setUpAlertController:@"设置真实姓名之后才可以设置昵称"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
    } failure:^(NSError *error) {
    }];
}
-(void)postNewData:(NSDictionary*)par AndUrl:(NSString*)url
{
    [BSHttpRequest POST:url parameters:par success:^(id responseObject){
        
//         NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSString*codeStr=objString[@"code"];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self.navigationController popViewControllerAnimated:YES];
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        }
        else if (codeStr.integerValue==1001)
        {
            [self setUpAlertController:@"该用户名已被占用，请修改后重新提交"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else if (codeStr.integerValue==2001)
        {
            [self setUpAlertController:@"学籍号已经存在"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
        else if (codeStr.integerValue==1007)
        {
            [SVProgressHUD showSuccessWithStatus:@"旧密码不正确"];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"修改失败"];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"修改失败"];
           }];
}

-(void)setUpAlertController:(NSString*)str
{
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
 
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:_alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
        
    }];
    alert = nil;
}

-(void)personInfo
{
    _realNameField=[[UITextField alloc]initWithFrame:CGRectMake(10,45, MainScreenW-20, 45)];
    _realNameField.delegate=self;
    _realNameField.placeholder=@"请输入新的名字";
    _realNameField.backgroundColor=[UIColor whiteColor];
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _realNameField.leftView=newView;
    _realNameField.leftViewMode=UITextFieldViewModeAlways;

    _realNameField.clearButtonMode =UITextFieldViewModeAlways;
    [_realNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_realNameField];
    
    UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, MainScreenW-20, 1)];
    lineView.backgroundColor=XXYBgColor;
    [_realNameField addSubview:lineView];

    
    _studentNumField=[[UITextField alloc]initWithFrame:CGRectMake(10,90, MainScreenW-20, 45)];
    _studentNumField.delegate=self;
    UIView*oldView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _studentNumField.leftView=oldView;
    _studentNumField.leftViewMode=UITextFieldViewModeAlways;
    _studentNumField.placeholder=@"请输入学籍号";
    _studentNumField.clearButtonMode =UITextFieldViewModeAlways;
    _studentNumField.backgroundColor=[UIColor whiteColor];
    [_studentNumField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_studentNumField];

}
-(void)setUpNickName
{
    _nickNameField=[[UITextField alloc]initWithFrame:CGRectMake(10,45, MainScreenW-20, 45)];
    _nickNameField.delegate=self;
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _nickNameField.leftView=newView;
    _nickNameField.leftViewMode=UITextFieldViewModeAlways;
    _nickNameField.placeholder=@"请输入昵称";
    _nickNameField.backgroundColor=[UIColor whiteColor];
    _nickNameField.clearButtonMode =UITextFieldViewModeAlways;
    [_nickNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_nickNameField];
}
-(void)aboutUs
{
    UIDevice*device= [UIDevice currentDevice];
    
    CGFloat picHeight=0.0;
    if([device.model isEqualToString:@"iPad"])
    {
        picHeight=(MainScreenW-305)/2+120;
    }
    else
    {
        picHeight=MainScreenW-240+35;
    }

    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2, (picHeight+64-100)/2, 100, 100)];
    imageView.layer.masksToBounds=YES;
    imageView.layer.cornerRadius=10;
    imageView.image=[UIImage imageNamed:@"icon001"];
    [self.view addSubview:imageView];
    
    UILabel*nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, (picHeight+64-100)/2+110, MainScreenW-40, 30)];
    nameLabel.text=@"学生端V1.0.1";
    nameLabel.textColor=XXYMainColor;
    nameLabel.font=[UIFont systemFontOfSize:17];
    //nameLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:20];
    nameLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(0, picHeight+70, MainScreenW, 120)];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    for (int i=0;i<2;i++)
    {
        UIView*label=[[UIView alloc]initWithFrame:CGRectMake(0,40*(i+1), MainScreenW, 1)];
        label.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        [bgView addSubview:label];
        
    }
    UIView*LastBgView=[[UIView alloc]initWithFrame:CGRectMake(0, picHeight+210, MainScreenW, 80)];
    LastBgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:LastBgView];
    
    UIView*seplabel=[[UIView alloc]initWithFrame:CGRectMake(0,40, MainScreenW, 1)];
    seplabel.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    [LastBgView addSubview:seplabel];
    
    NSArray*secondTitleArray=@[@"检查更新",@"给我评分"];
    
    for(int i=0;i<2;i++)
    {
        UIButton*lastbtn=[UIButton buttonWithType:UIButtonTypeSystem];
        [lastbtn setBackgroundColor:[UIColor clearColor]];
        lastbtn.frame=CGRectMake(0, 40*i, MainScreenW, 40);
        lastbtn.tag=100+i;
        [lastbtn addTarget:self action:@selector(lastBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [LastBgView addSubview:lastbtn];
        
        UILabel*secondTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 5, 100, 30)];
        secondTitleLabel.text=secondTitleArray[i];
        secondTitleLabel.textColor=XXYMainColor;
        secondTitleLabel.font=[UIFont systemFontOfSize:16];
        [lastbtn addSubview:secondTitleLabel];
        
        UIImageView*secImageView=[[UIImageView alloc]initWithFrame:CGRectMake(MainScreenW-40, 10, 20, 20)];
        secImageView.image=[UIImage imageNamed:@"icon_img"];
        [lastbtn addSubview:secImageView];
    }
    NSArray*firstTitleArray=@[@"官方网站:",@"客服电话:",@"微信号:"];
    NSArray*firstBtnArray=@[@"http://comoclass.com",@"021-52992729",@"comoclass"];
    for (int i=0;i<3;i++)
    {
        UILabel*firstTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 5+40*i, 80, 30)];
        firstTitleLabel.text=firstTitleArray[i];
        firstTitleLabel.textColor=XXYMainColor;
        firstTitleLabel.font=[UIFont systemFontOfSize:16];
        [bgView addSubview:firstTitleLabel];
        
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        CGSize size=[firstBtnArray[i] sizeWithAttributes:attrs];
        
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame=CGRectMake(110, 5+40*i, size.width, 30);
        [btn setTitle:firstBtnArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.tag=i+1;
        btn.titleLabel.textAlignment=NSTextAlignmentCenter;
        btn.titleLabel.font=[UIFont systemFontOfSize:14];;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:btn];
        
//        UIImageView*firstImageView=[[UIImageView alloc]initWithFrame:CGRectMake(MainScreenW-40, 10+40*i, 20, 20)];
//        firstImageView.image=[UIImage imageNamed:@"icon_img"];
//        [bgView addSubview:firstImageView];
        
    }
    UILabel*timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,MainScreenH-64-30,MainScreenW, 20)];
    timeLabel.textAlignment=NSTextAlignmentCenter;
    timeLabel.textColor=[UIColor lightGrayColor];
    timeLabel.font=[UIFont systemFontOfSize:12];
    timeLabel.text=@"服务时间: 09:00~18:00";
    [self.view addSubview:timeLabel];
}
-(void)lastBtnCliked:(UIButton*)btn
{
    switch (btn.tag)
    {
        case 100:
        {
            [self setUpAlertController:@"当前版本已经是最新版本了"];
            [self presentViewController:_alertCon animated:YES completion:nil];
        }
            break;
        case 101:
        {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1156392147&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
        }
            break;
        default:
            break;
    }
}
-(void)btnClicked:(UIButton*)btn
{
    switch (btn.tag)
    {
        case 1:
        {
            XXYWebViewController*webCon=[[XXYWebViewController alloc]init];
            [self.navigationController pushViewController:webCon animated:YES];
        }
            break;
        case 2:
        {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",btn.currentTitle];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self.view addSubview:callWebview];
        }
            break;
        case 3:
        {
            [self setUpAlertController:@"请搜索酷么课堂,关注最新动态"];
            [self presentViewController:_alertCon animated:YES completion:nil];
            
        }
            break;
        default:
            break;
    }
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}@end

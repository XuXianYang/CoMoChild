#import "XXYLoginController.h"
#import "XXYRegisterController.h"
#import "XXYLostPasswordController.h"
#import "XXYTabBarController.h"
#import"BSHttpRequest.h"
#import "AppDelegate.h"
#import "XXYJoinSchoolController.h"
#import<RongIMKit/RongIMKit.h>
#import<AFNetworking.h>
@interface XXYLoginController ()<UITextFieldDelegate>
{
    UIAlertController *_alertCon;
}

@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UITextField*nameTextField;
@property(nonatomic,strong)UITextField*passwordTextField;
@property(nonatomic,strong)UIButton*loginBtn;
@property(nonatomic,strong)UIButton*lostPasswordBtn;
@property(nonatomic,strong)UIButton*fastRegisterBtn;

@property(nonatomic,strong)UIButton*remberNameAndPasswordBtn;


@property(nonatomic,strong)UIView*bgView;
@property(nonatomic,assign)CGFloat picHeight;
@property(nonatomic,strong)UITextField*otherTextField;

@end

@implementation XXYLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    [self setUpLoginView];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray*array= [defaults objectForKey:@"nameAndPasswordData"];
    if(array.count>=2)
    {
        _nameTextField.text=array[0];
        _passwordTextField.text=array[1];
    }
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
-(void)viewWillDisappear:(BOOL)animated
{
    [_nameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}
-(void)viewDidDisappear:(BOOL)animated
{
    if(self.index==1)
    {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.index==1)
    {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }

    [self setUpNavigationControllerBackButton];
    _bgView.frame=self.view.bounds;
}
-(void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    //设置导航栏为透明色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
}
-(void)setUpNavigationControllerBackButton
{
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backicon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(0, 0, 30, 30);
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.text=@"登录";
    UIBarButtonItem*btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem*labelItem=[[UIBarButtonItem alloc] initWithCustomView:label];

    self.navigationItem.leftBarButtonItems=@[btnItem,labelItem];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)setUpLoginView
{
    _bgView=[[UIView alloc]initWithFrame:self.view.bounds];
    _bgView.backgroundColor=XXYBgColor;
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked:)];
    [_bgView addGestureRecognizer:tap];
    [self.view addSubview:_bgView];

    UIDevice*device= [UIDevice currentDevice];
    
    if([device.model isEqualToString:@"iPad"])
    {
        _picHeight=MainScreenW/2+60;
    }
    else
    {
        _picHeight=MainScreenW-100;
        
    }

    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-100)/2, (_picHeight+64-100)/2, 100, 100)];
    _iconImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer*icontap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked:)];
    [_iconImageView addGestureRecognizer:icontap];
    _iconImageView.layer.masksToBounds=YES;
    _iconImageView.layer.cornerRadius=20;
    _iconImageView.image=[UIImage imageNamed:@"icon001"];
    [_bgView addSubview:_iconImageView];
    
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(10, _picHeight, MainScreenW-20, 90)];
    bgView.backgroundColor=[UIColor whiteColor];
    [_bgView addSubview:bgView];
    
    _remberNameAndPasswordBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _remberNameAndPasswordBtn.frame=CGRectMake(10, _picHeight+95, 200, 20);
    _remberNameAndPasswordBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [_remberNameAndPasswordBtn setImage:[UIImage imageNamed:@"noremberName"] forState:UIControlStateNormal];
    [_remberNameAndPasswordBtn setImage:[UIImage imageNamed:@"remberName"] forState:UIControlStateSelected];
    _remberNameAndPasswordBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);//上，左，下，右
    _remberNameAndPasswordBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _remberNameAndPasswordBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
    [_remberNameAndPasswordBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_remberNameAndPasswordBtn addTarget:self action:@selector(remberBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [_remberNameAndPasswordBtn setTitle:@"记住账号和密码" forState:UIControlStateNormal];
    [_bgView addSubview:_remberNameAndPasswordBtn];
    _remberNameAndPasswordBtn.selected=YES;

    
    UIView*lineBgView=[[UIView alloc]initWithFrame:CGRectMake(5, 44.5, MainScreenW-30, 1)];
    lineBgView.backgroundColor=XXYBgColor;
    [bgView addSubview:lineBgView];
    
    _nameTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 0, MainScreenW-30, 45)];
    _nameTextField.delegate=self;
    _nameTextField.placeholder=@"  请输入账号";
    _nameTextField.backgroundColor=[UIColor clearColor];
    _nameTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [bgView addSubview:_nameTextField];
    
    _passwordTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 45, MainScreenW-30, 45)];
    _passwordTextField.delegate=self;
    _passwordTextField.secureTextEntry=YES;
    _passwordTextField.placeholder=@"  请输入密码";
    _passwordTextField.backgroundColor=[UIColor clearColor];
    _passwordTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_passwordTextField];
    
    _loginBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, _picHeight+140, MainScreenW-20, 45)];
    _loginBtn.layer.cornerRadius=5;
    [_loginBtn setBackgroundColor:[UIColor orangeColor]];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(loginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_loginBtn];
    
    _fastRegisterBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _fastRegisterBtn.frame=CGRectMake(10, _picHeight+200, 100, 30);
    [_fastRegisterBtn setTitle:@"快速注册" forState:UIControlStateNormal];
    [_fastRegisterBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_fastRegisterBtn addTarget:self action:@selector(fastRegisterBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_fastRegisterBtn];
   
    _lostPasswordBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _lostPasswordBtn.frame=CGRectMake(MainScreenW-110, _picHeight+200, 100, 30);
    [_lostPasswordBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [_lostPasswordBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_lostPasswordBtn addTarget:self action:@selector(lostPasswordBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_lostPasswordBtn];

}
-(void)remberBtnCliked:(UIButton*)btn
{
    btn.selected=!btn.isSelected;
}
-(void)loginBtnClicked:(UIButton*)btn
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/login"];
    
    if([XXYMyTools isEmpty:_nameTextField.text]||[XXYMyTools isEmpty:_passwordTextField.text])
    {
        [self setUpAlertController:@"账号或者密码不能包含空格等特殊字符"];
    }
    else if(_nameTextField.text.length<2||_passwordTextField.text.length<6||_nameTextField.text.length>24)
    {
        [self setUpAlertController:@"账号或者密码错误,请重新输入!"];
    }
    else
    [BSHttpRequest POST:requestUrl parameters:@{@"username":_nameTextField.text,@"password":_passwordTextField.text} success:^(id responseObject){
       // NSLog(@"145-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if([objString[@"message"] isEqualToString:@"success"])
        {
            if([objString[@"data"][@"user"][@"type"] isEqualToNumber:@2])
            {
                
              NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
              NSString*aliasString=  [defaultss objectForKey:@"aliasString"];
                //缓存账号和密码
                if(_remberNameAndPasswordBtn.isSelected)
                {
                    NSArray*nameAndPasswordArr=@[_nameTextField.text,_passwordTextField.text];
                    [defaultss setObject:nameAndPasswordArr forKey:@"nameAndPasswordData"];
                }
                else
                {
                    [defaultss removeObjectForKey:@"nameAndPasswordData"];
                }
                if(aliasString.length<30)
                {
                    NSDate*date=[NSDate date];
                    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
                    [dateFormate setDateFormat:@"yyyyMMddHHmmssSSSS"];
                    NSString *dateStr = [dateFormate stringFromDate:date];
                    aliasString=[NSString stringWithFormat:@"cyruspublicios%@",dateStr];
                    
                    [JPUSHService setTags:nil  alias:aliasString fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {}];
                    [self upLoadOtherName:aliasString AndSID:objString[@"data"][@"sid"]];

                }
                NSString*string=objString[@"data"][@"sid"];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:string forKey:@"userSid"];
                [defaults setObject:objString[@"data"] forKey:@"userInfo"];
                
                if(objString[@"data"][@"user"][@"studentInfo"][@"schoolId"]&&objString[@"data"][@"user"][@"studentInfo"][@"schoolName"]&&objString[@"data"][@"user"][@"studentInfo"][@"classId"]&&objString[@"data"][@"user"][@"studentInfo"][@"className"])
                {
                    [self getUserToken:objString[@"data"][@"sid"]];
                    [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"login"];
                }
                else
                {
                    XXYJoinSchoolController*joinCon=[[XXYJoinSchoolController alloc]init];
                    joinCon.index=1;
                    [UIApplication sharedApplication].keyWindow.rootViewController=joinCon;
                }
            }
            else
            {
                [self setUpAlertController:@"该客户端只支持学生登录!"];
            }
        }
        else
        {
            [self setUpAlertController:@"账号或者密码错误,请重新输入!"];
        }
    } failure:^(NSError *error) {
       // NSLog(@"error-%@",error.localizedDescription);
        NSString*errorString;
        if([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."])
            errorString=@"您的网络异常,请检查网络!";
        else
            errorString=@"登录失败,请稍后重试!";
        [self setUpAlertController:errorString];
    }];
}
-(void)upLoadOtherName:(NSString*)otherName AndSID:(NSString*)sid
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@%@?sid=%@",BaseUrl,@"/user/info/updateAlias/",otherName,sid];
   requestUrl=[requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 获得网络管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer=[AFHTTPRequestSerializer serializer];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    [manager PUT:requestUrl parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //NSLog(@"other-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:otherName forKey:@"aliasString"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}
-(void)connectRongYun:(NSString*)userToken
{
    [[RCIM sharedRCIM] connectWithToken:userToken success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        //设置用户信息提供者,页面展现的用户头像及昵称都会从此代理取
        [self getImUserInfo:userId];
        
                    } error:^(RCConnectErrorCode status) {
            } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        // NSLog(@"token错误");
        }];
}
-(void)getUserToken:(NSString*)sid
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/im/user/token"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":sid} success:^(id responseObject){
        
//        NSLog(@"token-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString*tokenString=objString[@"data"];
         if(tokenString)
        {
            [self connectRongYun:tokenString];
        }
    } failure:^(NSError *error) {
    }];
}
-(void)getImUserInfo:(NSString*)userID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/im/user/info"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"imUserId":userID} success:^(id responseObject){
        
//        NSLog(@"Success:userinfo= %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary*imUserInfo=objString[@"data"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:imUserInfo forKey:@"ImUserInfo"];
        if(imUserInfo)
        {
            RCUserInfo *user = [[RCUserInfo alloc]init];
            user.userId =imUserInfo[@"imUserId"];
            NSLog(@"userId=%@",user.userId);
            user.name = imUserInfo[@"imUserName"];
            user.portraitUri = imUserInfo[@"avatarUrl"];
            
            [[RCIM sharedRCIM] setCurrentUserInfo:user];
            [[RCIM sharedRCIM] setEnableMessageAttachUserInfo:YES];
            [RCIM sharedRCIM].enablePersistentUserInfoCache=YES;
        }
    } failure:^(NSError *error) {}];
}
-(void)setUpAlertController:(NSString*)str
{
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alertCon animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:_alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
}

-(void)fastRegisterBtnClicked:(UIButton*)btn
{
    XXYRegisterController*registerCon=[[XXYRegisterController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:registerCon];
}
-(void)lostPasswordBtnClicked:(UIButton*)btn
{
    XXYLostPasswordController*lostCon=[[XXYLostPasswordController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:lostCon];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}
-(void)tapClicked:(UITapGestureRecognizer*)tap
{
    [_nameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _otherTextField=textField;
}
//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float height = keyboardRect.size.height;
    
    CGFloat marginHeight=MainScreenH-64-_otherTextField.frame.origin.y-_picHeight;
    if(marginHeight<height)
    {
        [UIView animateWithDuration:0.3 animations:^{
            // 设置view弹出来的位置
            _bgView.frame=CGRectMake(0,0-height+marginHeight-20, MainScreenW, self.view.bounds.size.height);
        }];
    }
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
}

-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    [UIView animateWithDuration:0.3 animations:^{
        // 设置view弹出来的位置
        _bgView.frame=self.view.bounds;
    }];
    
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.nameTextField)
    {
        if (textField.text.length > 24)
        {
            textField.text = [textField.text substringToIndex:24];
        }
        
    }
    if (textField == self.passwordTextField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

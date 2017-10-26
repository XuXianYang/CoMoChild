#import "XXYRegisterController.h"

#import "BSHttpRequest.h"
@interface XXYRegisterController ()<UITextFieldDelegate>

{
    UIAlertController *_alertCon;
}

@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UITextField*phoneTextField;
@property(nonatomic,strong)UITextField*verificationCodeTextField;
@property(nonatomic,strong)UITextField*passwordTextField;
@property(nonatomic,strong)UITextField*nickNameTextField;
@property(nonatomic,strong)UITextField*confirmpasswordTextField;

@property(nonatomic,strong)UIButton*registerBtn;

@property(nonatomic,strong)UIButton*getVerificationCodeBtn;

@property(nonatomic,strong)UIView*bgView;
@property(nonatomic,assign)CGFloat picHeight;
@property(nonatomic,strong)UITextField*otherTextField;



@end
@implementation XXYRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    
    [self setUpRegisterView];
    
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
-(void)viewDidAppear:(BOOL)animated
{
    [self setUpNavigationControllerBackButton];
}
-(void)viewWillAppear:(BOOL)animated
{
    //[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //设置导航栏为透明色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

-(void)setUpNavigationControllerBackButton
{
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backicon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(0, 0, 30, 30);
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    label.text=@"注册";
    UIBarButtonItem*btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem*labelItem=[[UIBarButtonItem alloc] initWithCustomView:label];
    
    self.navigationItem.leftBarButtonItems=@[btnItem,labelItem];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)setUpRegisterView
{
    
    _bgView=[[UIView alloc]initWithFrame:self.view.bounds];
    _bgView.backgroundColor=XXYBgColor;
    UITapGestureRecognizer*tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked:)];
    [_bgView addGestureRecognizer:tap];
    [self.view addSubview:_bgView];
    
    UIDevice*device= [UIDevice currentDevice];
    if([device.model isEqualToString:@"iPad"])
    {
        _picHeight=(MainScreenW-180)*2/5+27+150;
    }
    else
    {
        _picHeight=(MainScreenW-180)*4/5+110;
        
    }

    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-150)/2, (_picHeight+64-120)/2, 150, 120)];
    _iconImageView.userInteractionEnabled=YES;
    UITapGestureRecognizer*icontap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClicked:)];
    [_iconImageView addGestureRecognizer:icontap];
    _iconImageView.image=[UIImage imageNamed:@"registerbg"];
    [_bgView addSubview:_iconImageView];
    
       
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(10, _picHeight, MainScreenW-20, 200)];
    bgView.backgroundColor=[UIColor whiteColor];
    [_bgView addSubview: bgView];
    
    for(NSInteger i=0;i<4;i++)
    {
        UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(5, 40*(i+1), MainScreenW-30, 1)];
        lineView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
        [bgView addSubview:lineView];
    }
    
    _phoneTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 0, MainScreenW-30, 40)];
    _phoneTextField.delegate=self;
    _phoneTextField.placeholder=@" 请输入手机号";
    _phoneTextField.backgroundColor=[UIColor clearColor];
    _phoneTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_phoneTextField];
    
    
    _verificationCodeTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 40, MainScreenW/2-15, 40)];
    _verificationCodeTextField.delegate=self;

    _verificationCodeTextField.placeholder=@" 请输入验证码";
    _verificationCodeTextField.backgroundColor=[UIColor clearColor];
     [_verificationCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_verificationCodeTextField];
    
    _passwordTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 120, MainScreenW-30, 40)];
    _passwordTextField.delegate=self;
    _passwordTextField.clearButtonMode =UITextFieldViewModeAlways;

    _passwordTextField.placeholder=@" 请输入密码(最多16位)";
    _passwordTextField.backgroundColor=[UIColor clearColor];
    _passwordTextField.secureTextEntry=YES;
 [_passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_passwordTextField];
    
    _confirmpasswordTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 160, MainScreenW-30, 40)];
    _confirmpasswordTextField.delegate=self;
    _confirmpasswordTextField.clearButtonMode =UITextFieldViewModeAlways;
    _confirmpasswordTextField.placeholder=@" 请再次输入密码";
    _confirmpasswordTextField.backgroundColor=[UIColor clearColor];
    _confirmpasswordTextField.secureTextEntry=YES;
    [_confirmpasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_confirmpasswordTextField];

    _getVerificationCodeBtn=[[UIButton alloc]initWithFrame:CGRectMake(MainScreenW/2+5, 45, MainScreenW/2-30, 30)];
    _getVerificationCodeBtn.layer.cornerRadius=5;
    [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0]];
    [_getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getVerificationCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _getVerificationCodeBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [_getVerificationCodeBtn addTarget:self action:@selector(getVerificationCodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_getVerificationCodeBtn];
    
    _nickNameTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 80, MainScreenW-30, 40)];
    _nickNameTextField.delegate=self;
    _nickNameTextField.placeholder=@" 请输入昵称";
    _nickNameTextField.backgroundColor=[UIColor clearColor];
    _nickNameTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_nickNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_nickNameTextField];
    
    _registerBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, _picHeight+250, MainScreenW-20, 40)];
    _registerBtn.layer.cornerRadius=5;
    [_registerBtn setBackgroundColor:[UIColor orangeColor]];
    [_registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerBtn addTarget:self action:@selector(registerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_registerBtn];

}
-(void)getVerificationCodeBtnClicked:(UIButton*)btn
{
    NSString*telStr=[XXYMyTools valiMobile:_phoneTextField.text];
    if([telStr isEqualToString:@"请输入正确的电话号码"])
    {
        [self setUpAlertController:@"请填写正确的手机号!" textField:_phoneTextField];
    }
    else
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@%@",BaseUrl,@"/user/register/otp?mobileNo=",_phoneTextField.text];
        [BSHttpRequest POST:requestUrl parameters:nil success:^(id responseObject){
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//           NSLog(@"注册验证码接口-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
               [self setUpAlertController:@"已发送验证码!" textField:nil];
                [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0]];
                [self countDown];
            }
            else
            {
                [self setUpAlertController:@"发送验证码失败!" textField:nil];
            }
            
        } failure:^(NSError *error) {
            
            NSString*errorString;
            if([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."])
                errorString=@"您的网络异常,请检查网络!";
            else
                errorString=@"获取验证码失败,请稍后重试!";
            
            [self setUpAlertController:errorString textField:_phoneTextField];
        }];
    }
}
-(void)countDown
{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示
                
                if(_phoneTextField.text.length==11)
                {
                   [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
                }
                else
                {
                   [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0]];
                }
                [_getVerificationCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
                _getVerificationCodeBtn.userInteractionEnabled = YES;
            });
        }
        else
        {
            NSString *strTime = [NSString stringWithFormat:@"%.2d", timeout];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示
                
                [UIView beginAnimations:nil context:nil];
                
                [UIView setAnimationDuration:1];
                
                [_getVerificationCodeBtn setTitle:[NSString stringWithFormat:@"%@秒后重新发送",strTime] forState:UIControlStateNormal];
                
                [UIView commitAnimations];
                _getVerificationCodeBtn.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);

}
-(void)registerBtnClicked:(UIButton*)btn
{
    
    
    NSString*telStr=[XXYMyTools valiMobile:_phoneTextField.text];
    if([telStr isEqualToString:@"请输入正确的电话号码"])
    {
        [self setUpAlertController:@"请填写正确的手机号!" textField:_phoneTextField];
    }
    else if([XXYMyTools isEmpty:_verificationCodeTextField.text]||[XXYMyTools isEmpty:_confirmpasswordTextField.text]||[XXYMyTools isEmpty:_nickNameTextField.text]||[XXYMyTools isEmpty:_passwordTextField.text])
    {
        [self setUpAlertController:@"验证码,昵称,密码不能包括空格等特殊字符" textField:nil];
    }
    else if(_verificationCodeTextField.text.length!=6)
    {
        [self setUpAlertController:@"请填写正确的验证码!" textField:_verificationCodeTextField];
    }
    else if (_nickNameTextField.text.length<2||_nickNameTextField.text.length>24)
    {
        [self setUpAlertController:@"昵称为2~24个字符" textField:_nickNameTextField];
    }
    else if (_passwordTextField.text.length<6||_confirmpasswordTextField.text.length<6)
    {
        [self setUpAlertController:@"密码最少为6位!" textField:nil];
    }
    else if (![_passwordTextField.text isEqualToString:_confirmpasswordTextField.text])
    {
        [self setUpAlertController:@"密码不一致!" textField:nil];
    }
    else
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/register"];
        [BSHttpRequest POST:requestUrl parameters:@{@"username":_nickNameTextField.text,@"password":_passwordTextField.text,@"type":@2,@"mobileNo":_phoneTextField.text,@"otp":_verificationCodeTextField.text} success:^(id responseObject){
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
//             NSLog(@"注册接口-Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"注册成功!" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [_alertCon addAction:action2];
                [self presentViewController:_alertCon animated:YES completion:nil];
                
            }
            else
            {
                NSString*messageString;
                if([objString[@"message"] isEqualToString:@"手机号已经被注册"])
                    messageString=@"手机号已经被注册";
                else if ([objString[@"message"] isEqualToString:@"用户名已经被注册"])
                {
                    messageString=@"昵称已经被已经被占用";
                }
                else if ([objString[@"message"] isEqualToString:@"验证码错误"])
                {
                    messageString=@"验证码错误";
                }
                else
                    messageString=@"注册失败";
                [self setUpAlertController:messageString textField:nil];
                
            }
            // NSLog(@"%@",[objString description]);
        } failure:^(NSError *error) {
            NSString*errorString;
            if([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."])
                errorString=@"您的网络异常,请检查网络!";
            else
                errorString=@"注册失败,请稍后重试!";
            [self setUpAlertController:errorString textField:nil];
            
        }];
    }
    
}
-(void)setUpAlertController:(NSString*)str textField:(UITextField*)textfield
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //注销第一响应者身份,隐藏键盘
    [textField resignFirstResponder];
    return YES;
}
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [_phoneTextField resignFirstResponder];
//    [_passwordTextField resignFirstResponder];
//    [_verificationCodeTextField resignFirstResponder];
//    [_nickNameTextField resignFirstResponder];
//}
-(void)tapClicked:(UITapGestureRecognizer*)tap
{
    [_phoneTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_verificationCodeTextField resignFirstResponder];
    [_nickNameTextField resignFirstResponder];
    [_confirmpasswordTextField resignFirstResponder];

}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _otherTextField=textField;
     if (textField == self.phoneTextField||textField == self.verificationCodeTextField)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
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
    if (textField == self.phoneTextField)
    {
        if (textField.text.length > 11)
        {
            textField.text = [textField.text substringToIndex:11];
        }
        if (textField.text.length == 11)
        {
            NSString*telStr=[XXYMyTools valiMobile:_phoneTextField.text];
            if([telStr isEqualToString:@"请输入正确的电话号码"])
            {
                
            }
            else
            {
               [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
            }
            
        }
        else
        {
            [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0]];
        }
    }
    if (textField == self.passwordTextField)
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

    if (textField == self.verificationCodeTextField)
    {
        if (textField.text.length > 6)
        {
            textField.text = [textField.text substringToIndex:6];
        }
    }
    if (textField == self.nickNameTextField)
    {
        if (textField.text.length > 24)
        {
            textField.text = [textField.text substringToIndex:24];
        }
    }

}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

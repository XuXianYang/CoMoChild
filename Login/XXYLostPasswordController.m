#import "XXYLostPasswordController.h"
#import "XXYLoginController.h"
#import"BSHttpRequest.h"
@interface XXYLostPasswordController ()<UITextFieldDelegate>
{
    UIAlertController *_alertCon;
}
@property(nonatomic,strong)UITextField*phoneTextField;
@property(nonatomic,strong)UITextField*verificationCodeTextField;
@property(nonatomic,strong)UITextField*nePasswordTextField;
@property(nonatomic,strong)UIButton*confirmBtn;

@property(nonatomic,strong)UIButton*getVerificationCodeBtn;

@property(nonatomic,strong)UITextField*confirmpasswordTextField;

@end

@implementation XXYLostPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=XXYBgColor;
    [self setUplolostPasswordView];
    
    SVProgressHUD.minimumDismissTimeInterval=1.0;
    SVProgressHUD.maximumDismissTimeInterval=1.5;
}
-(void)setUpNavigationControllerBackButton
{
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"backicon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(0, 0, 30, 30);
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    label.text=@"找回密码";
    UIBarButtonItem*btnItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem*labelItem=[[UIBarButtonItem alloc] initWithCustomView:label];
    
    self.navigationItem.leftBarButtonItems=@[btnItem,labelItem];
}
-(void)viewDidAppear:(BOOL)animated
{
    [self setUpNavigationControllerBackButton];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
-(void)setUplolostPasswordView
{
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(10, 100, MainScreenW-20, 160)];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    for(NSInteger i=0;i<3;i++)
    {
        UIView*lineView=[[UIView alloc]initWithFrame:CGRectMake(5, 40*(i+1), MainScreenW-30, 1)];
        lineView.backgroundColor=XXYBgColor;
        [bgView addSubview:lineView];
    }
    _phoneTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 0, MainScreenW-30, 40)];
    _phoneTextField.placeholder=@" 请输入手机号";
    _phoneTextField.delegate=self;
    _phoneTextField.clearButtonMode =UITextFieldViewModeAlways;

    _phoneTextField.backgroundColor=[UIColor clearColor];
    [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_phoneTextField];
    
    
    _verificationCodeTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 40, MainScreenW/2-15, 40)];
    _verificationCodeTextField.delegate=self;
    _verificationCodeTextField.placeholder=@" 请输入验证码";
    _verificationCodeTextField.backgroundColor=[UIColor clearColor];
    [_verificationCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_verificationCodeTextField];
    
    _nePasswordTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 80, MainScreenW-30, 40)];
    _nePasswordTextField.delegate=self;
    _nePasswordTextField.placeholder=@" 请输入新密码";
    _nePasswordTextField.backgroundColor=[UIColor clearColor];
    _nePasswordTextField.secureTextEntry=YES;
    _nePasswordTextField.clearButtonMode =UITextFieldViewModeAlways;
     [_nePasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_nePasswordTextField];
    
    
    _confirmpasswordTextField=[[UITextField alloc]initWithFrame:CGRectMake(5, 120, MainScreenW-30, 40)];
    _confirmpasswordTextField.delegate=self;
    _confirmpasswordTextField.placeholder=@" 请输入确认密码";
    _confirmpasswordTextField.backgroundColor=[UIColor clearColor];
    _confirmpasswordTextField.secureTextEntry=YES;
    _confirmpasswordTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_confirmpasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [bgView addSubview:_confirmpasswordTextField];
    
    
    _getVerificationCodeBtn=[[UIButton alloc]initWithFrame:CGRectMake(MainScreenW/2+10, 45, MainScreenW/2-40, 30)];
    _getVerificationCodeBtn.layer.cornerRadius=5;
    [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0]];
    [_getVerificationCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_getVerificationCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _getVerificationCodeBtn.titleLabel.font=[UIFont systemFontOfSize:15];
    [_getVerificationCodeBtn addTarget:self action:@selector(getVerificationCodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:_getVerificationCodeBtn];
    
    
    _confirmBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 320, MainScreenW-20, 40)];
    _confirmBtn.layer.cornerRadius=5;
    [_confirmBtn setBackgroundColor:[UIColor orangeColor]];
    [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_confirmBtn];
}
-(void)getVerificationCodeBtnClicked:(UIButton*)btn
{
    
    NSString*telStr=[XXYMyTools valiMobile:_phoneTextField.text];
    if([telStr isEqualToString:@"请输入正确的电话号码"])
    {
        [self setUpAlertController:@"请填写正确的手机号!"];
    }
    else
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@%@",BaseUrl,@"/user/findPassword/otp?mobileNo=",_phoneTextField.text];
        
        [BSHttpRequest POST:requestUrl parameters:nil success:^(id responseObject){
            
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [self setUpAlertController:@"已发送验证码!" ];
                [_getVerificationCodeBtn setBackgroundColor:[UIColor colorWithRed:205.0/255 green:205.0/255 blue:205.0/255 alpha:1.0]];
                [self countDown];
            }
            else
            {
                [self setUpAlertController:@"发送验证码失败!"];
            }
            
        } failure:^(NSError *error) {
            
            NSString*errorString;
            if([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."])
                errorString=@"您的网络异常,请检查网络!";
            else
                errorString=@"获取验证码失败,请稍后重试!";
            
            [self setUpAlertController:errorString];
            
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
-(void)confirmBtnClicked:(UIButton*)btn
{
    [self setUpAlertController];
}

-(void)setUpAlertController
{
    NSString*telStr=[XXYMyTools valiMobile:_phoneTextField.text];
    if([telStr isEqualToString:@"请输入正确的电话号码"])
    {
        [self setUpAlertController:@"请填写正确的手机号!"];
    }
    else if([XXYMyTools isEmpty:_nePasswordTextField.text]||[XXYMyTools isEmpty:_verificationCodeTextField.text]||[XXYMyTools isEmpty:_confirmpasswordTextField.text])
    {
        [self setUpAlertController:@"验证码或者密码不能包含空格等特殊字符"];
    }

    else if(_verificationCodeTextField.text.length!=6)
    {
        [self setUpAlertController:@"请填写正确的验证码!"];
    }
    else if(_nePasswordTextField.text.length<6||_confirmpasswordTextField.text.length<6)
    {
        [self setUpAlertController:@"密码最少为6位!"];
    }
    else if([_nePasswordTextField.text isEqualToString:_confirmpasswordTextField.text])
    {
        [self setUpAlertController:@"密码不一致"];
    }
    else
    {
        NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/register/resetPassword"];
        [BSHttpRequest POST:requestUrl parameters:@{@"otp":_verificationCodeTextField.text,@"mobileNo":_phoneTextField.text,@"password":_nePasswordTextField.text} success:^(id responseObject){
            
            //NSLog(@"1=%@ 2=%@ 3=%@",_verificationCodeTextField.text,_phoneTextField.text,_nePasswordTextField.text);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
//               [self setUpAlertController:@"找回密码成功!"];
                [SVProgressHUD showSuccessWithStatus:@"找回密码成功!"];
                [self.navigationController popViewControllerWithAnimation];
                
            }
            else
            {
                [self setUpAlertController:@"找回密码失败!"];
            }
        } failure:^(NSError *error) {
            
          [self setUpAlertController:@"找回密码失败!"];
        }];
    }
}
-(void)setUpAlertController:(NSString*)str {
    
    _alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:_alertCon animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:_alertCon repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer
{
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_phoneTextField resignFirstResponder];
    [_nePasswordTextField resignFirstResponder];
    [_verificationCodeTextField resignFirstResponder];
    [_confirmpasswordTextField resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.phoneTextField||textField == self.verificationCodeTextField)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
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
    if (textField == self.nePasswordTextField)
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
    if (textField == self.confirmpasswordTextField)
    {
        if (textField.text.length > 16)
        {
            textField.text = [textField.text substringToIndex:16];
        }
    }

}
@end

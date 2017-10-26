#import "XXYJoinSchoolController.h"
#import "BSHttpRequest.h"
#import "AppDelegate.h"
#import "XXYGuideController.h"
@interface XXYJoinSchoolController ()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField*schoolCodeTextField;
@property(nonatomic,strong)UIButton*joinSchoolBtn;
@property(nonatomic,strong)UIImageView*bgImageView;

@end

@implementation XXYJoinSchoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"加入班级";
    self.view.backgroundColor=[UIColor whiteColor];
    
    _bgImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.userInteractionEnabled=YES;
    _bgImageView.image=[[UIImage imageNamed:@"bg_join_class"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.view addSubview:_bgImageView];
    
    [self setUpSubviews];
    [self setUpNavigationControllerBackButton];
    
    if(self.index)
    {
        [self setUpNextBtn];
    }
    
}
-(void)setUpNextBtn
{
    UIButton*nextBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    nextBtn.frame=CGRectMake(MainScreenW-80, 20, 60, 44);
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitle:@"跳过>>" forState:UIControlStateNormal];
    nextBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [nextBtn addTarget:self action:@selector(nextBtnCliked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:nextBtn];
}
-(void)nextBtnCliked
{
    [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"login"];
}
-(void)viewWillAppear:(BOOL)animated
{
    [_schoolCodeTextField becomeFirstResponder];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //设置导航栏为透明色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"transparent"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"transparent"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];

}
-(void)setUpNavigationControllerBackButton
{
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.textAlignment=NSTextAlignmentLeft;
    [btn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame=CGRectMake(20, 20, 60, 44);
   btn.titleLabel.font=[UIFont systemFontOfSize:17];
    [self.view addSubview:btn];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(100, 20, MainScreenW-200, 44)];
    label.text=@"加入班级";
    label.textColor=[UIColor whiteColor];
    label.font=[UIFont fontWithName:@"Helvetica-Bold" size:19];
    label.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:label];
}
-(void)backClicked:(UIButton*)btn
{
    if(self.index)
    {
//        XXYGuideController *loginVC = [[XXYGuideController alloc] init];
//        UINavigationController*navCon = [[UINavigationController alloc] initWithRootViewController:loginVC];
//        [UIApplication sharedApplication].keyWindow.rootViewController = navCon;
        [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"loginOut"];
    }
    else
    {
       [self dismissViewControllerAnimated:YES completion:nil];
    }
   
}

-(void)setUpSubviews
{
    _schoolCodeTextField=[[UITextField alloc]initWithFrame:CGRectMake(20, MainScreenH/2-100, MainScreenW-40, 40)];
    _schoolCodeTextField.layer.cornerRadius=5;
    _schoolCodeTextField.delegate=self;
    _schoolCodeTextField.backgroundColor=[UIColor groupTableViewBackgroundColor];
    _schoolCodeTextField.placeholder=@"请填写班级码";
    _schoolCodeTextField.keyboardType=UIKeyboardTypeASCIICapable;
    UIView*newView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 45)];
    _schoolCodeTextField.leftView=newView;
    _schoolCodeTextField.leftViewMode=UITextFieldViewModeAlways;
    _schoolCodeTextField.clearButtonMode =UITextFieldViewModeAlways;
    [_schoolCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_bgImageView addSubview:_schoolCodeTextField];
    
    _joinSchoolBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _joinSchoolBtn.frame=CGRectMake(20,MainScreenH/2-40, MainScreenW-40, 40);
    _joinSchoolBtn.layer.cornerRadius=5;
    [_joinSchoolBtn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
    _joinSchoolBtn.titleLabel.font=[UIFont systemFontOfSize:19];
    [_joinSchoolBtn setTitle:@"加入班级" forState:UIControlStateNormal];
    [_joinSchoolBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_joinSchoolBtn addTarget:self action:@selector(joinSchoolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_bgImageView addSubview:_joinSchoolBtn];
}
-(void)joinSchoolBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/class/join"];
    
    if([XXYMyTools isEmpty:_schoolCodeTextField.text]||[XXYMyTools isChinese:_schoolCodeTextField.text]||_schoolCodeTextField.text.length==0)
    {
       [self setUpAlertController:@"班级编码不能包含中文,空格等字符"];
    }
    else
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"code":_schoolCodeTextField.text} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSNumber*num=objString[@"code"];
        
        if([objString[@"message"] isEqualToString:@"success"]&&[num integerValue]==0)
        {
           // NSLog(@"sucess11111");
            
            UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"加入班级成功" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                if(self.index)
                {
//                    XXYGuideController *loginVC = [[XXYGuideController alloc] init];
//                    UINavigationController*navCon = [[UINavigationController alloc] initWithRootViewController:loginVC];
//                    [UIApplication sharedApplication].keyWindow.rootViewController = navCon;
                    [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"loginOut"];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
            [alertCon addAction:action1];

            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
                if(self.index)
                {
                    [(AppDelegate*)[UIApplication sharedApplication].delegate showWindowHome:@"login"];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
            [alertCon addAction:action2];
            [self presentViewController:alertCon animated:YES completion:nil];

        }
        else
        {
            NSString*failString=objString[@"message"];
            [self setUpAlertController:failString];
        }
        
        } failure:^(NSError *error) {
        [self setUpAlertController:@"加入班级失败"];
        }];

}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:str preferredStyle:UIAlertControllerStyleAlert];
    
     [self presentViewController:alertCon animated:YES completion:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_schoolCodeTextField resignFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.schoolCodeTextField)
    {
        if (textField.text.length > 8)
        {
            textField.text = [textField.text substringToIndex:8];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

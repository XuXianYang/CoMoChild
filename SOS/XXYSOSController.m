#import "XXYSOSController.h"
#import "XXYBackButton.h"

#import"LMComBoxView.h"
#import "LMContainsLMComboxScrollView.h"

#import "BSHttpRequest.h"

@interface XXYSOSController ()<LMComBoxViewDelegate>
{
    UIDatePicker *_datepicker;
}
@property(nonatomic,strong)UIButton*selTimeBtn;

@property(nonatomic,strong)UIButton*selTimeComfirmBtn;
@property(nonatomic,strong)UIView*datePickerView;

@property(nonatomic,copy)NSString*currentDateString;

@property (nonatomic, strong) LMComBoxView *comBox;
@property(nonatomic,retain)NSArray*dataList;

@property(nonatomic,strong)UIButton*totalComfirmBtn;//timeout

@property(nonatomic,copy)NSString*timeoutString;

@end
@implementation XXYSOSController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    _timeoutString=@"0分钟";
    [self setUpSubViews];
}
-(NSArray*)dataList
{
    if(!_dataList)
    {
        _dataList=@[@"0分钟",@"15分钟",@"30分钟",@"45分钟",@"60分钟",@"75分钟",@"90分钟",@"105分钟",@"120分钟"];
    }
    return _dataList;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UIView*view in [_datePickerView subviews])
    {
        [view removeFromSuperview];
    }
    [_datePickerView removeFromSuperview];
    if(_comBox.isOpen)
    {
        [_comBox tapAction];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}
-(void)setUpSubViews
{
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenH, 64)];
    view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:view];
    
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(10, 27, 30, 30);
    [btn setImage:[UIImage imageNamed:@"navigationbar_back_withtext_highlighted_001"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(plusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake((MainScreenW-200)/2, 27, 200, 30)];
    label.font=[UIFont fontWithName:@"Helvetica-Bold" size:19];
    label.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"设置到家时间";
    [view addSubview:label];
    
    
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(15, 94, MainScreenW-30, 100)];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    UILabel*lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,49.5, MainScreenW-50, 1)];
    lineLabel.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    [bgView addSubview:lineLabel];
    
    
    NSArray*nameLabel=@[@"预计到家",@"误差时间"];
    
    for(int i=0;i<2;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(10,50*i, 80, 50)];
        titleLabel.text=nameLabel[i];
        titleLabel.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
        [bgView addSubview:titleLabel];
    }
    
    UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    selBtn.frame=CGRectMake(90, 0, bgView.frame.size.width-110, 50);
    selBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [selBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [selBtn setTitle:@"请选择" forState:UIControlStateNormal];
    [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:selBtn];
    _selTimeBtn=selBtn;
    
    _totalComfirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _totalComfirmBtn.frame=CGRectMake(15, 224, MainScreenW-30, 50);
    _totalComfirmBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [_totalComfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_totalComfirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_totalComfirmBtn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
    [_totalComfirmBtn addTarget:self action:@selector(totalBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_totalComfirmBtn];

    
    _comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(145, 149, bgView.frame.size.width-190, 40)];
    _comBox.backgroundColor = [UIColor clearColor];
    //_comBox.arrowImgName = @"down_dark0.png";
    _comBox.titlesList = [NSMutableArray arrayWithArray:self.dataList];
    _comBox.delegate = self;
    _comBox.supView = self.view;
    [_comBox defaultSettings];
    _comBox.tag = 100;
    [self.view addSubview:_comBox];
}
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
    //NSLog(@"title=%@",_combox.titlesList[index]);
    _timeoutString=_combox.titlesList[index];
}
-(void)totalBtnClicked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/sos/msg/warningConfig"];
    
    NSString*timeOut=[_timeoutString substringWithRange:NSMakeRange(0, _timeoutString.length-2)];
    
//    NSLog(@"11==%@,22==%@",_currentDateString,_timeoutString);
    
    if(_currentDateString!=NULL)
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"expectTime":_currentDateString,@"timeout":timeOut} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
                if([self.sendDelegate respondsToSelector:@selector(sendNewDataOfSettingTime:)])
                {
                    [self.sendDelegate sendNewDataOfSettingTime:_currentDateString];
                }
            }];
        }
        else
        {
            [self setUpAlertController:@"设置失败"];
        }
    } failure:^(NSError *error) {
    }];
    else
    {
        [self setUpAlertController:@"请选择到家时间"];
    }
}
//设置弹框
-(void)setUpAlertController:(NSString*)string
{
    UIAlertController*alert = [UIAlertController alertControllerWithTitle:@"" message:string preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alert repeats:NO];
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
//        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    alert = nil;
}

-(void)selBtnClicked:(UIButton*)btn
{
    [self setUpDatePickerView];
}

-(void)setUpDatePickerView
{
    
    for (UIView*view in [_datePickerView subviews])
    {
        [view removeFromSuperview];
    }
    [_datePickerView removeFromSuperview];
    
    _datePickerView=[[UIView alloc]initWithFrame:CGRectMake(0, MainScreenH-266, MainScreenW, 266)];
    _datePickerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_datePickerView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    label.text=@"请选择预计到家时间";
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:17];
    [_datePickerView addSubview:label];
    
    
    _selTimeComfirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_selTimeComfirmBtn setBackgroundColor:[UIColor whiteColor]];
    _selTimeComfirmBtn.frame=CGRectMake(MainScreenW-60, 0, 60, 50);
    [_selTimeComfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_selTimeComfirmBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:150.0/255 blue:248.0/255 alpha:1.0] forState:UIControlStateNormal];
    _selTimeComfirmBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [_selTimeComfirmBtn addTarget:self action:@selector(selTimeComfirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_datePickerView addSubview:_selTimeComfirmBtn];
    
    _datepicker = [[UIDatePicker alloc] init];
    _datepicker.backgroundColor=[UIColor colorWithRed:206.0/255 green:213.0/255 blue:218.0/255 alpha:1.0];
    _datepicker.datePickerMode = UIDatePickerModeTime;
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-cn"];
    _datepicker.locale=cnLocale;
    _datepicker.frame = CGRectMake(0, MainScreenH, MainScreenW, 216);
    [_datePickerView addSubview:_datepicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0,50, MainScreenW, 216);
    }];
    _currentDateString=[self getDateStr:_datepicker.date];
    [_selTimeBtn setTitle:_currentDateString forState:UIControlStateNormal];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
}
-(void)selTimeComfirmBtnClicked:(UIButton*)btn
{
    [_datepicker removeFromSuperview];
    [_selTimeComfirmBtn removeFromSuperview];
    _datepicker=nil;
    [_datePickerView removeFromSuperview];
}
- (void)changeDate:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *date = datePicker.date;
    _currentDateString=[self getDateStr:date];
    [_selTimeBtn setTitle:_currentDateString forState:UIControlStateNormal];
    
}
// 获取日期键盘的日期
- (NSString *)getDateStr:(NSDate *)date
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"H:mm:ss"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}

-(void)plusBtnClicked:(UIButton*)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

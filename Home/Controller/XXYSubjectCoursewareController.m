#import "XXYSubjectCoursewareController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import"LMComBoxView.h"
#import "LMContainsLMComboxScrollView.h"
#import "XXYCourseWareListController.h"
@interface XXYSubjectCoursewareController ()<LMComBoxViewDelegate>
{
    UIDatePicker *_datepicker;
}

@property (nonatomic, strong) LMComBoxView *comBox;
@property (nonatomic, retain) NSMutableArray *dataList;
@property (nonatomic,strong)  UIButton*startTimeBtn;
@property (nonatomic,strong)  UIButton*endTimeBtn;
@property (nonatomic,strong)  UIButton*selTimeComfirmBtn;
@property (nonatomic,strong)  UIView*datePickerView;
@property (nonatomic, copy)   NSString *courseId;
@property (nonatomic, copy)   NSString *courseType;
@property (nonatomic, copy)   NSString *startDate;
@property (nonatomic, copy)   NSString *endDate;

@end

@implementation XXYSubjectCoursewareController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"查询课件";
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    [self setUpSubViews];
    
    _courseType=@"1";
    
    if(self.dataList.count>0)
    {
        NSMutableDictionary*dict=self.dataList[0];
        _courseId=dict[@"courseId"];
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_datePickerView removeFromSuperview];
    for (UIView*view in [self.view subviews])
    {
        if([view isKindOfClass:[LMComBoxView class]])
        {
            LMComBoxView*box=(LMComBoxView*)view;
            if(box.isOpen)
            {
                [box tapAction];
            }
        }
    }
    
}
-(void)setUpSubViews
{
    UIView*bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 44*4)];
    bgView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bgView];
    
    NSArray*titleArray=@[@"课        程:",@"类        型:",@"起始日期:",@"结束日期:"];
    
    for(int i=0;i<4;i++)
    {
        UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(25,44*i, 80, 44)];
        titleLabel.text=titleArray[i];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
        [bgView addSubview:titleLabel];
        
        UILabel*lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,44*(i+1), MainScreenW, 1)];
        lineLabel.backgroundColor=[UIColor colorWithRed:208.0/255 green:208.0/255 blue:208.0/255 alpha:1.0];
        [bgView addSubview:lineLabel];
    }
    UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame=CGRectMake(25,MainScreenH*1/2, MainScreenW-50, 40);
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    btn.layer.cornerRadius=5;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [btn addTarget:self action:@selector(confirmBntClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self setUpComBox:1 AndDataArray:[NSMutableArray arrayWithArray:@[@"预习向导",@"课堂笔记",@"课件"]]];
    
    [self getComBoxListData];
    
    for(int i=0;i<2;i++)
    {
        UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        selBtn.frame=CGRectMake(130, 7+44*(i+2), MainScreenW-200, 30);
        //selBtn.titleLabel.font=[UIFont systemFontOfSize:16];
        [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:selBtn];
        selBtn.tag=200+i;
        if(i==0)
        {
            _startDate=[self getDateStr:[NSDate date]];
            [selBtn setTitle:_startDate forState:UIControlStateNormal];
            _startTimeBtn=selBtn;
        }
        else
        {
            _endDate=[self getDateStr:[NSDate date]];
            [selBtn setTitle:_endDate forState:UIControlStateNormal];
            _endTimeBtn=selBtn;
        }
    }
}
-(void)setUpComBox:(NSInteger)tag AndDataArray:(NSMutableArray*)array
{
    _comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(130, 7+44*tag, MainScreenW-200, 30)];
    _comBox.backgroundColor = [UIColor clearColor];
    //_comBox.arrowImgName = @"down_dark0.png";
    
    _comBox.delegate = self;
    _comBox.supView = self.view;
    if(tag==0)
    {
        if([array[0] isKindOfClass:[NSMutableDictionary class]])
        {
            NSMutableArray*dataArray=[NSMutableArray array];
            for (int i=0;i<array.count;i++)
            {
                NSMutableDictionary*model=array[i];
                [dataArray addObject:model[@"courseName"]];
            }
            _comBox.titlesList=dataArray;
        }
    }
    else
    {
       _comBox.titlesList=array;
    }
    [_comBox defaultSettings];
    _comBox.tag = 100+tag;
    [self.view addSubview:_comBox];
}
-(void)getComBoxListData
{
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/course/assignment/list"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSMutableArray*courseListArray=[defaults objectForKey:@"studentCourseInfoList"];
    if(courseListArray.count>0)
    {
        if([courseListArray[0] isKindOfClass:[NSMutableDictionary class]])
        {
            [self setUpComBox:0 AndDataArray:courseListArray];
        }
    }
    else
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){

        //NSLog(@"termlist=Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArray=objString[@"data"];
        
        if(dataArray.count>0)
        {
            NSMutableArray*array=[NSMutableArray array];
            
            for (NSDictionary*dict in dataArray)
            {
                NSMutableDictionary*model=[[NSMutableDictionary alloc]init];
                model[@"courseId"]=dict[@"courseId"];
                model[@"courseName"]=dict[@"courseName"];
                [array addObject:model];
            }
            
            [self setUpComBox:0 AndDataArray:array];
            NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
            [defaultss setObject:array forKey:@"studentCourseInfoList"];
        }
        else
        {
           [self setUpComBox:0 AndDataArray:[NSMutableArray arrayWithArray:@[@"",@"",@""]]];
        }
        
    } failure:^(NSError *error) {
    }];
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _dataList=[defaults objectForKey:@"studentCourseInfoList"];
    }
    return _dataList;
}
-(NSString*)turnCourseNameToCourseId:(NSString*)courseName
{
    NSString*courseId=@"1";
    if(self.dataList.count>0)
    {
        if([self.dataList[0] isKindOfClass:[NSMutableDictionary class]])
        {
            for (NSMutableDictionary*dict in self.dataList)
            {
                if([dict[@"courseName"] isEqualToString:courseName])
                {
                    courseId=dict[@"courseId"];
                    return courseId;
                }
            }
        }
    }
    return courseId;
}
-(NSString*)turnCourseTypeNameToCoursetypeId:(NSString*)typeName
{
    NSString*courseTypeId=@"1";
    NSArray*array=@[@"预习向导",@"课堂笔记",@"课件"];
    for (int i=1;i<4;i++)
    {
        NSString*string=array[i-1];
        if([typeName isEqualToString:string])
        {
            return [NSString stringWithFormat:@"%i",i];
        }
    }
    return courseTypeId;
}
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
     switch (_combox.tag) {
        case 100:
        {
            _courseId=[self turnCourseNameToCourseId:_combox.titlesList[index]];
        }
            break;
        case 101:
        {
            _courseType=[self turnCourseTypeNameToCoursetypeId:_combox.titlesList[index]];
        }
            break;
        default:
            break;
    }
}
-(void)selBtnClicked:(UIButton*)btn
{
    [self setUpDatePickerView:btn.tag];
}
-(void)setUpDatePickerView:(NSInteger)btnTag
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
    _datepicker.datePickerMode = UIDatePickerModeDate;
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-cn"];
    _datepicker.locale=cnLocale;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:1];//设置最大时间为：当前时间推后1年
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-1];//设置最小时间为：当前时间前推1年
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [_datepicker setMaximumDate:maxDate];
    [_datepicker setMinimumDate:minDate];

    _datepicker.frame = CGRectMake(0, MainScreenH, MainScreenW, 216);
    _datepicker.tag=btnTag+100;
    [_datePickerView addSubview:_datepicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0,50, MainScreenW, 216);
    }];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    if(btnTag==200)
    {
        label.text=@"请选择开始日期";
    }
    else
    {
        label.text=@"请选择结束日期";
    }
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
    
    switch (datePicker.tag) {
        case 300:
        {
            _startDate=[self getDateStr:date];
            [_startTimeBtn setTitle:_startDate forState:UIControlStateNormal];
        }
            break;
        case 301:
        {
            _endDate=[self getDateStr:date];
            [_endTimeBtn setTitle:_endDate forState:UIControlStateNormal];
        }
            break;
  
        default:
            break;
    }
}
// 获取日期键盘的日期
- (NSString *)getDateStr:(NSDate *)date
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}

-(void)confirmBntClicked:(UIButton*)btn
{
    //NSLog(@"courseid=%@,coursetype=%@,startDate=%@,endDate=%@",_courseId,_courseType,_startDate,_endDate);
    
    XXYCourseWareListController*listCon=[[XXYCourseWareListController alloc]init];
    listCon.courseId=_courseId;
    listCon.courseType=_courseType;
    listCon.startDate=_startDate;
    listCon.endDate=_endDate;
    [self.navigationController pushViewController:listCon animated:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

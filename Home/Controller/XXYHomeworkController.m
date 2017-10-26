#import "XXYHomeworkController.h"
#import "XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYHomeworkModel.h"
@interface XXYHomeworkController ()<UIScrollViewDelegate>
{
    UIDatePicker *_datepicker;
}

@property(nonatomic,strong)UIScrollView*homeworkContentScrollView;

@property(nonatomic,strong)UIScrollView*homeworkOfCourseScrollView;

@property(nonatomic,strong)UIScrollView*homeworkOfDetailScrollView;

@property(nonatomic,strong)UIButton*selTimeBtn;
@property(nonatomic,strong)UILabel*pageNumber;

@property(nonatomic,assign)NSInteger totalPageNumber;

@property(nonatomic,strong)UIButton*selTimeComfirmBtn;
@property(nonatomic,strong)UIView*datePickerView;

@property(nonatomic,copy)NSString*currentDateString;

@end

@implementation XXYHomeworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"作业本";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    //[self setUpSelTimeBtn];
    
    //[self setUpNoHomeworkOfSubViews];
    _currentDateString=[self getDateStr:[NSDate date]];
    
    [self getNewData:_currentDateString];
}

-(void)setUpDatePickerView
{
    _datePickerView=[[UIView alloc]initWithFrame:CGRectMake(0, MainScreenH-266, MainScreenW, 266)];
    _datePickerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_datePickerView];
    
    _selTimeComfirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _selTimeComfirmBtn.frame=CGRectMake(MainScreenW-100, 0, 100, 30);
    [_selTimeComfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_selTimeComfirmBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:150.0/255 blue:248.0/255 alpha:1.0] forState:UIControlStateNormal];
    _selTimeComfirmBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [_selTimeComfirmBtn addTarget:self action:@selector(selTimeComfirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_datePickerView addSubview:_selTimeComfirmBtn];
    
    _datepicker = [[UIDatePicker alloc] init];
    _datepicker.backgroundColor=[UIColor whiteColor];
    _datepicker.datePickerMode = UIDatePickerModeDate;
    
    
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-cn"];
    
    _datepicker.locale=cnLocale;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:3];//设置最大时间为：当前时间推后十年
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-3];//设置最小时间为：当前时间前推十年
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [_datepicker setMaximumDate:maxDate];
    [_datepicker setMinimumDate:minDate];
    
    _datepicker.frame = CGRectMake(0, _datePickerView.frame.size.height-20, 0, 0);
    [_datePickerView addSubview:_datepicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0,25, MainScreenW, 236);
    }];
    [_selTimeBtn setTitle:[self getDateStr:_datepicker.date] forState:UIControlStateNormal];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
}
-(void)selTimeComfirmBtnClicked:(UIButton*)btn
{
    [_datepicker removeFromSuperview];
    [_selTimeComfirmBtn removeFromSuperview];
    _datepicker=nil;
    [_datePickerView removeFromSuperview];

    //NSLog(@"11--%@",_selTimeBtn.currentTitle);
    
    [self getNewData:_selTimeBtn.currentTitle];
}
-(void)setUpDatePicker:(UIView*)view
{
    _datepicker = [[UIDatePicker alloc] init];
    _datepicker.backgroundColor=[UIColor whiteColor];
    _datepicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datepicker.frame = CGRectMake(0, view.frame.size.height-50, 0, 0);
    [view addSubview:_datepicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0, view.frame.size.height-50, [UIScreen mainScreen].bounds.size.width, 216);
    }];
    [_selTimeBtn setTitle:[self getDateStr:_datepicker.date] forState:UIControlStateNormal];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
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
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}
-(void)setUpSelTimeBtn
{
    
    [_selTimeBtn removeFromSuperview];
    
    _selTimeBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _selTimeBtn.frame=CGRectMake(15, 10, MainScreenW-30, 40);
    _selTimeBtn.layer.cornerRadius=15;
    _selTimeBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    _selTimeBtn.backgroundColor=[UIColor whiteColor];
    [_selTimeBtn setTitle:_currentDateString forState:UIControlStateNormal];
    [_selTimeBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_selTimeBtn];

}
-(void)setUpNoHomeworkOfSubViews
{
    
    for(UIView *view in [self.view subviews])
    {
        [view removeFromSuperview];
    }

    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 60, MainScreenW, MainScreenH-64-60)];
    view.backgroundColor=[UIColor whiteColor];
    view.tag=100;
    [self.view addSubview:view];
    
    //320*260
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(80, 50, MainScreenW-160,(MainScreenW-160)*13/16)];
    imageView.tag=101;
    imageView.image=[UIImage imageNamed:@"no-content"];
    [view addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, (MainScreenW-160)*13/16+60, MainScreenW-100,50)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:16];
    label.text=@"暂无作业本内容";
    label.tag=102;
    [view addSubview:label];
}
-(void)setUpHomeworkOfSubViews:(NSArray*)dataArray
{
    for(UIView *view in [self.view subviews])
    {
        [view removeFromSuperview];
    }
    _totalPageNumber=dataArray.count;
    
    _homeworkContentScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 60, MainScreenW, MainScreenH-64-60)];
    _homeworkContentScrollView.backgroundColor=[UIColor whiteColor];
    _homeworkContentScrollView.contentSize=CGSizeMake(0, MainScreenH);
    _homeworkContentScrollView.showsVerticalScrollIndicator=NO;
    _homeworkContentScrollView.bounces=NO;
    _homeworkContentScrollView.tag=200;
    [self.view addSubview:_homeworkContentScrollView];
    
    
    _homeworkOfCourseScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0, MainScreenW, (MainScreenH-64-60)/2-40)];
    _homeworkOfCourseScrollView.backgroundColor=[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0];
    _homeworkOfCourseScrollView.contentSize=CGSizeMake(MainScreenW*dataArray.count, 0);
    _homeworkOfCourseScrollView.showsHorizontalScrollIndicator=NO;
    _homeworkOfCourseScrollView.bounces=NO;
    _homeworkOfCourseScrollView.pagingEnabled=YES;
    _homeworkOfCourseScrollView.tag=201;
    _homeworkOfCourseScrollView.delegate=self;
    [_homeworkContentScrollView addSubview:_homeworkOfCourseScrollView];
    
    
    _homeworkOfDetailScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,(MainScreenH-64-60)/2, MainScreenW, MainScreenH)];
    _homeworkOfDetailScrollView.backgroundColor=[UIColor whiteColor];
    _homeworkOfDetailScrollView.contentSize=CGSizeMake(MainScreenW*dataArray.count, 0);
    _homeworkOfDetailScrollView.showsHorizontalScrollIndicator=NO;
    _homeworkOfDetailScrollView.bounces=NO;
    _homeworkOfDetailScrollView.pagingEnabled=YES;
    _homeworkOfDetailScrollView.tag=202;
    _homeworkOfDetailScrollView.scrollEnabled=NO;
    _homeworkOfDetailScrollView.delegate=self;
    [_homeworkContentScrollView addSubview:_homeworkOfDetailScrollView];
    
    for(int i=0;i<dataArray.count;i++)
    {
        XXYHomeworkModel*model=dataArray[i];
        // 222*284
        UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW-((MainScreenH-64-60)/2-50)*0.78)/2+MainScreenW*i, 10,((MainScreenH-64-60)/2-50)*0.78, (MainScreenH-64-60)/2-50)];
        
        imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"book%i",(model.courseId.intValue-1)%6+1]];
        
        [_homeworkOfCourseScrollView addSubview:imageView];
        
        UILabel*courseNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.size.width/3, imageView.frame.size.height*1/5, imageView.frame.size.width*3/4, 40)];
        courseNameLabel.text=model.courseName;
        courseNameLabel.font=[UIFont systemFontOfSize:16];
        courseNameLabel.textColor=[UIColor whiteColor];
        [imageView addSubview:courseNameLabel];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:_currentDateString];
        
        UILabel*weekdayLabel=[[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.size.width/6, imageView.frame.size.height*3/5-10, imageView.frame.size.width*1/3, 40)];
        weekdayLabel.text=[self weekdayStringFromDate:date];
        weekdayLabel.font=[UIFont systemFontOfSize:14];

        weekdayLabel.textColor=[UIColor whiteColor];
        [imageView addSubview:weekdayLabel];

        UILabel*teacherNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.size.width/2-20, imageView.frame.size.height*3/5-10, imageView.frame.size.width/2+10, 40)];
        teacherNameLabel.text=model.teacherName;
        teacherNameLabel.font=[UIFont systemFontOfSize:14];
        teacherNameLabel.textAlignment=NSTextAlignmentRight;

        teacherNameLabel.textColor=[UIColor whiteColor];
        [imageView addSubview:teacherNameLabel];
        
        NSMutableArray*homeworkDetailArray=model.courseHomeworkContent;
        
        for (int j=0 ;j<homeworkDetailArray.count;j++) {

            NSString*contentString=homeworkDetailArray[j];
            UILabel*label=[[UILabel alloc]init];
             CGSize titleSize = [contentString boundingRectWithSize:CGSizeMake(MainScreenW-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
            label.frame=CGRectMake(20+MainScreenW*i, 40+80*j, MainScreenW-40, titleSize.height+30);
            label.layer.borderColor=[UIColor clearColor].CGColor;
            label.text=contentString;
            label.numberOfLines=0;
            label.backgroundColor=[UIColor colorWithRed:230.0/255 green:242.0/255 blue:254.0/255 alpha:1.0];
            [_homeworkOfDetailScrollView addSubview:label];
        }
    }
    
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, (MainScreenH-64-60)/2-40, MainScreenW, 40)];
    view.backgroundColor=[UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1.0];
    [_homeworkContentScrollView addSubview:view];
    
    _pageNumber=[[UILabel alloc]initWithFrame:CGRectMake(120, (MainScreenH-64-60)/2-35, MainScreenW-240, 30)];
    _pageNumber.textAlignment=NSTextAlignmentCenter;
    _pageNumber.textColor=[UIColor lightGrayColor];
    _pageNumber.font=[UIFont systemFontOfSize:17];
    _pageNumber.text=[NSString stringWithFormat:@"1 / %li",_totalPageNumber];
    [_homeworkContentScrollView addSubview:_pageNumber];
    
    
    UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(30, (MainScreenH-64-60)/2-25, 50, 50)];
    
    titleLabel.backgroundColor=[UIColor colorWithRed:0.0/255 green:150.0/255 blue:248.0/255 alpha:1.0];
    
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.text=@"TIPS";
    titleLabel.layer.cornerRadius=25;
    titleLabel.clipsToBounds = YES;
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [_homeworkContentScrollView addSubview:titleLabel];
    
}
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag==201)
    {
        NSInteger currentIndex=scrollView.contentOffset.x / MainScreenW;
        _pageNumber.text=[NSString stringWithFormat:@"%li / %li",currentIndex+1,_totalPageNumber];
        
        _homeworkOfDetailScrollView.contentOffset=CGPointMake(MainScreenW*currentIndex,0);
    }
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView.tag==201)
    {
        if(!decelerate)
        {
            NSInteger currentIndex=scrollView.contentOffset.x / MainScreenW;
            _pageNumber.text=[NSString stringWithFormat:@"%li / %li",currentIndex+1,_totalPageNumber];
            _homeworkOfDetailScrollView.contentOffset=CGPointMake(MainScreenW*currentIndex,0);
        }
    }

}

-(void)selBtnClicked:(UIButton*)btn
{
    [_datepicker removeFromSuperview];
    [_selTimeComfirmBtn removeFromSuperview];
    _datepicker=nil;
    [_datePickerView removeFromSuperview];

    [self setUpDatePickerView];
}
-(void)getNewData:(NSString*)dateString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/homework/review/list"];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"studyDate":dateString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //{"course":{"id":1,"name":"语文"},"teacher":{"teacherUserId":3,"teacherId":2,"realName":"张老师"},"homeworks":[{"homeworkId":50,"name":"第一份作业","description":"111366444","reviewed":false},{"homeworkId":51,"name":"第二份作业","description":"1667646","reviewed":false},{"homeworkId":52,"name":"第三份作业","description":"466466","reviewed":false}]}
        
        NSMutableArray*homworkArray=[NSMutableArray array];
        
        NSArray*dataArray=objString[@"data"][@"courses"];
        for (NSDictionary*dict in dataArray)
        {
            XXYHomeworkModel*model=[[XXYHomeworkModel alloc]init];
            model.courseHomeworkContent=[NSMutableArray array];
            model.courseName=dict[@"course"][@"name"];
            model.courseId=dict[@"course"][@"id"];
            model.teacherName=dict[@"teacher"][@"realName"];
            NSArray*homeworkContentArray=dict[@"homeworks"];
            for (NSDictionary*content in homeworkContentArray)
            {
                NSString*detailString=content[@"description"];
                [model.courseHomeworkContent addObject:detailString];
                
            }
            [homworkArray addObject:model];
        }
        if(homworkArray.count>0)
        {
            [self setUpHomeworkOfSubViews:homworkArray];
            [self setUpSelTimeBtn];
        }
        else
        {
            [self setUpNoHomeworkOfSubViews];
            [self setUpSelTimeBtn];
        }
           } failure:^(NSError *error) {
    }];

}
- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
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

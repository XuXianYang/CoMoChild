#import "XXYBurnCaloriesController.h"
#import "XXYBackButton.h"
#import "LMComBoxView.h"
#import "BSHttpRequest.h"
#import "LMContainsLMComboxScrollView.h"
#import "FSCalendar.h"
#import "XXYTimeShartModel.h"
#import "XXYTimeShaftTableView.h"
#import "XXYPublishDynamicController.h"
#import "XXYAbandonCaloriesController.h"
#import "XXYCaloriesOfSecondPageOfAddInfoController.h"
#import "XXYRankingListModel.h"
#import "XXYRankingListTableView.h"
#import"XXYCheckMoreRankingListController.h"
#import"XXYCaloriesUnitTableView.h"


@interface XXYBurnCaloriesController ()<UIScrollViewDelegate,LMComBoxViewDelegate,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance,XXYcheckMoreDelegate,XXYReloadNewDataDelegate>
{
    UIDatePicker *_datepicker;
}
@property(nonatomic,strong)UIScrollView*scrollView;
@property(nonatomic,strong)UIScrollView*firstPageScrollView;
@property(nonatomic,strong)UIScrollView*secondPageScrollView;
@property(nonatomic,strong)UIView*firstPageTitleBgView;
@property(nonatomic,strong)UIButton*burnCaloriesBtn;
@property(nonatomic,strong)UIButton*chartsBtn;
@property (nonatomic, strong) LMComBoxView *comBox;
@property(nonatomic,retain)NSMutableArray*comBoxDataList;
@property(nonatomic,strong)UIButton*selTimeComfirmBtn;
@property(nonatomic,strong)UIView*datePickerView;
@property(nonatomic,strong)UILabel*totalCalorieLabel;
@property(nonatomic,assign)NSInteger totalMinute;
@property(nonatomic,assign)NSInteger totalCalorie;
@property(nonatomic,copy)NSString* calorieUnit;
@property(nonatomic,copy)NSString* calorieItemId;
@property (weak, nonatomic) FSCalendar *calendar;
@property(nonatomic,strong)UIButton*immediatelyPunchBtn;
@property(nonatomic,strong)UIButton*writeToDiaryBtn;
@property(nonatomic,strong)UIImageView*iconImageView;
@property(nonatomic,strong)UIButton*shareCalorieBtn;
@property(nonatomic,strong)UIButton*abandonCalorieBtn;
@property(nonatomic,strong)XXYTimeShaftTableView*timeShaftTableView;
@property(nonatomic,strong)UILabel*monthOfTotalCaloriesLabel;


@end

@implementation XXYBurnCaloriesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"消卡少年";
    
    _totalMinute=0;
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self setUpNavigationItemView];
    [self setUpFirstPageView];
    [self setUpSecondPageTableView];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.comBoxDataList=[defaults objectForKey:@"calorieItemsList"];
    
    if(self.comBoxDataList.count>0)
    {
        NSDictionary*itemInfoDict=self.comBoxDataList[0];
        _calorieItemId=itemInfoDict[@"id"];
        _calorieUnit=itemInfoDict[@"calorieMin"];
    }
    else
    {
        _calorieItemId=@"9";
        _calorieUnit=@"700";
    }
    [self setUpCalendarView];
    
    [self getCaloriesOfUsedInfoData:[self turnDateToString:[NSDate date]]];
}
-(void)setUpSecondPageView
{
    UIImageView*secondPageAddImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 80)];
    secondPageAddImageView.backgroundColor=[UIColor redColor];
    secondPageAddImageView.userInteractionEnabled=YES;
    secondPageAddImageView.image=[UIImage imageNamed:@"homeslide 2.jpg"];
//    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSecondPageOfAd)];
//    [secondPageAddImageView addGestureRecognizer:tapGesturRecognizer];
    
    [_secondPageScrollView addSubview:secondPageAddImageView];
    
}
-(void)setUpSecondPageTableView
{
    XXYRankingListTableView*rangingListTableView= [XXYRankingListTableView contentTableView];
    rangingListTableView.frame=CGRectMake(15, 10, MainScreenW-30, 250);
    rangingListTableView.rankingListIndex=1;
    rangingListTableView.layer.cornerRadius=10;
    rangingListTableView.backgroundColor=[UIColor whiteColor];
    rangingListTableView.bounces=NO;
    rangingListTableView.checkMoreDelegate=self;
    rangingListTableView.showsVerticalScrollIndicator=NO;
    [rangingListTableView addRefreshLoadMore];
    [_secondPageScrollView addSubview:rangingListTableView];
    
    XXYCaloriesUnitTableView*caloriesUnitTableView= [XXYCaloriesUnitTableView contentTableView];
    caloriesUnitTableView.frame=CGRectMake(15, 270, MainScreenW-30, 240);
    caloriesUnitTableView.layer.cornerRadius=10;
    caloriesUnitTableView.backgroundColor=[UIColor whiteColor];
    caloriesUnitTableView.bounces=NO;
    caloriesUnitTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    caloriesUnitTableView.showsVerticalScrollIndicator=NO;
    [_secondPageScrollView addSubview:caloriesUnitTableView];

}
-(void)checkMoreClicked
{
    XXYCheckMoreRankingListController*checkCon=[[XXYCheckMoreRankingListController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:checkCon];
}
-(void)tapSecondPageOfAd
{
    XXYCaloriesOfSecondPageOfAddInfoController*adCon=[[XXYCaloriesOfSecondPageOfAddInfoController alloc]init];
    [self.navigationController pushViewControllerWithAnimation:adCon];
}
-(void)setUpCalendarView
{
    //CGFloat height = [[UIDevice currentDevice].model hasPrefix:@"iPad"] ? 360 : 240;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 135, MainScreenW-40, 240)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.appearance.titleSelectionColor=[UIColor whiteColor];//选中字体色
    calendar.appearance.selectionColor=[UIColor colorWithRed:131.0/255 green:201.0/255 blue:245.0/255 alpha:1.0];//选中背景色
    calendar.appearance.weekdayTextColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];//星期字体色
    calendar.appearance.headerTitleColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];//头部字体色
    calendar.appearance.todayColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    calendar.appearance.titleTodayColor=[UIColor whiteColor];
    calendar.appearance.todaySelectionColor=[UIColor colorWithRed:131.0/255 green:201.0/255 blue:245.0/255 alpha:1.0];;
    
    calendar.allowsMultipleSelection = YES;
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [_firstPageTitleBgView addSubview:calendar];
    self.calendar = calendar;
    
    UIView*calendarLineBgView=[[UIView alloc]initWithFrame:CGRectMake(0,calendar.frame.size.height-1, calendar.frame.size.width, 2)];
    calendarLineBgView.backgroundColor=[UIColor whiteColor];
    [calendar addSubview:calendarLineBgView];
    
    [self getCaloriesAttendanceData:[self turnDateToString:[NSDate date]]];
}
- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    [self getCaloriesAttendanceData:[self turnDateToString:calendar.currentPage]];
    [self getCaloriesOfUsedInfoData:[self turnDateToString:calendar.currentPage]];
}
-(NSString*)turnDateToString:(NSDate*)date
{
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString*dateString=[dateFormatter stringFromDate:date];
    return dateString;
}
-(void)getCaloriesOfUsedInfoData:(NSString*)dateString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findCalorieRecordList"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"date":dateString} success:^(id responseObject){
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*caloriesOfUsedArr=objString[@"data"][@"data"];
        
        [_timeShaftTableView.timeInfoDataList removeAllObjects];
        _firstPageScrollView.contentSize=CGSizeMake(0, 585);
        _monthOfTotalCaloriesLabel.text=@"0.00";
        
        if(caloriesOfUsedArr.count>0)
        {
            _firstPageScrollView.contentSize=CGSizeMake(0, 585+caloriesOfUsedArr.count*50);

            NSString*monthOfTotalCalorie=objString[@"data"][@"totalCalorie"];
            _monthOfTotalCaloriesLabel.text=[NSString stringWithFormat:@"%.2f",([monthOfTotalCalorie floatValue])/1000];
            
            for (NSDictionary*caloriesOfUsedDict in caloriesOfUsedArr)
            {
                XXYTimeShartModel*mdoel=[[XXYTimeShartModel alloc]init];
                mdoel.calorieTime=caloriesOfUsedDict[@"strCreatedAt"];
                mdoel.calorieTotalnNum=[NSString stringWithFormat:@"%@",caloriesOfUsedDict[@"totalCalorie"]];
                [_timeShaftTableView.timeInfoDataList addObject:mdoel];
            }
        }
       [_timeShaftTableView reloadData];
    } failure:^(NSError *error) {
    }];
}
-(void)getCaloriesAttendanceData:(NSString*)dateString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findMarkRecord"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"date":dateString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        NSArray*dataArr=objString[@"data"];
        if(dataArr.count>0)
        {
            for (NSDictionary*dataInfo in dataArr)
            {
                NSString*dateString=dataInfo[@"strMarkAt"];
                NSDate*markDate=[dateFormatter dateFromString:dateString];
                [self.calendar selectDate:markDate];
            }
        }
        
            } failure:^(NSError *error) {
    }];
    
}

-(NSMutableArray*)comBoxDataList
{
    if(!_comBoxDataList)
    {
        _comBoxDataList=[NSMutableArray array];
    }
    return _comBoxDataList;
}
-(void)setUpFirstPageView
{
    _firstPageTitleBgView=[[UIView alloc]initWithFrame:CGRectMake(15, 15, MainScreenW-30, 415)];
    _firstPageTitleBgView.layer.cornerRadius=5;
    _firstPageTitleBgView.backgroundColor=[UIColor whiteColor];
    [_firstPageScrollView addSubview:_firstPageTitleBgView];
    
    NSArray*firstPageTitleArray=@[@"运动种类:",@"运动时间:",@"消耗的卡路里:"];
    for(int i=0;i<3;i++)
    {
        UILabel*firstPageTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 15+40*i, _firstPageTitleBgView.frame.size.width/2-40, 25)];
        firstPageTitleLabel.textColor=[UIColor whiteColor];
        firstPageTitleLabel.layer.cornerRadius=5;
        firstPageTitleLabel.layer.masksToBounds=YES;
        firstPageTitleLabel.font=[UIFont systemFontOfSize:14];
        firstPageTitleLabel.textAlignment=NSTextAlignmentCenter;
        firstPageTitleLabel.text=firstPageTitleArray[i];
        firstPageTitleLabel.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
        [_firstPageTitleBgView addSubview:firstPageTitleLabel];
    }
    
    [self getNewData];
    
    UIButton*selTimeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    selTimeBtn.frame=CGRectMake(MainScreenW-((MainScreenW-110)/2)-30-15, 70-15, (MainScreenW-110)/2, 25);
    [selTimeBtn addTarget:self action:@selector(selTimeBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    [_firstPageTitleBgView addSubview:selTimeBtn];
    
    NSArray*itemTimeNameArr=@[@"00",@"时",@"00",@"分"];
    
    for(int i=0;i<4;i++)
    {
        UILabel*itemTimeLabel=[[UILabel alloc]initWithFrame:CGRectMake(selTimeBtn.frame.size.width/4*i, 0, selTimeBtn.frame.size.width/4, 25)];
        itemTimeLabel.text=itemTimeNameArr[i];
        itemTimeLabel.tag=50+i;
        itemTimeLabel.font=[UIFont systemFontOfSize:14];
        itemTimeLabel.textAlignment=NSTextAlignmentCenter;
        [selTimeBtn addSubview:itemTimeLabel];
        if(i==0||i==2)
        {
            itemTimeLabel.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
            itemTimeLabel.textColor=[UIColor whiteColor];
            itemTimeLabel.layer.masksToBounds=YES;
            itemTimeLabel.layer.cornerRadius=5;
        }
        else
        {
            itemTimeLabel.textColor=[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0];
            itemTimeLabel.backgroundColor=[UIColor clearColor];
        }
    }
    
    _totalCalorieLabel=[[UILabel alloc]initWithFrame:CGRectMake(MainScreenW-((MainScreenW-110)/2)-30-15, 70+25, (MainScreenW-110)/2, 25)];
    _totalCalorieLabel.textAlignment=NSTextAlignmentCenter;
    _totalCalorieLabel.textColor=[UIColor whiteColor];
    _totalCalorieLabel.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    _totalCalorieLabel.font=[UIFont systemFontOfSize:14];
    _totalCalorieLabel.layer.cornerRadius=5;
    _totalCalorieLabel.layer.masksToBounds=YES;
    _totalCalorieLabel.text=@"0卡";
    [_firstPageTitleBgView addSubview:_totalCalorieLabel];
    
    NSArray*btnTitleArr=@[@"马上打卡",@"计入日记"];
    for(int i=0;i<2;i++)
    {
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        btn.layer.cornerRadius=5;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0]];
        btn.tag=150+i;
        btn.titleLabel.font=[UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(punchAndDiaryBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame=CGRectMake(15+((MainScreenW-110)/2+50)*i, 390-13, (MainScreenW-110)/2, 25);
        [_firstPageTitleBgView addSubview:btn];
        if(i==0)
        {
            _immediatelyPunchBtn=btn;
        }
        else
        {
            _writeToDiaryBtn=btn;
        }
        
    }
    _iconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(15,445, 40, 40)];
    _iconImageView.image=[UIImage imageNamed:@"calorie_diary_icon"];
    [_firstPageScrollView addSubview:_iconImageView];
    
    UILabel*imageTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(70,445, 80, 40)];
    imageTitleLabel.text=@"消卡日记";
    imageTitleLabel.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    imageTitleLabel.font=[UIFont systemFontOfSize:12];
    [_firstPageScrollView addSubview:imageTitleLabel];

    
    NSArray*totalNumArray=@[@"本月累计:",@"00",@"大卡"];
    for(int i=0;i<3;i++)
    {
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
        CGSize size=[@"大卡" sizeWithAttributes:attrs];
        UILabel*totalNumLabel=[[UILabel alloc]init];
        totalNumLabel.text=totalNumArray[i];
        totalNumLabel.font=[UIFont systemFontOfSize:12];
        [_firstPageScrollView addSubview:totalNumLabel];
        if(i==1)
        {
            totalNumLabel.textAlignment=NSTextAlignmentCenter;
            totalNumLabel.frame=CGRectMake(MainScreenW-15-size.width-40,445, 40, 40);
            totalNumLabel.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
            _monthOfTotalCaloriesLabel=totalNumLabel;
        }
        else
        {
            totalNumLabel.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
            if(i==0)
            {
                totalNumLabel.frame=CGRectMake(MainScreenW-15-size.width-40-80,445, 80, 40);
                totalNumLabel.textAlignment=NSTextAlignmentRight;
  
            }
            else
            {
              totalNumLabel.frame=CGRectMake(MainScreenW-15-size.width,445,size.width, 40);
            }
        }

    }
    [self  setUpFirstPageTableView];
}
-(void)setUpFirstPageTableView
{
    _timeShaftTableView= [XXYTimeShaftTableView contentTableView];
    _timeShaftTableView.frame=CGRectMake(0, 500-15, MainScreenW, MainScreenH);
    _timeShaftTableView.backgroundColor=[UIColor clearColor];
    _timeShaftTableView.bounces=NO;
    _timeShaftTableView.showsVerticalScrollIndicator=NO;
    [_firstPageScrollView addSubview:_timeShaftTableView];
}
-(void)calorieSaveMark
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/saveMark"];
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self setUpAlertController:@"今天打卡成功!"];
            [self.calendar selectDate:[NSDate date]];
        }
        else if([objString[@"message"] hasPrefix:@"当天签到一次"]&&[codeString isEqualToString:@"8002"])
        {
            [self setUpAlertController:@"今天已经打卡啦~"];
        }
        else
        {
            [self setUpAlertController:@"打卡失败!"];
        }
    } failure:^(NSError *error) {
        [self setUpAlertController:@"打卡失败!"];
    }];
}
-(void)writeToDiary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/sendRecord"];
    
   // NSLog(@"totalCalorie=%i\ntotalMinute=%i\ncalorieItemId=%@",_totalCalorie,_totalMinute,_calorieItemId);
    
    if(!_totalCalorie||!_totalMinute)
    {
        [self setUpAlertController:@"今天没有消耗卡路里,不能计入日记哦!"];
    }
    else if(_totalMinute>180)
    {
        [self setUpAlertController:@"你运动过度了,请重新选择时间!"];
    }
    else if(_calorieItemId)
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"totalCalorie":[NSNumber numberWithInteger:_totalCalorie],@"itemType":_calorieItemId,@"min":[NSNumber numberWithInteger:_totalMinute]} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self setUpAlertController:@"卡路里记录成功\n再接再厉!"];
            [self getCaloriesOfUsedInfoData:[self turnDateToString:[NSDate date]]];
        }
        else
        {
            [self setUpAlertController:@"计入日记失败!,稍后再试!"];
        }
    } failure:^(NSError *error) {
        [self setUpAlertController:@"计入日记失败!,稍后再试!"];
    }];
}
-(void)punchAndDiaryBtnCliked:(UIButton*)btn
{
    switch (btn.tag) {
        case 150:
        {
            [self calorieSaveMark];
        }
            break;
        case 151:
        {
            [self writeToDiary];
        }
            break;
        default:
            break;
    }
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
    
    
   // UIAlertAction *action = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        
//           }];
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
-(void)selTimeBtnCliked:(UIButton*)btn
{
    for (UIView*view in [_datePickerView subviews])
    {
        [view removeFromSuperview];
    }
    [_datePickerView removeFromSuperview];
    _datePickerView=[[UIView alloc]initWithFrame:CGRectMake(0, MainScreenH-256, MainScreenW, 256)];
    _datePickerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_datePickerView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 40)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=@"请选择运动时长";
    label.textColor=[UIColor colorWithRed:146.0/255 green:146.0/255 blue:146.0/255 alpha:1.0];
    label.font=[UIFont systemFontOfSize:17];
    [_datePickerView addSubview:label];
    
    _selTimeComfirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    [_selTimeComfirmBtn setBackgroundColor:[UIColor whiteColor]];
    _selTimeComfirmBtn.frame=CGRectMake(MainScreenW-60, 0, 60, 40);
    [_selTimeComfirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_selTimeComfirmBtn setTitleColor:[UIColor colorWithRed:0.0/255 green:150.0/255 blue:248.0/255 alpha:1.0] forState:UIControlStateNormal];
    _selTimeComfirmBtn.titleLabel.font=[UIFont systemFontOfSize:18];
    [_selTimeComfirmBtn addTarget:self action:@selector(selTimeComfirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_datePickerView addSubview:_selTimeComfirmBtn];
    
    _datepicker = [[UIDatePicker alloc] init];
    _datepicker.backgroundColor=[UIColor colorWithRed:206.0/255 green:213.0/255 blue:218.0/255 alpha:1.0];
    _datepicker.datePickerMode = UIDatePickerModeCountDownTimer;
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-cn"];
    _datepicker.locale=cnLocale;
    _datepicker.frame = CGRectMake(0, MainScreenH, MainScreenW, 216);
   
    [_datePickerView addSubview:_datepicker];
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0,40, MainScreenW, 216);
    }];
    _datepicker.countDownDuration=60;
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self writeToTaleCaloriesAndTime:_datepicker.date];
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
//    NSLog(@"sender=%@",sender);
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *date = datePicker.date;
    [self writeToTaleCaloriesAndTime:date];
}
-(void)writeToTaleCaloriesAndTime:(NSDate*)date
{
    
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"HH:mm"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    NSArray*timeTitleArr=[dateStr componentsSeparatedByString:@":"];
    
    if(timeTitleArr.count>=2)
    {
        UILabel*countHourLabel=[self.view viewWithTag:50];
        countHourLabel.text=timeTitleArr[0];
        UILabel*countMinuteLabel=[self.view viewWithTag:52];
        countMinuteLabel.text=timeTitleArr[1];
    }
    
    NSInteger hourValue=[timeTitleArr[0] integerValue];
    NSInteger minuteValue=[timeTitleArr[1] integerValue];
    _totalMinute=hourValue*60+minuteValue;
    _totalCalorie=_totalMinute*[_calorieUnit integerValue];
    _totalCalorieLabel.text=[NSString stringWithFormat:@"%i卡",_totalCalorie];

}
-(void)getNewData
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findAllCalorieItems"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSMutableArray*dataArray=[defaults objectForKey:@"calorieItemsList"];
    
        if(dataArray.count<=0)
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray*array=[NSMutableArray array];
            NSArray*dataArray=objString[@"data"];
            for (NSDictionary*dict in dataArray)
            {
                [array addObject:dict];
            }
            if(array.count>0)
            {
                NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
                [defaultss setObject:array forKey:@"calorieItemsList"];
               [self setUpcomBoxView:array];
            }
        } failure:^(NSError *error) {
        }];
    else
    {
        [self setUpcomBoxView:dataArray];
    }
}
-(void)setUpcomBoxView:(NSMutableArray*)array
{
    _comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(MainScreenW-((MainScreenW-110)/2)-30-15, 15, (MainScreenW-110)/2, 25)];
    _comBox.backgroundColor = [UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
   // _comBox.arrowImgName = @"navigationbar_arrow_down";
    NSMutableArray*titleArray=[NSMutableArray array];
    for (NSDictionary*dict in array) {
        NSString*titleName=dict[@"name"];
        [titleArray addObject:titleName];
    }
    _comBox.titlesList = titleArray;
    _comBox.delegate = self;
    _comBox.titleLabelColor=[UIColor whiteColor];
    _comBox.supView = _firstPageTitleBgView;
    _comBox.layer.cornerRadius=5;
    [_comBox defaultSettings];
    _comBox.tag = 100;
    [_firstPageTitleBgView addSubview:_comBox];
}
#pragma mark -LMComBoxViewDelegate
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
    //NSLog(@"title=%@",_combox.titlesList[index]);
    if(self.comBoxDataList)
    {
        NSDictionary*itemInfoDict=self.comBoxDataList[index];
        _calorieItemId=itemInfoDict[@"id"];
        _calorieUnit=itemInfoDict[@"calorieMin"];
        _totalCalorie=_totalMinute*[_calorieUnit integerValue];
        _totalCalorieLabel.text=[NSString stringWithFormat:@"%i卡",_totalCalorie];
    }
}
-(void)setUpNavigationItemView
{
    UIView*titleBtnBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    titleBtnBgView.backgroundColor=[UIColor whiteColor];

    UIBezierPath *titleBtnBgViewshadowPath = [UIBezierPath bezierPathWithRect:titleBtnBgView.bounds];
    titleBtnBgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    titleBtnBgView.layer.shadowOffset = CGSizeMake(-0.0f, 0.5f);
    titleBtnBgView.layer.shadowOpacity = 0.1f;
    titleBtnBgView.layer.shadowPath = titleBtnBgViewshadowPath.CGPath;
    [self.view addSubview:titleBtnBgView];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 50+1, MainScreenW, MainScreenH-64-51)];
    _scrollView.backgroundColor=[UIColor whiteColor];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.bounces=NO;
    _scrollView.delegate=self;
    _scrollView.pagingEnabled=YES;
    _scrollView.contentSize=CGSizeMake(MainScreenW*2, 0);
    [self.view addSubview:_scrollView];
    
    NSArray*navBtnTitle=@[@"我的卡路里",@"排行榜"];
    for (int i=0;i<2; i++)
    {
        UIButton*navBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        navBtn.frame=CGRectMake((MainScreenW/2)*i, 0, MainScreenW/2, 50);
        [navBtn setBackgroundColor:[UIColor whiteColor]];
        navBtn.tag=100+i;
        navBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [navBtn setTitle:navBtnTitle[i] forState:UIControlStateNormal];
        [navBtn addTarget:self action:@selector(navBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [titleBtnBgView addSubview:navBtn];
        
        UIScrollView*pageScrollow=[[UIScrollView alloc]init];
        pageScrollow.bounces=YES;
        pageScrollow.showsVerticalScrollIndicator=NO;
        
        if(i==0)
        {
            [navBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            pageScrollow.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
            pageScrollow.contentSize=CGSizeMake(0, 585);
            pageScrollow.frame=CGRectMake(MainScreenW*i, 0,MainScreenW,_scrollView.frame.size.height-50);
            _firstPageScrollView=pageScrollow;
            _burnCaloriesBtn=navBtn;
        }
        else
        {
            [navBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
            pageScrollow.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
            pageScrollow.frame=CGRectMake(MainScreenW*i, 0,MainScreenW,_scrollView.frame.size.height);
            
            if(_scrollView.frame.size.height<520)
            {
                pageScrollow.contentSize=CGSizeMake(0, 520);
            }
            else
            {
               pageScrollow.contentSize=CGSizeMake(0, _scrollView.frame.size.height+5);
            }
            _secondPageScrollView=pageScrollow;
            _chartsBtn=navBtn;
        }
        [_scrollView addSubview:pageScrollow];
    }
    
    NSArray*shareLabelTitle=@[@"分享",@"捐卡"];
    
    UIView*shareAndAbandonBgView=[[UIView alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height-50, MainScreenW, 50)];
    shareAndAbandonBgView.backgroundColor=[UIColor whiteColor];
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:shareAndAbandonBgView.bounds];
    shareAndAbandonBgView.layer.shadowColor = [UIColor blackColor].CGColor;
    shareAndAbandonBgView.layer.shadowOffset = CGSizeMake(-0.0f, -0.5f);
    shareAndAbandonBgView.layer.shadowOpacity = 0.2f;
    shareAndAbandonBgView.layer.shadowPath = shadowPath.CGPath;
    [_scrollView addSubview:shareAndAbandonBgView];
    
    for(int i=0;i<2;i++)
    {
        UIButton*shareAndAbandonBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        shareAndAbandonBtn.frame=CGRectMake((MainScreenW/2)*i, 0, MainScreenW/2, 50);
        [shareAndAbandonBtn setBackgroundColor:[UIColor clearColor]];
        shareAndAbandonBtn.tag=200+i;
        [shareAndAbandonBtn addTarget:self action:@selector(shareAndAbandonBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [shareAndAbandonBgView addSubview:shareAndAbandonBtn];
        
        UIView*shareLineView=[[UIView alloc]initWithFrame:CGRectMake(MainScreenW/2-0.5, _scrollView.frame.size.height-45, 1, 40)];
        shareLineView.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
        [_scrollView addSubview:shareLineView];
        
        UIImageView*shareImageView=[[UIImageView alloc]initWithFrame:CGRectMake((MainScreenW/2-30-15-40)/2, 12.5, 25, 25)];
        
        [shareAndAbandonBtn addSubview:shareImageView];
        
        UILabel*sharelabel=[[UILabel alloc]initWithFrame:CGRectMake((MainScreenW/2-30-15-40)/2+30+15, 10, 40, 30)];
        sharelabel.text=shareLabelTitle[i];
        sharelabel.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
        sharelabel.font=[UIFont systemFontOfSize:15];
        [shareAndAbandonBtn addSubview:sharelabel];
        
        if(i==0)
        {
            shareImageView.image=[UIImage imageNamed:@"calorie_share"];
            _shareCalorieBtn=shareAndAbandonBtn;
        }
        else
        {
            shareImageView.image=[UIImage imageNamed:@"calorie_card"];
            _abandonCalorieBtn=shareAndAbandonBtn;
        }
    }
}
-(void)shareAndAbandonBtnCliked:(UIButton*)btn
{
    switch (btn.tag) {
        case 200:
        {
            [self shareBtnCliked];
           
        }
            break;
        case 201:
        {
            XXYAbandonCaloriesController*abandonCon=[[XXYAbandonCaloriesController alloc]init];
            [self.navigationController pushViewControllerWithAnimation:abandonCon];
        }
            break;
        default:
            break;
    }
}

-(void)shareBtnCliked
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/calorie/findTodayTotalCal"];
    //NSLog(@"sid=%@",userSidString);
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSNumber*totalCalories=objString[@"data"];
        
        if([totalCalories floatValue]>0)
        {
            XXYPublishDynamicController*publishCon=[[XXYPublishDynamicController alloc]init];
            publishCon.shareIndex=2;
            publishCon.reloadDelegate=self;
            publishCon.shareString=[NSString stringWithFormat:@"我今天消耗了 %.1f 大卡,快来和我一起运动吧!",[totalCalories floatValue]/1000 ];
            [self presentViewController:publishCon animated:YES completion:nil];
        }
        else
        {
            [self setUpAlertController:@"没有消耗卡路里,不能分享哦"];
        }
        
    } failure:^(NSError *error) {
        [self setUpAlertController:@"没有消耗卡路里,不能分享哦"];
    }];

    
}
-(void)reloadNewDataOfPublished
{
    [self setUpAlertController:@"分享成功"];
}
#pragma mark - UIScrollView delegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / MainScreenW;
    switch (index)
    {
        case 0:
        {
           [_burnCaloriesBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_chartsBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [_chartsBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_burnCaloriesBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        NSInteger index = scrollView.contentOffset.x / MainScreenW;
        switch (index)
        {
            case 0:
            {
                [_burnCaloriesBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                [_chartsBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                [_chartsBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                [_burnCaloriesBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
    }
}
-(void)navBtnCliked:(UIButton*)btn
{
    switch (btn.tag) {
        case 100:
        {
            [UIView animateWithDuration:0.2   animations:^{
                _scrollView.contentOffset = CGPointMake(0, 0);
            }];
            [_burnCaloriesBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_chartsBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 101:
        {
            [UIView animateWithDuration:0.2   animations:^{
                _scrollView.contentOffset = CGPointMake(MainScreenW, 0);
            }];
            [_chartsBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_burnCaloriesBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
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

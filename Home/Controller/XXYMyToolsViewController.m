#import "XXYMyToolsViewController.h"
#import"XXYBackButton.h"
#import"LMComBoxView.h"
#import "LMContainsLMComboxScrollView.h"
#import "BSHttpRequest.h"
#import "YXScrollMenu.h"
#import "XXYTermScoreModel.h"
#import "JHChartHeader.h"
@interface XXYMyToolsViewController ()<LMComBoxViewDelegate,YXScrollMenuDelegate, UIScrollViewDelegate>
@property (nonatomic, weak) YXScrollMenu *menu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger previousIndex;
@property (nonatomic, strong) LMComBoxView *comBox;
@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,assign)CGFloat btnsBgViewHight;
@property(nonatomic,strong)JHLineChart *lineChart;

@property(nonatomic,copy)NSString *currentTermString;


@end
@implementation XXYMyToolsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"成绩";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    [self setUpSubViews];
    [self getData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.dataList=[defaults objectForKey:@"studentTeamList"];
    
    if(self.dataList.count>0)
    {
        _currentTermString=self.dataList[0];
        for(int i=3;i>0;i--)
        {
            [self loadNewData:_currentTermString andType:i];
            
        }
    }
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
    }
    return _dataList;
}
-(void)loadNewData:(NSString*)termString andType:(int)type
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/quiz/score/summary"];
    NSString*studyYear=@"";
    NSString*studyTerm=@"";
    if(termString.length>6)
    {
        studyYear=[termString substringWithRange:NSMakeRange(0, 4)];
        studyTerm=[termString substringWithRange:NSMakeRange(6, 1)];
    }
    
    //NSLog(@"year=%@,term=%@,type=%i",studyYear,studyTerm,type);
    
    if(studyYear&&studyTerm&&type)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"studyYear":studyYear,@"studyTerm":studyTerm,@"category":[NSNumber numberWithInt:type]} success:^(id responseObject){
        
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*scoreArray=objString[@"data"][@"quizScores"];
        
        if(scoreArray.count>0)
        {
            NSMutableArray*modelArray=[NSMutableArray array];
            
            for (NSDictionary*dict in scoreArray)
            {
                XXYTermScoreModel*model=[[XXYTermScoreModel alloc]init];
                model.score=dict[@"score"];
                model.courseId=[NSString stringWithFormat:@"%@",dict[@"course"][@"id"]];
                model.courseName=dict[@"course"][@"name"];
               // NSLog(@"%i=%@",type,model.score);
                
                [modelArray addObject:model];
            }
            [self setUpScoreOfSubViews:[NSMutableArray arrayWithArray:modelArray] AndType:type];
        }
        else
        {
            [self setUpNoScoreOfSubViews:type];
        }
           } failure:^(NSError *error) {
               
               [self setUpNoScoreOfSubViews:type];
    }];
}
-(void)setUpNoScoreOfSubViews:(int)type
{
    CGFloat startingPointPosition=_scrollView.frame.size.width*(3-type);
    //CGRectMake(15, 110, MainScreenW-30, MainScreenH-110-64)];

    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(startingPointPosition, 0, MainScreenW-30, MainScreenH-64-110)];
    view.backgroundColor=[UIColor whiteColor];
    view.tag=100;
    [_scrollView addSubview:view];
    
    //320*260
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:CGRectMake(70, 50, MainScreenW-170,(MainScreenW-170)*13/16)];
    imageView.tag=101;
    imageView.image=[UIImage imageNamed:@"no-content"];
    [view addSubview:imageView];
    
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(50, (MainScreenW-170)*13/16+60, MainScreenW-130,50)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor grayColor];
    label.font=[UIFont systemFontOfSize:16];
    label.text=@"暂无考试成绩";
    label.tag=102;
    [view addSubview:label];
}
-(void)setUpScoreOfSubViews:(NSArray*)array AndType:(int)type
{
    CGFloat startingPointPosition=_scrollView.frame.size.width*(3-type);
    NSInteger scoreCount=array.count;
    NSInteger scoreH=scoreCount/4;
    
    NSInteger scoreRemainder=scoreCount%4;
    
    CGFloat scoreLength=(_scrollView.frame.size.width-25)/4;
    
    CGFloat totalScore=0;
    
    if(scoreRemainder)
    {
        scoreH=scoreH+1;
    }
    CGFloat bgViewLength=(scoreH+1)*5+scoreLength*scoreH;
    
    _btnsBgViewHight=bgViewLength;
    
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(startingPointPosition, 0, _scrollView.frame.size.width, 70)];
    view.backgroundColor=[UIColor whiteColor];
    [_scrollView addSubview:view];
    
    UIView*bgView=[[UIView alloc]init];
    bgView.frame=CGRectMake(startingPointPosition, 70, _scrollView.frame.size.width, bgViewLength);
    bgView.backgroundColor=[UIColor colorWithRed:217.0/255 green:218.0/255 blue:220.0/255 alpha:1.0];
    [_scrollView addSubview:bgView];
    
    for(int i=0;i<scoreCount;i++)
    {
        XXYTermScoreModel*model=array[i];
        
        totalScore=[model.score floatValue]+totalScore;
        
        UIButton*btn=[UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame=CGRectMake(5+(scoreLength+5)*(i%4), 5+(scoreLength+5)*(i/4), scoreLength, scoreLength);
        btn.backgroundColor=[UIColor whiteColor];
        [btn addTarget:self action:@selector(courseScoreClicked:) forControlEvents:UIControlEventTouchUpInside];
        //btn.tag/200-1
        btn.tag=type*200;
        [btn setTitle:model.courseId forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        
        [bgView addSubview:btn];
        
        for(int j=0;j<2;j++)
        {
            UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(0, (btn.frame.size.height*3/5-15)*j+8, btn.frame.size.width, btn.frame.size.height*3/5-btn.frame.size.height/5*j)];
            label.textAlignment=NSTextAlignmentCenter;
            [btn addSubview: label];
            if(j==0)
            {
                label.text=[NSString stringWithFormat:@"%.0f",[model.score floatValue]];
                label.font=[UIFont systemFontOfSize:25];
                label.textColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
            }
            else
            {
                label.text=model.courseName;
                label.font=[UIFont systemFontOfSize:14];
                label.textColor=[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
            }
        }
    }
    NSArray*labelTextArray=@[@"平均",@"总分"];
    for(int i=0;i<2;i++)
    {
        for(int j=0;j<2;j++)
        {
            UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width/2*i+startingPointPosition, j*40, _scrollView.frame.size.width/2,50-20*j)];
            label.backgroundColor=[UIColor clearColor];
            label.textAlignment=NSTextAlignmentCenter;
            [_scrollView addSubview:label];
            if(j==1)
            {
                label.tag=100+i;
                label.text=labelTextArray[i];
                label.font=[UIFont systemFontOfSize:13];
                label.textColor=[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
            }
            else
            {
                label.tag=50+i;
                if(i==0)
                label.text=[NSString stringWithFormat:@"%.2f",totalScore/scoreCount];
                else
                    label.text=[NSString stringWithFormat:@"%.1f",totalScore];
                label.font=[UIFont systemFontOfSize:28];
                label.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
            }
        }
    }
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width/2-1+startingPointPosition, 10, 1,50)];
    label.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    [_scrollView addSubview:label];
}
-(void)courseScoreClicked:(UIButton*)btn
{
    //[self showFirstQuardrant:_btnsBgViewHight+70+15 AndType:3-btn.tag/200];
    
    [self getOneCourseScoreTrendInTheYear:btn.currentTitle AndType:3-btn.tag/200];
}
-(void)getOneCourseScoreTrendInTheYear:(NSString*)courseId AndType:(int)type
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*termString=_currentTermString;
    
    NSString*studyYear=@"";
    
    if(termString.length>6)
    {
        studyYear=[termString substringWithRange:NSMakeRange(0, 4)];
    }
    
   // NSLog(@"11==%@,22==%@",studyYear,courseId);
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/course/score/trends"];
    if(courseId&&studyYear)
        
       // NSLog(@"%@",userSidString);
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"courseId":courseId,@"studyYear":studyYear} success:^(id responseObject){
        
       // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //{"code":0,"message":"success","data":[]}
        //{"score":99.0,"quiz":{"id":7,"name":"2016秋季期末考试","enrolYear":2016,"startTime":"Dec 10, 2016 12:00:00 AM","endTime":"Dec 13, 2016 12:00:00 AM","category":1,"studyYear":2016,"studyTerm":1,"studyMonth":0,"description":"期末语文考试全本内容","daysAfterNow":-11}}
        NSMutableArray*xArray=[NSMutableArray array];
        NSMutableArray*valueArray=[NSMutableArray array];
        
        NSArray*dataArray=objString[@"data"];
        
        for (NSDictionary*dict in dataArray)
        {
            NSNumber*yValue=dict[@"score"];
            NSNumber*xValue=dict[@"quiz"][@"studyMonth"];
            
            [xArray addObject:xValue];
            [valueArray addObject:yValue];
        }
        
        if(xArray.count>0&&valueArray.count>0)
        
        [self showFirstQuardrant:_btnsBgViewHight+70+15 AndType:type AndXarray:xArray AndYArray:valueArray];
        
           } failure:^(NSError *error) {
    }];

}
//第一象限折线图
- (void)showFirstQuardrant:(CGFloat)hight AndType:(int)type AndXarray:(NSArray*)xArray AndYArray:(NSArray*)valueArray
{
    
    for (UIView*view in [_lineChart subviews]) {
        [view removeFromSuperview];
    }
    [_lineChart removeFromSuperview];
    
    /*     Create object        */
    _lineChart = [[JHLineChart alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width*type, hight, _scrollView.frame.size.width, _scrollView.frame.size.height-hight-20) andLineChartType:JHChartLineValueNotForEveryX];
    
    for (int i=0;i<2;i++)
    {
        UILabel*label=[[UILabel alloc]init];
        label.font=[UIFont systemFontOfSize:7];
        if(i==0)
        {
            label.frame=CGRectMake(0, 0, 30, 20);
            label.text=@" 分数";
        }
        else
        {
            label.frame=CGRectMake(_lineChart.frame.size.width-30, _lineChart.frame.size.height-10, 30, 10);
            label.textAlignment=NSTextAlignmentRight;
            label.text=@"月份";
        }
        [_lineChart addSubview:label];
    }
    _lineChart.backgroundColor=[UIColor whiteColor];
    /* The scale value of the X axis can be passed into the NSString or NSNumber type and the data structure changes with the change of the line chart type. The details look at the document or other quadrant X axis data source sample.*/
    NSArray*array=@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
    
    _lineChart.xLineDataArr = array;
    
    NSMutableArray*dataArray=[NSMutableArray array];
    
    for (int j=0;j<13;j++)
    {
        NSNumber*valueString=@0;
        
        for (int i=0;i<xArray.count;i++)
        {
            NSNumber*string=xArray[i];
            
            if([string intValue]==j)
            {
                valueString=valueArray[i];
            }
            
        }
        [dataArray addObject:valueString];
    }
    
    //NSLog(@"array=%@",dataArray);
    
    /* The different types of the broken line chart, according to the quadrant division, different quadrant correspond to different X axis scale data source and different value data source. */
    
    _lineChart.lineChartQuadrantType = JHLineChartQuadrantTypeFirstQuardrant;
    
    _lineChart.valueArr = @[dataArray];
   // _lineChart.valueArr = dataArray;
    /* Line Chart colors */
    _lineChart.valueLineColorArr =@[ [UIColor purpleColor], [UIColor brownColor]];
    /* Colors for every line chart*/
    _lineChart.pointColorArr = @[[UIColor orangeColor],[UIColor yellowColor]];
    /* color for XY axis */
    _lineChart.xAndYLineColor = [UIColor blackColor];
    /* XY axis scale color */
    _lineChart.xAndYNumberColor = [UIColor blackColor];
    /* Dotted line color of the coordinate point */
    _lineChart.positionLineColorArr = @[[UIColor blueColor],[UIColor greenColor]];
    /*        Set whether to fill the content, the default is False         */
    _lineChart.contentFill = YES;
    /*        Set whether the curve path         */
    _lineChart.pathCurve = YES;
    /*        Set fill color array         */
    _lineChart.contentFillColorArr = @[[UIColor colorWithRed:0.500 green:0.000 blue:0.500 alpha:0.468],[UIColor colorWithRed:0.500 green:0.214 blue:0.098 alpha:0.468]];
    [_scrollView addSubview:_lineChart];
    /*       Start animation        */
    [_lineChart showAnimation];
}

-(void)setUpSubViews
{
    YXScrollMenu *menu = [[YXScrollMenu alloc] initWithFrame:CGRectMake(15,60,MainScreenW-30, 40)];
    menu.backgroundColor=[UIColor purpleColor];
    menu.titleArray = @[@"月考", @"期中", @"期末"];
    menu.cellWidth =(MainScreenW-30)/3;
    menu.delegate = self;
    menu.isHiddenSeparator = YES;
    menu.selectedTextColor=[UIColor whiteColor];
    menu.normalBackgroundColor=[UIColor whiteColor];
    menu.selectedBackgroundColor=[UIColor colorWithRed:28.0/255 green:207.0/255 blue:200.0/255 alpha:1.0];
    [self.view addSubview:menu];
    
    _menu = menu;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 110, MainScreenW-30, MainScreenH-110-64)];
    //回弹
    scrollView.bounces=NO;
    //分页
    scrollView.pagingEnabled = YES;
    //横向滚动条
    scrollView.showsHorizontalScrollIndicator=NO;
    
    scrollView.backgroundColor=[UIColor clearColor];
    
    scrollView.contentSize = CGSizeMake(menu.titleArray.count * (MainScreenW-30), 0);
    scrollView.delegate = self;
    scrollView.scrollEnabled=YES;
    
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
}
#pragma mark - YXScrollMenu delgate
- (void)scrollMenu:(YXScrollMenu *)scrollMenu selectedIndex:(NSInteger)selectedIndex
{
    [UIView animateWithDuration:0.2 * ABS(selectedIndex - _previousIndex)   animations:^{
        _scrollView.contentOffset = CGPointMake(selectedIndex * (MainScreenW-30), 0);
    }];
    _previousIndex = selectedIndex;
}
#pragma mark - UIScrollView delegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    _menu.currentIndex = scrollView.contentOffset.x / (MainScreenW-30);
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _menu.currentIndex = scrollView.contentOffset.x / (MainScreenW-30);
    }
}
-(void)setUpBgScrollView:(NSMutableArray*)array
{
    _comBox = [[LMComBoxView alloc]initWithFrame:CGRectMake(50, 10, MainScreenW-100, 40)];
    _comBox.backgroundColor = [UIColor clearColor];
    _comBox.arrowImgName = @"down_dark0.png";
    _comBox.titlesList = array;
    _dataList=array;
    _comBox.delegate = self;
    _comBox.supView = self.view;
    [_comBox defaultSettings];
    _comBox.tag = 100;
    [self.view addSubview:_comBox];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_comBox.isOpen)
    {
        [_comBox tapAction];
    }
}
-(void)getData
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/term/list"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSMutableArray*dataArray=[defaults objectForKey:@"studentTeamList"];
    
    if(dataArray.count<=0)
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSMutableArray*array=[NSMutableArray array];
        
        NSArray*dataArray=objString[@"data"];
        
        for (NSDictionary*dict in dataArray)
        {
            NSString*teamString=[NSString stringWithFormat:@"%@年第%@学期",dict[@"studyYear"],dict[@"studyTerm"]];
            [array addObject:teamString];
        }
        if(array.count>0)
        {
            
            NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
            [defaultss setObject:array forKey:@"studentTeamList"];
            
            [self setUpBgScrollView:array];
        }
    } failure:^(NSError *error) {
    }];
    else
    {
       [self setUpBgScrollView:dataArray];
    }
}
#pragma mark -LMComBoxViewDelegate
-(void)selectAtIndex:(int)index inCombox:(LMComBoxView *)_combox
{
    //NSLog(@"title=%@",_combox.titlesList[index]);
    
    for (UIView*view in [_scrollView subviews])
    {
        [view removeFromSuperview];
    }
    _currentTermString=_combox.titlesList[index];
    for(int i=3;i>0;i--)
    {
        [self loadNewData:_currentTermString andType:i];
    }
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

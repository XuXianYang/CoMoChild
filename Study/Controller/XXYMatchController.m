#import "XXYMatchController.h"
#import"XXYBackButton.h"
#import "BSHttpRequest.h"
#import "XXYMatchListModel.h"
#import "XXYMatchListCell.h"
#import "MJRefresh.h"
#import "XXYMatchDetailController.h"
#import "XXYMatchMessageController.h"
#import "XXYMatchTypeInfoController.h"
#import "XXYMyPublishMatchController.h"

#define matchBtnHight (MainScreenH-164.0)/13
@interface XXYMatchController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate,XXYSendMatchTypeInfoDelegate,XXYMatchListDelegate>
{
    NSInteger _currentPage;
    UIDatePicker *_datepicker;
}
@property(nonatomic,retain)NSMutableArray*dataCacheArray;

@property(nonatomic,retain)NSMutableArray*dataList;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)UIScrollView*scrollView;
@property(nonatomic,strong)UIView*firstPageTitleBgView;
@property(nonatomic,strong)UIButton*ballBtn;
@property(nonatomic,strong)UIButton*matchBtn;

@property(nonatomic,strong)UIButton*matchTypeBtn;
@property(nonatomic,strong)UIButton*matchTimeBtn;
@property(nonatomic,strong)UIButton*matchPublishBtn;
@property(nonatomic,strong)UITextField*matchPeoTextField;
@property(nonatomic,strong)UITextView*matchPlaceTextView;
@property(nonatomic,strong)UITextView*matchNoteTextView;

@property(nonatomic,strong)UILabel*matchPlacePlaceHoder;
@property(nonatomic,strong)UILabel*matchNotePlaceHoder;
@property(nonatomic,retain)NSDictionary*matchTypeInfoDict;

@property(nonatomic,strong)UIButton*selTimeComfirmBtn;
@property(nonatomic,strong)UIView*datePickerView;
@property(nonatomic,copy)NSString*selDateString;

@property(nonatomic,strong)UIImageView*imageView;

@end

@implementation XXYMatchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"约战";
    
    _currentPage=1;
    
    
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton*messageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    messageBtn.frame=CGRectMake(0, 0, 30, 30);
    [messageBtn setImage:[UIImage imageNamed:@"match_message"] forState:UIControlStateNormal];
    [messageBtn addTarget:self action:@selector(messageBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:messageBtn];

    [self setUpNavigationItemView];
    
    [self setUpTableView];
    [self addRefreshLoadMore];
    
    [self setUpPublishMatchView];
}
-(void)messageBtnCliked:(UIButton*)btn
{
    XXYMyPublishMatchController*matchMesCon=[[XXYMyPublishMatchController alloc]init];
    [self.navigationController pushViewController:matchMesCon animated:YES];
}
//添加刷新加载更多
- (void)addRefreshLoadMore
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    [header beginRefreshing];
    
    self.tableView.mj_header = header;
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    self.tableView.mj_footer.automaticallyHidden = YES;

}
-(void)loadMoreData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
//    NSLog(@"_currentPage=%i",_currentPage);
 
    NSNumber *page = [NSNumber numberWithInteger:_currentPage];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/listMatch"];
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString,@"pageNum":page,@"pageSize":@10} success:^(id responseObject){
        [self.tableView.mj_footer endRefreshing];
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray*dataArr=objString[@"data"];
        
        if(dataArr.count>0)
        {
            _currentPage=_currentPage+1;
            [self.dataCacheArray addObjectsFromArray:dataArr];
            [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"matchListCache" WithPath:@"matchList.plist"];
        }
        else
        {
            [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        }
        for (NSDictionary*dict in dataArr)
        {
            XXYMatchListModel*model=[[XXYMatchListModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
        [SVProgressHUD showImage:[UIImage imageNamed:loadMoreOfNonePic] status:@"已经到底了~"];
        [self.tableView.mj_footer endRefreshing];
    }];
}
-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/listMatch"];
    _currentPage=2;
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        // NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        [self.tableView.mj_header endRefreshing];
        //先清空数据源
        [self.dataList removeAllObjects];
        [self.dataCacheArray removeAllObjects];
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSArray*array=objString[@"data"];
        
        if(array.count<1)
        {
            [self setUpNoMessageView];
        }
        else
        {
            [_imageView removeFromSuperview];
        }

        self.dataCacheArray=[NSMutableArray arrayWithArray:array];
        
        [BSHttpRequest archiverObject:self.dataCacheArray ByKey:@"matchListCache" WithPath:@"matchList.plist"];
        
        for (NSDictionary*dict in array)
        {
            XXYMatchListModel*model=[[XXYMatchListModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
        NSArray*array =[BSHttpRequest unarchiverObjectByKey:@"matchListCache" WithPath:@"matchList.plist"];
        for (NSDictionary*dict in array)
        {
            XXYMatchListModel*model=[[XXYMatchListModel alloc]initWithDictionary:dict error:nil];
            [self.dataList addObject:model];
        }
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    }];
}
-(void)setUpNoMessageView
{
    [_imageView removeFromSuperview];
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(50, MainScreenH/2-64-(MainScreenW-100)/2, MainScreenW-100, MainScreenW-100)];
    _imageView.image=[UIImage imageNamed:@"msg_bg"];
    [self.tableView addSubview:_imageView];
}

-(void)setUpTableView
{
    [self.scrollView addSubview:self.tableView];
    self.tableView.backgroundColor=[UIColor clearColor];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator=NO;
    UIView*view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 5)];
    view.backgroundColor=[UIColor clearColor];
    self.tableView.tableHeaderView=view;
    [self.tableView registerNib:[UINib nibWithNibName:@"XXYMatchListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cellId"];
}
-(UITableView*)tableView
{
    if(!_tableView)
    {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,MainScreenW, MainScreenH-64-51) style:UITableViewStylePlain];
    }
    return _tableView;
}
-(NSMutableArray*)dataList
{
    if(!_dataList)
    {
        _dataList=[NSMutableArray array];
    }
    return _dataList;
}
-(NSMutableArray*)dataCacheArray
{
    if(!_dataCacheArray)
    {
        _dataCacheArray=[NSMutableArray array];
    }
    return _dataCacheArray;
}

#pragma mark -tableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.dataList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMatchListCell*cell=[tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.dataModel=self.dataList[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor=[UIColor clearColor];
    cell.backgroundColor=[UIColor clearColor];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXYMatchListModel*model=self.dataList[indexPath.row];
    
    XXYMatchDetailController*detailCon=[[XXYMatchDetailController alloc]init];
    detailCon.reloadDelegate=self;
    detailCon.getId=[NSString stringWithFormat:@"%@",model.uid];
    [self.navigationController pushViewControllerWithAnimation:detailCon];
}
-(void)reloadMatchListOfPublished
{
    [self loadNewData];
}
-(void)setUpPublishMatchView
{
    
    UIView*secondPageBgView=[[UIView alloc]initWithFrame:CGRectMake(MainScreenW, 0, MainScreenW, self.scrollView.frame.size.height)];
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapInfoBgView)];
    [secondPageBgView addGestureRecognizer:tapGesturRecognizer];

    secondPageBgView.backgroundColor=[UIColor clearColor];
    [self.scrollView addSubview:secondPageBgView];
    
    NSArray*btnTitle=@[@"  请选择约战类型",@"  请选择约战时间"];
    NSArray*textViewTitle=@[@"  请输入约战地点,50字以内",@"  请输入备注信息及联系方式哦,100字以内"];
    
    for(int i=0;i<2;i++)
    {
        UIButton*selBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        selBtn.frame=CGRectMake(15, 15+(matchBtnHight+10)*i, MainScreenW-30, matchBtnHight);
        selBtn.layer.cornerRadius=5;
        [selBtn setBackgroundColor:[UIColor whiteColor]];
        [selBtn setTitle:btnTitle[i] forState:UIControlStateNormal];
        [selBtn setTitleColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] forState:UIControlStateNormal];
        selBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        selBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
        selBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        
//        selBtn.layer.shadowOffset = CGSizeMake(1,1);
//        selBtn.layer.shadowOpacity = 0.1;
//        selBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        
        [selBtn addTarget:self action:@selector(selBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        selBtn.tag=300+i;
        
        UITextView*textView=[[UITextView alloc]initWithFrame:CGRectMake(15, matchBtnHight*3+45+(matchBtnHight*2+10)*i, MainScreenW-30, matchBtnHight*2*(i*0.5+1))];
        textView.layer.cornerRadius=5;
        textView.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
        textView.backgroundColor=[UIColor whiteColor];
        textView.delegate=self;
        textView.font = [UIFont systemFontOfSize:14];
        [secondPageBgView addSubview:textView];
        
        UILabel*placeHoderlabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, MainScreenW-30, 30)];
        placeHoderlabel.textColor=[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0];
        placeHoderlabel.backgroundColor=[UIColor clearColor];
        placeHoderlabel.font=[UIFont systemFontOfSize:14];
        placeHoderlabel.text = textViewTitle[i];
        //placeHoderlabel.enabled=NO;
        [textView addSubview:placeHoderlabel];

        if(i==0)
        {
            _matchTypeBtn=selBtn;
            _matchPlaceTextView=textView;
            _matchPlacePlaceHoder=placeHoderlabel;
        }
        else
        {
            _matchTimeBtn=selBtn;
            _matchNoteTextView=textView;
            _matchNotePlaceHoder=placeHoderlabel;
        }
        [secondPageBgView addSubview:selBtn];
        
    }
    _matchPeoTextField=[[UITextField alloc]init];
    _matchPeoTextField.frame=CGRectMake(15, matchBtnHight*2+35, MainScreenW-30, matchBtnHight);
    [_matchPeoTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _matchPeoTextField.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _matchPeoTextField.font=[UIFont systemFontOfSize:14];
    _matchPeoTextField.layer.cornerRadius=5;
    _matchPeoTextField.textAlignment=NSTextAlignmentLeft;
    _matchPeoTextField.backgroundColor=[UIColor whiteColor];
    _matchPeoTextField.delegate=self;
    _matchPeoTextField.placeholder=@"  请输入约战人数";
    [secondPageBgView addSubview:_matchPeoTextField];
    

    _matchPublishBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    _matchPublishBtn.frame=CGRectMake(60, matchBtnHight*10+50, MainScreenW-120,matchBtnHight);
    _matchPublishBtn.layer.borderWidth=1;
    [_matchPublishBtn setBackgroundColor:[UIColor whiteColor]];
    _matchPublishBtn.layer.borderColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0].CGColor;
    [_matchPublishBtn setTitleColor:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    [_matchPublishBtn addTarget:self action:@selector(matchPublishBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
    _matchPublishBtn.layer.cornerRadius=matchBtnHight/2;
    [_matchPublishBtn setTitle:@"约战" forState:UIControlStateNormal];
//    _matchPublishBtn.layer.shadowOffset = CGSizeMake(1,1);
//    _matchPublishBtn.layer.shadowOpacity = 0.1;
//    _matchPublishBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [secondPageBgView addSubview:_matchPublishBtn];

}
-(void)tapInfoBgView
{
    [_matchPeoTextField resignFirstResponder];
    [_matchNoteTextView resignFirstResponder];
    [_matchPlaceTextView resignFirstResponder];
}
-(void)textViewDidChange:(UITextView *)textView
{
    
    if (textView == self.matchPlaceTextView)
    {
        if (textView.text.length == 0)
        {
            _matchPlacePlaceHoder.text = @"  请输入约战地点,50字以内";
        }
        else
        {
            _matchPlacePlaceHoder.text = @"";
        }

    }
    if (textView == self.matchNoteTextView)
    {
        if (textView.text.length == 0)
        {
            _matchNotePlaceHoder.text = @"  请输入备注信息及联系方式哦,100字以内";
        }
        else
        {
            _matchNotePlaceHoder.text = @"";
        }
    }
    
    
    NSString *toBeString = textView.text;
    
    NSString *lang = [(UITextInputMode*)[[UITextInputMode activeInputModes] firstObject] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length >= 255)
            {
                textView.text = [toBeString substringToIndex:255];
            }
        } // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else
        {
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length >= 100)
        {
            textView.text = [toBeString substringToIndex:100];
        }
    }

}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == self.matchNoteTextView)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _matchTypeBtn.frame=CGRectMake(15, 15-180, MainScreenW-30, matchBtnHight);
            _matchTimeBtn.frame=CGRectMake(15, 15+matchBtnHight+10-180, MainScreenW-30, matchBtnHight);
            _matchPeoTextField.frame=CGRectMake(15, 15+matchBtnHight*2+20-180, MainScreenW-30, matchBtnHight);
            _matchPlaceTextView.frame=CGRectMake(15, 15+matchBtnHight*3+30-180, MainScreenW-30, matchBtnHight*2);
            _matchNoteTextView.frame=CGRectMake(15, 15+matchBtnHight*5+40-180, MainScreenW-30, matchBtnHight*3);
        }];
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == self.matchNoteTextView)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _matchTypeBtn.frame=CGRectMake(15, 15, MainScreenW-30, matchBtnHight);
            _matchTimeBtn.frame=CGRectMake(15, 15+matchBtnHight+10, MainScreenW-30, matchBtnHight);
            _matchPeoTextField.frame=CGRectMake(15, 15+matchBtnHight*2+20, MainScreenW-30, matchBtnHight);
            _matchPlaceTextView.frame=CGRectMake(15, 15+matchBtnHight*3+30, MainScreenW-30, matchBtnHight*2);
            _matchNoteTextView.frame=CGRectMake(15, 15+matchBtnHight*5+40, MainScreenW-30, matchBtnHight*3);
        }];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return  [textField resignFirstResponder];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.matchPeoTextField)
    {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }
}
- (void)textFieldDidChange:(UITextField *)textField
{
    
    if (textField == self.matchPeoTextField)
    {
        self.matchPeoTextField.text=textField.text;
        NSString*text= [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        if(text.length > 0)
        {
            [self setUpAlertController:@"请输入正确的约战人数"];
        }
        else if (textField.text.length > 2)
        {
            textField.text = [textField.text substringToIndex:2];
        }

    }
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
    
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        if([str isEqualToString:@"请输入正确的约战人数"])
//        {
//            _matchPeoTextField.text=nil;
//        }
//       
//    }];
//    [action setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
//    [alertCon addAction:action];
    [self presentViewController:alertCon animated:YES completion:nil];
    if([str isEqualToString:@"请输入正确的约战人数"])
    {
        _matchPeoTextField.text=nil;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
    }
  else  if([str isEqualToString:@"约战成功!"])
    {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(creatAlert:) userInfo:alertCon repeats:NO];
 
    }
    
    else
    {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(otherCliecked:) userInfo:alertCon repeats:NO];
    }
}
-(void)otherCliecked:(NSTimer *)timer
{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
           }];
    alert = nil;
  
}
- (void)creatAlert:(NSTimer *)timer{
    UIAlertController *alert = [timer userInfo];
    [alert dismissViewControllerAnimated:YES completion:^{
        _matchNoteTextView.text=nil;
        _matchPlaceTextView.text=nil;
        _matchPeoTextField.text=nil;
        [_matchTypeBtn setTitle:@"请选择约战类型" forState:UIControlStateNormal];
        [_matchTimeBtn setTitle:@"请选择约战时间" forState:UIControlStateNormal];
        _selDateString=nil;
        _matchTypeInfoDict=nil;
        [_matchTimeBtn setTitleColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] forState:UIControlStateNormal];
        [_matchTypeBtn setTitleColor:[UIColor colorWithRed:199.0/255 green:199.0/255 blue:205.0/255 alpha:1.0] forState:UIControlStateNormal];
        
        _matchPlacePlaceHoder.text=@"  请输入约战地点,50字以内";
        _matchNotePlaceHoder.text=@"  请输入备注信息及联系方式哦,100字以内";
        self.scrollView.contentOffset=CGPointMake(0, 0);
        [self addRefreshLoadMore];

        
        
    }];
    alert = nil;
}


-(void)sendMatchTypeInfo:(NSDictionary *)dict
{
    _matchTypeInfoDict=dict;
    [_matchTypeBtn setTitle:[NSString stringWithFormat:@"  %@",dict[@"sName"]] forState:UIControlStateNormal];
    [_matchTypeBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
}
-(void)selBtnClicked:(UIButton*)btn
{
    
    switch (btn.tag) {
        case 300:
        {
            XXYMatchTypeInfoController*typeCon=[[XXYMatchTypeInfoController alloc]init];
            typeCon.sendDelegate=self;
            [self.navigationController pushViewController:typeCon animated:YES];
        }
            break;
        case 301:
        {
            [self setUpDatePickerView];
        }
            break;
        default:
            break;
    }
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
    _datepicker.datePickerMode = UIDatePickerModeDateAndTime;
    NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-cn"];
    _datepicker.locale=cnLocale;
    
    NSDate *maxDate = [[NSDate alloc]initWithTimeIntervalSinceNow:24*60*60*30];
    NSDate *minDate = [NSDate date];
    [_datepicker setMaximumDate:maxDate];
    [_datepicker setMinimumDate:minDate];
    
    _datepicker.frame = CGRectMake(0, MainScreenH, MainScreenW, 216);
    [_datePickerView addSubview:_datepicker];
    
    [UIView animateWithDuration:0.25f animations:^{
        _datepicker.frame = CGRectMake(0,50, MainScreenW, 216);
    }];
    [_datepicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    
    label.text=@"请选择约战日期";
    
    _selDateString=[self getDateStr:_datepicker.date];
    [_matchTimeBtn setTitle:_selDateString forState:UIControlStateNormal];
    [_matchTimeBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
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
    
    _selDateString=[self getDateStr:date];
    [_matchTimeBtn setTitle:_selDateString forState:UIControlStateNormal];
    [_matchTimeBtn setTitleColor:[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0] forState:UIControlStateNormal];
}
// 获取日期键盘的日期
- (NSString *)getDateStr:(NSDate *)date
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}

-(void)matchPublishBtnCliked:(UIButton*)btn
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/match/addMatch"];
    
    _matchNoteTextView.text= [_matchNoteTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _matchPlaceTextView.text= [_matchPlaceTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
   
    if(!_matchTypeInfoDict[@"id"])
    {
        [self setUpAlertController:@"请选择约战类型"];
    }
    else if(_selDateString.length==0)
    {
        [self setUpAlertController:@"请选择约战时间"];
    }

   else if([_matchPeoTextField.text intValue]<2||[_matchPeoTextField.text intValue]>20)
    {
        [self setUpAlertController:@"约战人数为2人~20人"];
    }
   else if (_matchPlaceTextView.text.length==0)
   {
       [self setUpAlertController:@"请填写约战地点"];
   }
    else if (_matchNoteTextView.text.length==0)
    {
        [self setUpAlertController:@"请填写备注信息,记得留下联系方式哦"];
    }
    else
    [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"mType":_matchTypeInfoDict[@"id"],@"numPeo":_matchPeoTextField.text,@"address":_matchPlaceTextView.text,@"note":_matchNoteTextView.text,@"strMTime":_selDateString} success:^(id responseObject){
        
         //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            [self setUpAlertController:@"约战成功!"];
        }
        else
        {
            [self setUpAlertController:@"约战失败!"];
        }
    } failure:^(NSError *error) {
        [self setUpAlertController:@"约战失败!"];
    }];
}

-(void)setUpNavigationItemView
{
    UIView*titleBtnBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, 50)];
    titleBtnBgView.backgroundColor=[UIColor whiteColor];
    
    UIBezierPath *titleBtnBgViewshadowPath = [UIBezierPath bezierPathWithRect:titleBtnBgView.bounds];
    titleBtnBgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    titleBtnBgView.layer.shadowOffset = CGSizeMake(0, 2.0f);
    titleBtnBgView.layer.shadowOpacity = 0.1f;
    titleBtnBgView.layer.shadowPath = titleBtnBgViewshadowPath.CGPath;
    [self.view addSubview:titleBtnBgView];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 50+1, MainScreenW, MainScreenH-64-52)];
    _scrollView.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
;
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.bounces=NO;
    _scrollView.delegate=self;
    _scrollView.pagingEnabled=YES;
    _scrollView.contentSize=CGSizeMake(MainScreenW*2, 0);
    [self.view addSubview:_scrollView];
    
    NSArray*navBtnTitle=@[@"球场",@"我要约战"];
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
        
        if(i==0)
        {
            [navBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
               _ballBtn=navBtn;
        }
        else
        {
            [navBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
                       _matchBtn=navBtn;
        }
    }
}
#pragma mark - UIScrollView delegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / MainScreenW;
    switch (index)
    {
        case 0:
        {
            [_ballBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_matchBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            [_matchBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_ballBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
            
            
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
                [_ballBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                [_matchBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                [_matchBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                [_ballBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
                
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
            [_ballBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_matchBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 101:
        {
            [UIView animateWithDuration:0.2   animations:^{
                _scrollView.contentOffset = CGPointMake(MainScreenW, 0);
            }];
            [_matchBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            [_ballBtn setTitleColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0] forState:UIControlStateNormal];
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

#import "XXYCamDyDetailController.h"
#import "XXYCampusDynamicModel.h"
#import "XXYCampusDynamicCell.h"
#import "XXYCampusDynamicFrame.h"
#import"XXYBackButton.h"
#import "XXYPublishDynamicController.h"
#import "XXYPriasePeopleTableView.h"
#import "XXYCommentDetailTableView.h"
#import "BSHttpRequest.h"
#import <MJExtension.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface XXYCamDyDetailController ()<XXYReloadNewDataDelegate,XXYSendTableViewHightDataDelegate,XXYSendPriaseTableViewHightDataDelegate>

@property(nonatomic,strong)UIScrollView*bgScollView;
@property(nonatomic,strong)UIScrollView*pageScollView;
@property(nonatomic,strong)UIView*lineScrollView;
@property(nonatomic,strong)UIButton*commentListBtn;
@property(nonatomic,strong)UIButton*praiseListBtn;
@property(nonatomic,strong)UIButton*commentBtn;
@property(nonatomic,strong)UIButton*praisetBtn;
@property(nonatomic,assign)CGFloat commentListBtnWidth;
@property(nonatomic,assign)CGFloat praiseListBtnWidth;
@property(nonatomic,strong)UIView*praiseAndCommmentListBgView;

@property (strong , nonatomic)NSMutableArray<XXYCampusDynamicFrame *> *dataList;
@end

@implementation XXYCamDyDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"正文";
    
    [self setUpBgScrollView];
    [self setUpMoreBtn];
    [self setUpScrollView];
    if(self.messIndex==1)
    {
        [self loadNewData];
        [self setUpCommmentAndPraiseTableView:self.actId];
    }
    else
    {
        [self setUpCommmentAndPraiseTableView:self.campusDynamicFrame.dataModel.dynamicId];
    }
}
-(void)setUpBgScrollView
{
    _bgScollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, MainScreenW, MainScreenH-64-44)];
    _bgScollView.backgroundColor=XXYBgColor;
    _bgScollView.showsVerticalScrollIndicator=NO;
    if(self.campusDynamicFrame.cellHeight<MainScreenH/2)
    {
        _bgScollView.contentSize=CGSizeMake(0, MainScreenH);
    }
    else
    {
        _bgScollView.contentSize=CGSizeMake(0, self.campusDynamicFrame.cellHeight+MainScreenH/2);
    }
    [self.view addSubview:_bgScollView];
}

-(void)loadNewData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    //NSLog(@"%@",self);
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@%@",BaseUrl,@"/student/pg/listDetailPgAct/",self.actId];
    
    [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
        
        //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary*dict=objString[@"data"];
        
        XXYCampusDynamicModel*model=[[XXYCampusDynamicModel alloc]init];
        model.dynamicId = dict[@"id"];
        model.userId = dict[@"userId"];
        model.name = dict[@"userDto"][@"username"];
        model.profile_image= dict[@"userDto"][@"avatarUrl"];
        model.text = dict[@"content"];;
        model.ding =((NSString*) dict[@"zanCount"]).integerValue;
        model.comment = ((NSString*)dict[@"discussesInfo"][@"total"]).integerValue;
        model.created_at = [NSString stringWithFormat:@"%@:00",dict[@"strCreateAt"]];
        model.isZan4Me=((NSString*) dict[@"isZan4Me"]).boolValue;
        model.vedioUrl = dict[@"vedioUrl"];
        NSArray*imageArray=dict[@"imgs"];
        
        model.picCount = [NSNumber numberWithInteger:imageArray.count].integerValue;
        model.imageArray=imageArray;
        
        XXYCampusDynamicFrame*frame=[[XXYCampusDynamicFrame alloc]init];
        
        frame.dataModel=model;
        
        //头部cell
        XXYCampusDynamicCell *topicCell = [[XXYCampusDynamicCell alloc]init];
        topicCell.backgroundColor = [UIColor whiteColor];
        self.campusDynamicFrame=frame;
        topicCell.selTool=1;
        topicCell.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.campusDynamicFrame.cellHeight-35);
        [_bgScollView addSubview:topicCell];
        topicCell.campusFrame = self.campusDynamicFrame;
        
        _praiseAndCommmentListBgView.frame=CGRectMake(0, self.campusDynamicFrame.cellHeight-35+10, MainScreenW, 44);
        
        [_commentListBtn setTitle:[NSString stringWithFormat:@"评论 %i",self.campusDynamicFrame.dataModel.comment] forState:UIControlStateNormal];
        [_praiseListBtn setTitle:[NSString stringWithFormat:@"赞 %i",self.campusDynamicFrame.dataModel.ding] forState:UIControlStateNormal];
        if(self.campusDynamicFrame.dataModel.isZan4Me)
        {
            [_praisetBtn setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateNormal];
            [_praisetBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        }

    } failure:^(NSError *error) {
    }];
    
}

-(void)reloadNewDataOfPublished
{
    XXYCommentDetailTableView*tabView=[self.view viewWithTag:20];
    [tabView addRefreshLoadMore];
    
    UIButton*btn=[self.view viewWithTag:200];
    [btn setTitle:[NSString stringWithFormat:@"评论 %i",self.campusDynamicFrame.dataModel.comment+1] forState:UIControlStateNormal];
}
-(void)setUpMoreBtn
{
    //返回按钮
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    //右边更多按钮
    UIButton*moreBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame=CGRectMake(0, 0, 40, 40);
    [moreBtn setImage:[UIImage imageNamed:@"school_stb_more"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(detailPageCliked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:moreBtn];
    
}

-(void)detailPageCliked
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary*imUserInfo=[defaults objectForKey:@"userInfo"];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if([[NSString stringWithFormat:@"%@",self.campusDynamicFrame.dataModel.userId] isEqualToString:[NSString stringWithFormat:@"%@",imUserInfo[@"user"][@"id"]]])
    {
        [controller addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteMyDynamic];
        }]];
    }
    [controller addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        SVProgressHUD.minimumDismissTimeInterval=1.0  ;
        SVProgressHUD.maximumDismissTimeInterval=1.5  ;
        [SVProgressHUD showSuccessWithStatus:@"举报成功"];
        
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)deleteMyDynamic
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/deletePgAct"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"sid"] = userSidString;
    
    if(self.actId&&self.messIndex==1)
    {
        parameters[@"actId"] = self.actId;
    }
    else
    {
        parameters[@"actId"] = self.campusDynamicFrame.dataModel.dynamicId;
    }
    [BSHttpRequest POST:requestUrl parameters:parameters success:^(id responseObject){
        
        //        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if([objString[@"message"] isEqualToString:@"success"])
        {
            SVProgressHUD.minimumDismissTimeInterval=1.0  ;
            SVProgressHUD.maximumDismissTimeInterval=1.5  ;
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            if([self.reloadDelegate respondsToSelector:@selector(sendToReloadData)])
            {
                [self.reloadDelegate sendToReloadData];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error) {
    }];
}
-(void)setUpCommmentAndPraiseTableView:(NSString*)actid
{
    XXYCommentDetailTableView*commentDetailTableView= [XXYCommentDetailTableView contentTableView];
    commentDetailTableView.frame=CGRectMake(0, 0, _pageScollView.frame.size.width, _pageScollView.frame.size.height);
    commentDetailTableView.sendDelegate=self;
    commentDetailTableView.actId=actid;
    commentDetailTableView.scrollEnabled=NO;
    commentDetailTableView.tag=20;
    [commentDetailTableView addRefreshLoadMore];
    [_pageScollView addSubview:commentDetailTableView];
    
    XXYPriasePeopleTableView*priasePeopleTableView= [XXYPriasePeopleTableView contentTableView];
    priasePeopleTableView.frame=CGRectMake(MainScreenW, 0, _pageScollView.frame.size.width, _pageScollView.frame.size.height);
    priasePeopleTableView.actId=actid;
    priasePeopleTableView.scrollEnabled=NO;
    priasePeopleTableView.sendDelegate=self;
    priasePeopleTableView.tag=21;
    [priasePeopleTableView addRefreshLoadMore];
    [_pageScollView addSubview:priasePeopleTableView];
    
}
-(void)sendhight:(CGFloat)hight
{
    //NSLog(@"sendHight=%.2f",hight);
    
    CGFloat totalH=self.campusDynamicFrame.cellHeight+19+hight+50+10;
    
    if(totalH<MainScreenH-64-44)
    {
        totalH=MainScreenH-64-24;
    }
    
    _bgScollView.contentSize=CGSizeMake(0, totalH);
    _pageScollView.frame=CGRectMake(0, self.campusDynamicFrame.cellHeight+19+10, MainScreenW, totalH-(self.campusDynamicFrame.cellHeight+19));
    XXYCommentDetailTableView*detailDabView=[self.view viewWithTag:20];
    detailDabView.frame=CGRectMake(0, 0, MainScreenW, totalH-(self.campusDynamicFrame.cellHeight+19));
    
}
-(void)sendPraisehight:(CGFloat)hight
{
    CGFloat totalH=self.campusDynamicFrame.cellHeight+19+hight+50+10;
    
    if(totalH<MainScreenH-64-44)
    {
        totalH=MainScreenH-64-24;
    }
    _bgScollView.contentSize=CGSizeMake(0, totalH);
    _pageScollView.frame=CGRectMake(0, self.campusDynamicFrame.cellHeight+19+10, MainScreenW, totalH-(self.campusDynamicFrame.cellHeight+19));
    XXYCommentDetailTableView*detailDabView=[self.view viewWithTag:20];
    detailDabView.frame=CGRectMake(0, 0, MainScreenW, totalH-(self.campusDynamicFrame.cellHeight+19));
    
}
-(void)setUpScrollView
{
    //头部cell
    if(!self.actId)
    {
        XXYCampusDynamicCell *topicCell = [[XXYCampusDynamicCell alloc]init];
        topicCell.backgroundColor = [UIColor whiteColor];
        topicCell.campusFrame = self.campusDynamicFrame;
        topicCell.selTool=1;
        topicCell.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.campusDynamicFrame.cellHeight-35);
        [_bgScollView addSubview:topicCell];
    }
    UIView*toolBgView=[[UIView alloc]initWithFrame:CGRectMake(0, MainScreenH-64-44, MainScreenW, 44)];
    //    toolBgView.backgroundColor=[UIColor clearColor];
    //
    //    UIImageView*imageView=[[UIImageView alloc]initWithFrame:toolBgView.bounds];
    //    imageView.image=[UIImage imageNamed:@"table_bg2"];
    //    imageView.userInteractionEnabled=YES;
    //    [toolBgView addSubview:imageView];
    
    UIColor *bgColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"table_bg2"]];
    
    [toolBgView setBackgroundColor:bgColor];
    
    
    UIBezierPath *titleBtnBgViewshadowPath = [UIBezierPath bezierPathWithRect:toolBgView.bounds];
    toolBgView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    toolBgView.layer.shadowOffset = CGSizeMake(-0.0f, 0.5f);
    toolBgView.layer.shadowOpacity = 0.1f;
    toolBgView.layer.shadowPath = titleBtnBgViewshadowPath.CGPath;
    
    
    [self.view addSubview:toolBgView];
    
    UIView*linView=[[UIView alloc]initWithFrame:CGRectMake(MainScreenW/2-0.5, 4, 1, 36)];
    linView.backgroundColor=[UIColor lightGrayColor];
    [toolBgView addSubview:linView];
    
    NSArray*toolBtnNameArr=@[@"mainCellComment",@"mainCellDing"];
    NSArray*toolBtnTitleNameArr=@[@"评论",@"赞"];
    
    
    _praiseAndCommmentListBgView=[[UIView alloc]initWithFrame:CGRectMake(0, self.campusDynamicFrame.cellHeight-35+10, MainScreenW, 44)];
    _praiseAndCommmentListBgView.backgroundColor=[UIColor whiteColor];
    [_bgScollView addSubview:_praiseAndCommmentListBgView];
    
    NSArray*praiseAndCommmentListBtnTitle=@[[NSString stringWithFormat:@"评论 %i",self.campusDynamicFrame.dataModel.comment],[NSString stringWithFormat:@"赞 %i",self.campusDynamicFrame.dataModel.ding]];
    
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]};
    _commentListBtnWidth=[praiseAndCommmentListBtnTitle[0] sizeWithAttributes:attrs].width+10;
    _praiseListBtnWidth=[praiseAndCommmentListBtnTitle[1] sizeWithAttributes:attrs].width+10;
    
    
    _lineScrollView=[[UIView alloc]initWithFrame:CGRectMake(10, 36, _commentListBtnWidth, 2)];
    _lineScrollView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [_praiseAndCommmentListBgView addSubview:_lineScrollView];
    
    for (NSInteger i=0;i<2;i++)
    {
        UIButton*toolBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        toolBtn.frame=CGRectMake(MainScreenW/2*i+0.5, 4.5, MainScreenW/2-0.5, 35);
        [toolBtn setImage:[UIImage imageNamed:toolBtnNameArr[i]] forState:UIControlStateNormal];
        [toolBtn setTitle:toolBtnTitleNameArr[i] forState:UIControlStateNormal];
        [toolBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        toolBtn.tag=100+i;
        toolBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        [toolBtn addTarget: self action:@selector(toolBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        [toolBgView addSubview:toolBtn];
        
        UIButton*praiseAndCommmentListBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        
        [praiseAndCommmentListBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        praiseAndCommmentListBtn.tag=200+i;
        praiseAndCommmentListBtn.titleLabel.font=[UIFont systemFontOfSize:17];
        [praiseAndCommmentListBtn addTarget: self action:@selector(praiseAndCommmentListBtnCliked:) forControlEvents:UIControlEventTouchUpInside];
        if(i==0)
        {
            praiseAndCommmentListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            praiseAndCommmentListBtn.titleLabel.textAlignment=NSTextAlignmentLeft;
            praiseAndCommmentListBtn.frame=CGRectMake(10+(MainScreenW-_commentListBtnWidth-20)*i, 7, _commentListBtnWidth, 30);
            [praiseAndCommmentListBtn setTitle:praiseAndCommmentListBtnTitle[i] forState:UIControlStateNormal];
            _commentBtn=toolBtn;
            _commentListBtn=praiseAndCommmentListBtn;
        }
        else
        {
            praiseAndCommmentListBtn.frame=CGRectMake(10+(MainScreenW-20-_praiseListBtnWidth)*i, 7, _praiseListBtnWidth, 30);
            praiseAndCommmentListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            praiseAndCommmentListBtn.titleLabel.textAlignment=NSTextAlignmentRight;
            [self setUpButton:praiseAndCommmentListBtn number:self.campusDynamicFrame.dataModel.ding];
            _praisetBtn=toolBtn;
            _praiseListBtn=praiseAndCommmentListBtn;
            
            if(self.campusDynamicFrame.dataModel.isZan4Me)
            {
                [toolBtn setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateNormal];
                [_praisetBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            }
        }
        [_praiseAndCommmentListBgView addSubview:praiseAndCommmentListBtn];
    }
    _pageScollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, self.campusDynamicFrame.cellHeight-35+44+10+10, MainScreenW, MainScreenH/2+self.campusDynamicFrame.cellHeight)];
    _pageScollView.backgroundColor=[UIColor whiteColor];
    _pageScollView.showsHorizontalScrollIndicator=NO;
    _pageScollView.contentSize=CGSizeMake(MainScreenW*2, 0);
    _pageScollView.scrollEnabled=NO;
    [_bgScollView addSubview:_pageScollView];
}
-(void)setUpPraiseAndCommmentListBgView:(NSDictionary*)dict
{
    
}
-(void)praiseAndCommmentListBtnCliked:(UIButton*)btn
{
    if(btn.tag==200)
    {
        [UIView animateWithDuration:0.2   animations:^{
            _pageScollView.contentOffset=CGPointMake(0, 0);
            _lineScrollView.frame=CGRectMake(10, 36, _commentListBtnWidth, 2);
        }];
        
        XXYCommentDetailTableView*tabView=[self.view viewWithTag:20];
        [tabView addRefreshLoadMore];
    }
    else
    {
        [UIView animateWithDuration:0.2   animations:^{
            _pageScollView.contentOffset=CGPointMake(MainScreenW, 0);
            _lineScrollView.frame=CGRectMake(MainScreenW-_praiseListBtnWidth-10, 36, _praiseListBtnWidth, 2);
        }];
        
        XXYPriasePeopleTableView*tabView=[self.view viewWithTag:21];
        tabView.index=1;
        [tabView addRefreshLoadMore];
    }
}
-(void)toolBtnCliked:(UIButton*)btn
{
    if(btn.tag==100)
    {
        XXYPublishDynamicController*pubCon=[[XXYPublishDynamicController alloc]init];
        pubCon.index=1;
        pubCon.reloadDelegate=self;
        pubCon.actId=self.campusDynamicFrame.dataModel.dynamicId;
        [self presentViewController:pubCon animated:YES completion:nil];
    }
    else
    {
        self.campusDynamicFrame.dataModel.isZan4Me=!self.campusDynamicFrame.dataModel.isZan4Me;
        if(self.campusDynamicFrame.dataModel.isZan4Me)
        {
            [self priase];
        }
        else
        {
            [self canclePriase];
            //NSLog(@"取消赞");
        }
    }
}
-(void)setUpButton:(UIButton *)button number:(NSInteger)number
{
    if (number >= 10000) {
        [button setTitle:[NSString stringWithFormat:@"赞 %.1f万",number / 10000.0] forState:UIControlStateNormal];
    }else if (number > 0){
        [button setTitle:[NSString stringWithFormat:@"赞 %zd",number] forState:UIControlStateNormal];
    }else
    {
        [button setTitle:@"赞 0" forState:UIControlStateNormal];
    }
}

-(void)priase
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/saveZan"];
    
    if(self.campusDynamicFrame.dataModel.dynamicId)
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"actId":self.campusDynamicFrame.dataModel.dynamicId} success:^(id responseObject){
            
            //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [_praisetBtn setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateNormal];
                self.campusDynamicFrame.dataModel.ding++;
                [self setUpButton:_praiseListBtn number:self.campusDynamicFrame.dataModel.ding];
                [_praisetBtn setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
                
                XXYPriasePeopleTableView*tabView=[self.view viewWithTag:21];
                tabView.index=1;
                [tabView addRefreshLoadMore];

            }
            else if([objString[@"message"] hasPrefix:@"只能赞一次"]&&[codeString isEqualToString:@"9112"])
            {
                [self setUpAlertController:@"只能赞一次哦"];
            }
            else
            {
                [self setUpAlertController:@"赞失败,稍后再试!"];
            }
        } failure:^(NSError *error) {
            [self setUpAlertController:@"赞失败,稍后再试!"];
        }];
    
    else
    {
        [self setUpAlertController:@"赞失败,稍后再试!"];
    }
}
-(void)canclePriase
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/removeZan"];
    
    if(self.campusDynamicFrame.dataModel.dynamicId)
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"actId":self.campusDynamicFrame.dataModel.dynamicId} success:^(id responseObject){
            
            //NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                [_praisetBtn setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
                self.campusDynamicFrame.dataModel.ding--;
                [self setUpButton:_praiseListBtn number:self.campusDynamicFrame.dataModel.ding];
                [_praisetBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                
                XXYPriasePeopleTableView*tabView=[self.view viewWithTag:21];
                tabView.index=1;
                [tabView addRefreshLoadMore];

            }
            else if([objString[@"message"] hasPrefix:@"只能赞一次"]&&[codeString isEqualToString:@"9112"])
            {
                [self setUpAlertController:@"已经取消赞了!"];
            }
            else
            {
                [self setUpAlertController:@"取消赞失败,稍后再试!"];
            }
        } failure:^(NSError *error) {
            
            [self setUpAlertController:@"取消赞失败,稍后再试!"];
        }];
    
    else
        [self setUpAlertController:@"取消赞失败,稍后再试!"];
    
}

-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        
        if([str isEqualToString:@"删除成功"])
        {
            if([self.reloadDelegate respondsToSelector:@selector(sendToReloadData)])
            {
                [self.reloadDelegate sendToReloadData];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
    [action setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
    [alertCon addAction:action];
    [self presentViewController:alertCon animated:YES completion:nil];
}

-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

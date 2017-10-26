#import "XXYClassAnnouncementDetailController.h"
#import "XXYBackButton.h"

@interface XXYClassAnnouncementDetailController ()
@property(nonatomic,strong)UILabel*titleLabel;
@property(nonatomic,strong)UILabel*timeLabel;
@property(nonatomic,strong)UILabel*detailLabel;
@end

@implementation XXYClassAnnouncementDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"公告详情";

    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    [self setUpSubViews];
}
-(void)setUpSubViews
{
    _titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 10, MainScreenW-30, 40)];
    _titleLabel.textAlignment=NSTextAlignmentLeft;
    _titleLabel.numberOfLines=2;
    _titleLabel.font=[UIFont systemFontOfSize:20 weight:2];
    _titleLabel.text=self.announcementModel.title;
    [self.view addSubview:_titleLabel];
    
    _timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(15, 60, MainScreenW-30, 30)];
    _timeLabel.textAlignment=NSTextAlignmentLeft;
    _timeLabel.text=[self turnDateStringToMyString:self.announcementModel.createdAt];
    _timeLabel.font=[UIFont systemFontOfSize:16];
    _timeLabel.textColor=[UIColor lightGrayColor];
    [self.view addSubview:_timeLabel];
    
    NSString*str=self.announcementModel.content;
    
    _detailLabel=[[UILabel alloc]init];
    
    _detailLabel.text=str;
    _detailLabel.numberOfLines=0;
    _detailLabel.font=[UIFont systemFontOfSize:15];
    
    CGSize titleSize = [str boundingRectWithSize:CGSizeMake(MainScreenW-20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    _detailLabel.frame=CGRectMake(10,90, MainScreenW-20, titleSize.height);

    [self.view addSubview:_detailLabel];

}
-(NSString*)turnDateStringToMyString:(NSString*)dateString
{
    
    NSArray*array=[dateString componentsSeparatedByString:@" "];
    
    NSString*dayString=[array[1] substringWithRange:NSMakeRange(0,((NSString*)array[1]).length-1)];
    
    NSString*monthString;
    
    NSArray*monArray=@[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
    NSArray*monNumArray=@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    
    for (int i=0;i<monArray.count;i++)
    {
        if([array[0] isEqualToString:monArray[i]])
        {
            monthString=monNumArray[i];
        }
    }
    if(array.count>=4)
    return [NSString stringWithFormat:@"%@-%@-%@ %@",array[2],monthString,dayString,array[3]];
    else
        return nil;
}

-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

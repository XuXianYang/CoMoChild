#import "XXYTestFluidListCell.h"
#import "XXYTestFluidListModel.h"
@interface XXYTestFluidListCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *testTime;

@property (weak, nonatomic) IBOutlet UILabel *remianTime;


@end
@implementation XXYTestFluidListCell
-(void)setDataModel:(XXYTestFluidListModel *)dataModel
{
    _dataModel=dataModel;
    
    _remianTime.text=[NSString stringWithFormat:@"还剩\n%i\n天",dataModel.daysAfterNow];
    
    _testTime.text=[self turnDateStringToMyString:dataModel.startTime];
    
    _titleLabel.text=[NSString stringWithFormat:@"%@(%@)",[self turnCategoryIdToTestType:dataModel.category],dataModel.courseName];
    
}
-(void)layoutSubviews
{
    
    _titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:20];
    
    _testTime.textColor=[UIColor lightGrayColor];
    _testTime.font=[UIFont systemFontOfSize:15];
    
    _remianTime.textColor=[UIColor whiteColor];
    _remianTime.font=[UIFont systemFontOfSize:18];
    _remianTime.numberOfLines=3;
    _remianTime.textAlignment=NSTextAlignmentCenter;
    _remianTime.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
}
-(NSString*)turnCategoryIdToTestType:(NSInteger)category
{
    NSArray*testTypeArray=@[@"期末考试",@"期中考试",@"月考"];
    NSString*testType;
    for(NSInteger i=1;i<=3;i++)
    {
        if(category==i)
        {
            testType=testTypeArray[i-1];
            return testType;
        }
    }
    return testType;
}
-(NSString*)turnDateStringToMyString:(NSString*)dateString
{
    
    NSArray*array=[dateString componentsSeparatedByString:@" "];
    
    NSString*dayString=[array[1] substringWithRange:NSMakeRange(0,((NSString*)array[1]).length-1)];
    
    NSString*monthString;
    
    NSArray*monArray=@[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
    NSArray*monNumArray=@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    
    for (int i=0;i<monArray.count;i++) {
        if([array[0] isEqualToString:monArray[i]])
        {
            monthString=monNumArray[i];
        }
    }
    return [NSString stringWithFormat:@"%@-%@-%@",array[2],monthString,dayString];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

#import "XXYCourseWareCell.h"
#import "XXYCourseWareListModel.h"
@interface XXYCourseWareCell()

@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;



@end
@implementation XXYCourseWareCell
-(void)setDataModel:(XXYCourseWareListModel *)dataModel
{
    _dataModel=dataModel;
    
    if(dataModel.courseName.length>1)
    _courseNameLabel.text=[dataModel.courseName substringWithRange:NSMakeRange(0, 1)];
    else
        _courseNameLabel.text=@"课";
    
    _titleLabel.text=dataModel.name;
    
    if(dataModel.teacherName)
    _timeLabel.text=[NSString stringWithFormat:@"%@%@",dataModel.teacherName,[self turnDateStringToMyString:dataModel.createdAt]];
    else
        _timeLabel.text=[self turnDateStringToMyString:dataModel.createdAt];
    
    _typeLabel.text=dataModel.myDescription;
    
    _fileNameLabel.text=dataModel.attachmentName;
}
-(void)layoutSubviews
{
    
    _courseNameLabel.backgroundColor=[UIColor colorWithRed:255.0/255 green:102.0/255 blue:31.0/255 alpha:1.0];
    _courseNameLabel.font=[UIFont systemFontOfSize:22];
    _courseNameLabel.textColor=[UIColor whiteColor];
    _courseNameLabel.textAlignment=NSTextAlignmentCenter;
    _titleLabel.font=[UIFont systemFontOfSize:20];
    
    _timeLabel.font=[UIFont systemFontOfSize:13];
    
    _timeLabel.textColor=[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
    
    _typeLabel.numberOfLines=2;
    
    _typeLabel.font=[UIFont systemFontOfSize:15];
    
    _bgView.backgroundColor=[UIColor colorWithRed:233.0/255 green:234.0/255 blue:236.0/255 alpha:1.0];
    
    _otherLabel.font=[UIFont systemFontOfSize:15];
    _otherLabel.textColor=[UIColor colorWithRed:161.0/255 green:161.0/255 blue:162.0/255 alpha:1.0];
    
    _fileNameLabel.textColor=[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0];
    _fileNameLabel.layer.cornerRadius=5;
    _fileNameLabel.layer.borderColor=[UIColor colorWithRed:31.0/255 green:152.0/255 blue:37.0/255 alpha:1.0].CGColor;
    _fileNameLabel.layer.borderWidth=0.5;
    _fileNameLabel.textAlignment=NSTextAlignmentCenter;
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
   }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

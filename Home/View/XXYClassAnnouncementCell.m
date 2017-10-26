#import "XXYClassAnnouncementCell.h"
#import "XXYClassAnnouncementModel.h"
@interface XXYClassAnnouncementCell ()


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;




@end

@implementation XXYClassAnnouncementCell

-(void)setDataModel:(XXYClassAnnouncementModel *)dataModel
{
    _dataModel=dataModel;
    _titleLabel.text=dataModel.title;
    _contentLabel.text=dataModel.content;
    _timeLabel.text=[self turnDateStringToMyString:dataModel.createdAt];
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

-(void)layoutSubviews
{
    _titleLabel.font=[UIFont systemFontOfSize:18];
    _titleLabel.textColor=XXYMainColor;
    
    _contentLabel.font=[UIFont systemFontOfSize:17];
    _contentLabel.textColor=[UIColor colorWithRed:56.0/255 green:56.0/255 blue:56.0/255 alpha:1.0];
    _contentLabel.numberOfLines=0;
    
    _timeLabel.textColor=[UIColor lightGrayColor];
    _timeLabel.font=[UIFont systemFontOfSize:15];
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

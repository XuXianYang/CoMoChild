#import "XXYPublicBenefitRecordCell.h"
#import "XXYPublicBenefitRecordModel.h"

@interface XXYPublicBenefitRecordCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@end

@implementation XXYPublicBenefitRecordCell
-(void)setDataModel:(XXYPublicBenefitRecordModel *)dataModel
{
    _dataModel=dataModel;
    _timeLabel.text=dataModel.strCreateAt;
    
    _moneyLabel.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    NSString*moneyString=[NSString stringWithFormat:@"捐出%@卡 已兑换%@块钱",dataModel.calorieVal,dataModel.countFor];
    NSMutableAttributedString *calorieAndMoneyStr = [[NSMutableAttributedString alloc] initWithString:moneyString];
    [calorieAndMoneyStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] range:NSMakeRange(2,dataModel.calorieVal.length)];
    [calorieAndMoneyStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] range:NSMakeRange(moneyString.length-2-dataModel.countFor.length,dataModel.countFor.length)];
    _moneyLabel.attributedText = calorieAndMoneyStr;
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    _itemImageView.layer.cornerRadius = 5;
    _itemImageView.clipsToBounds = YES;
}
-(void)layoutSubviews
{
    _iconImageView.image=[UIImage imageNamed:@"calorie_timershaft"];
    
    _itemImageView.contentMode=UIViewContentModeScaleAspectFill;
    _itemImageView.clipsToBounds = YES;
    _itemImageView.image=[UIImage imageNamed:@"publicBenefit_item"];
   
    _lineView.backgroundColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    
    _timeLabel.textColor=[UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:1.0];
    _timeLabel.font=[UIFont systemFontOfSize:12];
    _moneyLabel.numberOfLines=0;
    _moneyLabel.font=[UIFont systemFontOfSize:12];
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

#import "XXYTimeShaftCell.h"
#import "XXYTimeShartModel.h"
@interface XXYTimeShaftCell()

@property (weak, nonatomic) IBOutlet UIView *upLineView;
@property (weak, nonatomic) IBOutlet UIView *downLineView;
@property (weak, nonatomic) IBOutlet UILabel *timeInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCalorieNum;
@property (weak, nonatomic) IBOutlet UILabel *secondCalorieNum;
@property (weak, nonatomic) IBOutlet UILabel *totalCalorie;

@end

@implementation XXYTimeShaftCell
-(void)setDataModel:(XXYTimeShartModel *)dataModel
{
    _dataModel=dataModel;
    _timeInfoLabel.text=dataModel.calorieTime;
    _totalCalorie.text=dataModel.calorieTotalnNum;
}
-(void)layoutSubviews
{
    _upLineView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    _downLineView.backgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    _firstCalorieNum.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _firstCalorieNum.textAlignment=NSTextAlignmentRight;
    _firstCalorieNum.font=[UIFont systemFontOfSize:11];
    _firstCalorieNum.text=@"消耗了";
    _secondCalorieNum.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _secondCalorieNum.text=@"卡";
    _secondCalorieNum.textAlignment=NSTextAlignmentLeft;
    _secondCalorieNum.font=[UIFont systemFontOfSize:11];
    _totalCalorie.textColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    _totalCalorie.font=[UIFont systemFontOfSize:11];
    _totalCalorie.textAlignment=NSTextAlignmentCenter;
    _timeInfoLabel.textColor=[UIColor colorWithRed:105.0/255 green:105.0/255 blue:105.0/255 alpha:1.0];
    _timeInfoLabel.font=[UIFont systemFontOfSize:11];
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

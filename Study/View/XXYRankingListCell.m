#import "XXYRankingListCell.h"
#import "XXYRankingListModel.h"
#import "UIImageView+WebCache.h"
@interface XXYRankingListCell()

@property (weak, nonatomic) IBOutlet UILabel *rankingLiastNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rankingListIconImageView;

@property (weak, nonatomic) IBOutlet UILabel *rankingListINameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankingListOfCaloriesLabel;

@end

@implementation XXYRankingListCell

-(void)setDataModel:(XXYRankingListModel *)dataModel
{
    _dataModel=dataModel;
    _rankingLiastNumLabel.text=dataModel.rankingListNum;
    
    [_rankingListIconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.rankingListIcon] placeholderImage:[UIImage imageNamed:@"head_bj"]];

    //_rankingListIconImageView.image=[UIImage imageNamed:@"icon-clustered"];
    _rankingListINameLabel.text=dataModel.rankingListName;
    _rankingListOfCaloriesLabel.text=dataModel.rankingListOfCalories;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _rankingListOfCaloriesLabel.font=[UIFont systemFontOfSize:14];
    _rankingLiastNumLabel.font=[UIFont systemFontOfSize:13];
    _rankingListINameLabel.font=[UIFont systemFontOfSize:13];
    _rankingListINameLabel.numberOfLines=2;
    _rankingListOfCaloriesLabel.textAlignment=NSTextAlignmentRight;
    _rankingLiastNumLabel.textAlignment=NSTextAlignmentCenter;
    _rankingLiastNumLabel.textColor=[UIColor colorWithRed:104.0/255 green:104.0/255 blue:104.0/255 alpha:1.0];
    _rankingListIconImageView.layer.cornerRadius=15;
    _rankingListIconImageView.layer.masksToBounds=YES;
     _rankingListINameLabel.textColor=[UIColor colorWithRed:104.0/255 green:104.0/255 blue:104.0/255 alpha:1.0];
    _rankingListOfCaloriesLabel.textColor=[UIColor colorWithRed:28.0/255 green:148.0/255 blue:244.0/255 alpha:1.0];
    
}
- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

#import "XXYMatchListCell.h"
#import "XXYMatchListModel.h"
#import "UIImageView+WebCache.h"
@interface XXYMatchListCell ()
@property (weak, nonatomic) IBOutlet UIView *bgViEW;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numOfMatchLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
@implementation XXYMatchListCell
-(void)setDataModel:(XXYMatchListModel *)dataModel
{
    _dataModel=dataModel;
    
    _itemNameLabel.text=dataModel.mTypeName;
    
    _timeLabel.text=dataModel.strMTime;
    
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.imageUrl] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    _numOfMatchLabel.textColor=[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0];
    
    NSString*numString=[NSString stringWithFormat:@"%@ / %@",dataModel.joinNum,dataModel.numPeo];
    
    if([dataModel.numPeo intValue]==[dataModel.joinNum intValue])
    {
        _numOfMatchLabel.text=numString;
    }
    else
    {
        NSMutableAttributedString *numOfMatchPeoStr = [[NSMutableAttributedString alloc] initWithString:numString];
        [numOfMatchPeoStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] range:NSMakeRange(0,dataModel.joinNum.length)];
        _numOfMatchLabel.attributedText = numOfMatchPeoStr;
    }
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    _iconImageView.layer.cornerRadius = 18;
    _iconImageView.clipsToBounds = YES;
    
    self.bgViEW.layer.cornerRadius=5;
    self.bgViEW.layer.borderColor=[UIColor clearColor].CGColor;
    self.bgViEW.backgroundColor = [UIColor whiteColor];
    //给bgView边框设置阴影
    self.bgViEW.layer.shadowOffset = CGSizeMake(1,1);
    self.bgViEW.layer.shadowOpacity = 0.1;
    self.bgViEW.layer.shadowColor = [UIColor blackColor].CGColor;
}
-(void)layoutSubviews
{
    _itemNameLabel.textColor=[UIColor colorWithRed:246.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    _itemNameLabel.font=[UIFont systemFontOfSize:14];
    
    _numOfMatchLabel.font=[UIFont systemFontOfSize:14];
    _numOfMatchLabel.textAlignment=NSTextAlignmentRight;
    
    _timeLabel.font=[UIFont systemFontOfSize:10];
    _timeLabel.textColor=[UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0];
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

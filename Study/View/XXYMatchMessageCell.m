#import "XXYMatchMessageCell.h"
@interface XXYMatchMessageCell()
@end
@implementation XXYMatchMessageCell
-(void)layoutSubviews
{
    _titleLabel.font=[UIFont systemFontOfSize:17];
    _titleLabel.textColor=[UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    _lineView.backgroundColor=[UIColor colorWithRed:229.0/255 green:229.0/255 blue:229.0/255 alpha:1.0];
    
    switch (self.index) {
        case 0:
        {
            _iconImageView.image=[UIImage imageNamed:@"mymsg_"];
        }
            break;
        case 1:
        {
            _iconImageView.image=[UIImage imageNamed:@"mysag_cmt"];
        }
            break;
        case 2:
        {
            _iconImageView.image=[UIImage imageNamed:@"mymsg_nice"];
        }
            break;
  
        default:
            break;
    }
    
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

#import "XXYProfileSettingCell.h"

@interface XXYProfileSettingCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
@implementation XXYProfileSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)layoutSubviews
{
    
    _lineView.backgroundColor=[UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    
    switch (self.index) {
        case 0:
        {
            _iconImageView.image=[UIImage imageNamed:@"setting_class"];
            _titleLabel.text=@"加入班级";
        }
            break;

        case 1:
        {
            _iconImageView.image=[UIImage imageNamed:@"set_msg"];
            _titleLabel.text=@"我的消息";
        }
            break;
        case 2:
        {
            _iconImageView.image=[UIImage imageNamed:@"mFpassword"];
            _titleLabel.text=@"修改密码";
        }
            break;
        case 3:
        {
            _iconImageView.image=[UIImage imageNamed:@"set_name"];
            _titleLabel.text=@"修改姓名";

        }
            break;
        case 4:
        {
            _iconImageView.image=[UIImage imageNamed:@"personInfo"];
            _titleLabel.text=@"修改昵称";
            
        }
            break;
        case 5:
        {
            _iconImageView.image=[UIImage imageNamed:@"aboutUs"];
            _titleLabel.text=@"关于我们";

        }
            break;

            
        default:
            break;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

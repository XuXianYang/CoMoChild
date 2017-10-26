#import "XXYPraisePeopleCell.h"
#import "XXYCommentModel.h"
#import <UIImageView+WebCache.h>
@interface XXYPraisePeopleCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation XXYPraisePeopleCell

-(void)setDataModel:(XXYCommentModel *)dataModel
{
    _dataModel=dataModel;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.avatarUrl] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    
    self.nameLabel.text = dataModel.username;
}



-(void)layoutSubviews
{
    self.nameLabel.textColor=XXYCharacterBgColor;
    self.iconImageView.layer.cornerRadius=17.5;
    self.iconImageView.clipsToBounds=YES;
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

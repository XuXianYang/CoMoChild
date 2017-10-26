#import "XXYCommentDetailCell.h"
#import <UIImageView+WebCache.h>
#import "XXYCommentModel.h"

@interface XXYCommentDetailCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
@implementation XXYCommentDetailCell
/*
 {
 "id": 52,
 "actId": 88,
 "srcId": 51,
 "content": "敢不敢与哥一战",
 "createdAt": "Feb 17, 2017 5:56:04 PM",
 "srcDto":
 {
 "id": 51,
 "username": "13112312312",
 "mobileNo": "13112312312",
 "realName": "陈世明",
 "avatarUrl": "http://oci9mtj7o.bkt.clouddn.com/user/51/avatar/00f40997-4cbf-4f23-ac32-c355d8905a89/avatar.png"
 },
 "strCreatedAt": "2017-02-17 17:56"
 }
 */

-(void)setDataModel:(XXYCommentModel *)dataModel
{
    _dataModel=dataModel;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.avatarUrl] placeholderImage:[UIImage imageNamed:@"head_bj"]];
    self.nameLabel.text = dataModel.username;
    self.timeLabel.text = dataModel.createdAt;
    self.contentLabel.text=dataModel.content;
}

-(void)layoutSubviews
{
    self.contentLabel.textColor=XXYCharacterBgColor;
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

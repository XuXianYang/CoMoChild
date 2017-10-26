#import "XXYMatchDetailCell.h"
@interface XXYMatchDetailCell ()
@end

@implementation XXYMatchDetailCell

-(void)layoutSubviews
{
    
    NSArray*arr=@[@"时 间",@"类 型",@"人 数",@"地 址",@"备 注"];
    _typeLabel.text=arr[self.index];
    
    _typeLabel.font=[UIFont systemFontOfSize:14];
    _typeLabel.textColor=[UIColor colorWithRed:182.0/255 green:182.0/255 blue:182.0/255 alpha:1.0];
    
    _detailLabel.font=[UIFont systemFontOfSize:14];
    _detailLabel.textColor=[UIColor colorWithRed:68.0/255 green:68.0/255 blue:68.0/255 alpha:1.0];
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

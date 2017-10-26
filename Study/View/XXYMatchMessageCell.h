#import <UIKit/UIKit.h>

@interface XXYMatchMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property(nonatomic,assign)NSInteger index;

@end

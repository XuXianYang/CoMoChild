#import <UIKit/UIKit.h>

@interface XXYMatchDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property(nonatomic,assign)NSInteger index;
@end

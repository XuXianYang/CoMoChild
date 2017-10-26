#import <UIKit/UIKit.h>

@interface XXYTimeShaftTableView : UITableView

-(void)addRefreshLoadMore;
+ (XXYTimeShaftTableView *)contentTableView;
@property(nonatomic,retain)NSMutableArray*timeInfoDataList;

@end

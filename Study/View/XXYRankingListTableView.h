#import <UIKit/UIKit.h>

@protocol XXYcheckMoreDelegate <NSObject>

-(void)checkMoreClicked;

@end


@interface XXYRankingListTableView : UITableView

-(void)addRefreshLoadMore;
+ (XXYRankingListTableView *)contentTableView;

@property(nonatomic,retain)NSMutableArray*rankingListDataList;

@property(nonatomic,assign)NSInteger rankingListIndex;
@property(nonatomic,copy)NSString* rankingListOfNum;

@property(nonatomic,weak)id<XXYcheckMoreDelegate>checkMoreDelegate;
@end


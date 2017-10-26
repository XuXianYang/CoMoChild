#import <UIKit/UIKit.h>

@protocol XXYSendTableViewHightDataDelegate <NSObject>


-(void)sendhight:(CGFloat)hight;

@end


@interface XXYCommentDetailTableView : UITableView

+ (XXYCommentDetailTableView *)contentTableView;
//添加刷新加载更多
- (void)addRefreshLoadMore;

@property(nonatomic,copy)NSString*actId;

@property(nonatomic,weak)id<XXYSendTableViewHightDataDelegate>sendDelegate;


@end

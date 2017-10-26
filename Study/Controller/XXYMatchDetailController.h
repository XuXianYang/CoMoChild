#import <UIKit/UIKit.h>

@protocol XXYMatchListDelegate <NSObject>

-(void)reloadMatchListOfPublished;
@end


@interface XXYMatchDetailController : UIViewController

@property(nonatomic,weak)id<XXYMatchListDelegate>reloadDelegate;

@property(nonatomic,copy)NSString*getId;

@property(nonatomic,assign)NSInteger index;


@end

#import <UIKit/UIKit.h>
@protocol XXYSendNewDataDelegate <NSObject>


-(void)sendNewDataOfSettingTime:(NSString*)time;

@end

@interface XXYSOSController : UIViewController

@property(nonatomic,weak)id<XXYSendNewDataDelegate>sendDelegate;

@end

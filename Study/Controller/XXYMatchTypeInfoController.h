#import <UIKit/UIKit.h>

@protocol XXYSendMatchTypeInfoDelegate <NSObject>

-(void)sendMatchTypeInfo:(NSDictionary*)dict;

@end

@interface XXYMatchTypeInfoController : UIViewController

@property(nonatomic,weak)id<XXYSendMatchTypeInfoDelegate>sendDelegate;

@end

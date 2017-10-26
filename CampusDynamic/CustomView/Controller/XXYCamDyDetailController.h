#import <UIKit/UIKit.h>

@class XXYCampusDynamicFrame;

@protocol XXYReloadDataDelegate <NSObject>

-(void)sendToReloadData;

@end

@interface XXYCamDyDetailController : UIViewController

/** 帖子模型数据 */
@property (nonatomic, strong) XXYCampusDynamicFrame * campusDynamicFrame;

@property(nonatomic,assign)NSInteger index;

@property(nonatomic,copy)NSString* actId;

@property(nonatomic,assign)NSInteger messIndex;

@property(nonatomic,weak)id<XXYReloadDataDelegate>reloadDelegate;


@end

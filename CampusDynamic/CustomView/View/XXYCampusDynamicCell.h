#import <UIKit/UIKit.h>

@class XXYCampusDynamicFrame;

@protocol XXYPushDetailDelegate <NSObject>

-(void)deleteMyDynamicAndreload:(NSString*)dynamicId;

-(void)turnNextPageFromToolsView:(XXYCampusDynamicFrame*)campusFrame;

@end

@interface XXYCampusDynamicCell : UITableViewCell

@property (nonatomic,retain)XXYCampusDynamicFrame *campusFrame;
@property(nonatomic,weak)id<XXYPushDetailDelegate>pushDelegate;
@property(nonatomic,assign)NSInteger selTool;

@end

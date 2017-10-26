#import <UIKit/UIKit.h>
@class XXYCampusDynamicFrame;

@protocol XXYCampusToolsDelegate <NSObject>

-(void)turnNextPage:(XXYCampusDynamicFrame*)campusFrame;

@end

@interface XXYCampusToolsView : UIView
@property (nonatomic,retain)XXYCampusDynamicFrame *campusFrame;
@property(nonatomic,weak)id<XXYCampusToolsDelegate>turnDelegate;

@end

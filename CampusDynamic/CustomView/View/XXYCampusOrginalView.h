#import <UIKit/UIKit.h>

@class XXYCampusDynamicFrame;

@protocol XXYOrginalPushDetailDelegate <NSObject>

-(void)deleteMyDynamicAndreload:(NSString*)dynamicId;

@end

@interface XXYCampusOrginalView : UIView

@property (nonatomic,strong)UIButton *moreButton;
@property (nonatomic,retain)XXYCampusDynamicFrame *campusFrame;
@property(nonatomic,weak)id<XXYOrginalPushDetailDelegate>pushDelegate;

@end

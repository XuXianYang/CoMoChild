#import <Foundation/Foundation.h>

@class XXYCampusDynamicModel;

@interface XXYCampusDynamicFrame : NSObject

@property (nonatomic,retain)XXYCampusDynamicModel *dataModel;

@property (nonatomic,assign)CGRect originalViewFrame;
@property (nonatomic,assign)CGRect pictureViewFrame;
@property (nonatomic,assign)CGRect toolsViewFrame;

@property (nonatomic,assign)CGRect originalIconFrame;
@property (nonatomic,assign)CGRect originalNickFrame;
@property (nonatomic,assign)CGRect originalMoreBtnFrame;
@property (nonatomic,assign)CGRect originalTimeFrame;
@property (nonatomic,assign)CGRect originalTextFrame;

@property (nonatomic,assign)CGRect videoButtonFrame;

@property (nonatomic,assign)CGRect horizontalLineViewFrame;
@property (nonatomic,assign)CGRect verticalLineViewFrame;
@property (nonatomic,assign)CGRect praiseButtonFrame;
@property (nonatomic,assign)CGRect commentButtonFrame;

//cell的高度
@property (nonatomic,assign)CGFloat cellHeight;

@end

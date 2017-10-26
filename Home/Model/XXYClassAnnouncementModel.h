#import "JSONModel.h"

@interface XXYClassAnnouncementModel : JSONModel

@property(nonatomic,assign)NSInteger uid;

@property(nonatomic,assign)NSInteger type;

@property(nonatomic,copy)NSString*title;
@property(nonatomic,copy)NSString*content;
@property(nonatomic,copy)NSString*createdAt;

@end

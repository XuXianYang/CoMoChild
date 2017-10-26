#import "JSONModel.h"

@interface XXYMatchListModel : JSONModel
//球场列表
@property(nonatomic,copy)NSString*uid;

@property(nonatomic,copy)NSString*mType;

@property(nonatomic,copy)NSString*mTypeName;

@property(nonatomic,copy)NSString*numPeo;

@property(nonatomic,copy)NSString*strMTime;

@property(nonatomic,copy)NSString*joinNum;

@property(nonatomic,copy)NSString*imageUrl;

//约战人数详情
@property(nonatomic,copy)NSString*userNote;

@property(nonatomic,copy)NSString*strCreateAt;

@property(nonatomic,copy)NSString*userName;

@end

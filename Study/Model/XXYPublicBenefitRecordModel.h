#import "JSONModel.h"

@interface XXYPublicBenefitRecordModel : JSONModel

//{"chariProId":32,"countFor":10,"calorieVal":103908,"strCreateAt":"2017-02-08 11:41"}

@property(nonatomic,copy)NSString*countFor;

@property(nonatomic,copy)NSString*calorieVal;

@property(nonatomic,copy)NSString*strCreateAt;

@property(nonatomic,copy)NSString*chariProId;

@property(nonatomic,copy)NSString*comName;


@end

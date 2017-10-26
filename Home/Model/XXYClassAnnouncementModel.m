#import "XXYClassAnnouncementModel.h"

@implementation XXYClassAnnouncementModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"uid"}];
}

@end

//{"dayOfWeek":1,"lessonOfDay":1,"course":{"id":7,"name":"化学"},"teacher":{"teacherUserId":39,"teacherId":18,"realName":"诸葛老师"}}
#import <Foundation/Foundation.h>

@interface XXYTimeTableModel : NSObject

@property(nonatomic,copy)NSString*courseNum;

@property(nonatomic,copy)NSString*courseName;

@property(nonatomic,copy)NSString*teacherName;


@property(nonatomic,strong)NSNumber* dayOfWeek;

@property(nonatomic,strong)NSNumber* lessonOfDay;



@end

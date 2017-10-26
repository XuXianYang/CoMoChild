#import <Foundation/Foundation.h>

@interface XXYTermScoreModel : NSObject
//{"studentId":12,"score":85.0,"quiz":{"id":21,"name":"fdsdfdsfsdfds","enrolYear":2016,"startTime":"Dec 10, 2016 12:00:00 AM","endTime":"Dec 12, 2016 12:00:00 AM","category":3,"studyYear":2016,"studyTerm":1,"studyMonth":11,"description":"sfdssadasdsa","daysAfterNow":-4},"course":{"id":1,"name":"语文"}}
@property(nonatomic,copy)NSString* score;
@property(nonatomic,copy)NSString*courseId;
@property(nonatomic,copy)NSString*courseName;

@end

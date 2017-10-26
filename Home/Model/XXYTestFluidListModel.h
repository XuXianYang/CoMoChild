#import "JSONModel.h"

@interface XXYTestFluidListModel : JSONModel

//{"quiz":{"id":7,"name":"2016秋季期末考试","enrolYear":2016,"startTime":"Dec 10, 2016 12:00:00 AM","endTime":"Dec 13, 2016 12:00:00 AM","category":1,"studyYear":2016,"studyTerm":1,"studyMonth":0,"description":"期末语文考试全本内容","daysAfterNow":2},"course":{"id":1,"name":"语文"}}
@property(nonatomic,assign)NSInteger category;

@property(nonatomic,assign)NSInteger daysAfterNow;

@property(nonatomic,copy)NSString*startTime;

@property(nonatomic,copy)NSString*courseName;

@end

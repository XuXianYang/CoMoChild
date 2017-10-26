#import "JSONModel.h"

@interface XXYCourseWareListModel : JSONModel

//{"id":31,"type":1,"createdAt":"Dec 5, 2016 4:51:38 PM","name":"预习课件","description":"第三课","course":{"id":1,"name":"语文"},"teacher":{"teacherUserId":3,"teacherId":2,"realName":"张老师"},"attachment":{"id":170,"name":"guideView_4.png","url":"http://oci9mtj7o.bkt.clouddn.com/school/1/course_material/8f909e88-dee2-42be-94a2-479ed974cf82/guideView_4.png"}}

@property(nonatomic,copy)NSString*createdAt;
@property(nonatomic,copy)NSString*name;
@property(nonatomic,copy)NSString*myDescription;

@property(nonatomic,copy)NSString*courseName;

@property(nonatomic,copy)NSString*teacherName;

@property(nonatomic,copy)NSString*attachmentName;

@property(nonatomic,copy)NSString*attachmentUrl;




@end

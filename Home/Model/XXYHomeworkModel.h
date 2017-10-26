//
//  XXYHomeworkModel.h
//  点线
//
//  Created by 徐显洋 on 16/12/9.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XXYHomeworkModel : NSObject

//{"course":{"id":1,"name":"语文"},"teacher":{"teacherUserId":3,"teacherId":2,"realName":"张老师"},"homeworks":[{"homeworkId":50,"name":"第一份作业","description":"111366444","reviewed":false},{"homeworkId":51,"name":"第二份作业","description":"1667646","reviewed":false},{"homeworkId":52,"name":"第三份作业","description":"466466","reviewed":false}]}


@property(nonatomic,copy)NSString*courseName;
@property(nonatomic,copy)NSString*teacherName;

@property(nonatomic,retain)NSMutableArray*courseHomeworkContent;

@property(nonatomic,strong)NSNumber*courseId;

@end

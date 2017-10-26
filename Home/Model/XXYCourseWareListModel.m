//
//  XXYCourseWareListModel.m
//  点线
//
//  Created by 徐显洋 on 16/12/22.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYCourseWareListModel.h"

@implementation XXYCourseWareListModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"uid",@"description":@"myDescription"}];
}
@end

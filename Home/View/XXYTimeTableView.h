//
//  XXYTimeTableView.h
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/11.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXYturnNextControllerDelegate <NSObject>

-(void)turnNextController:(NSNumber*)lessonOfDay And:(NSNumber*)dayOfWeek;

@end
@interface XXYTimeTableView : UITableView

@property(nonatomic,weak)id<XXYturnNextControllerDelegate>turnNextControllerDelegate;

@property(nonatomic,copy) NSDictionary* firstClassDict;

+ (XXYTimeTableView *)contentTableView;

@property(nonatomic,assign)NSInteger index;

@property(nonatomic,retain)NSMutableArray*courseDataList;

-(void)addRefreshLoadMore;

@end

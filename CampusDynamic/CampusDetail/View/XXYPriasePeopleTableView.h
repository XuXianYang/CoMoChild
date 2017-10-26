//
//  XXYPriasePeopleTableView.h
//  点线
//
//  Created by 徐显洋 on 17/2/17.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XXYSendPriaseTableViewHightDataDelegate <NSObject>

-(void)sendPraisehight:(CGFloat)hight;

@end
@interface XXYPriasePeopleTableView : UITableView



+ (XXYPriasePeopleTableView *)contentTableView;
//添加刷新加载更多
- (void)addRefreshLoadMore;

@property(nonatomic,copy)NSString*actId;

@property(nonatomic,weak)id<XXYSendPriaseTableViewHightDataDelegate>sendDelegate;

@property(nonatomic,assign)NSInteger index;


@end

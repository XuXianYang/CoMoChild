//
//  XXYMyPraiseTableView.h
//  点线
//
//  Created by 徐显洋 on 17/2/21.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXYTurnNextPageDelegate <NSObject>


-(void)turnNextPage:(NSString*)dynamicId;

@end




@interface XXYMyPraiseTableView : UITableView
+ (XXYMyPraiseTableView *)contentTableView;
//添加刷新加载更多
- (void)addRefreshLoadMore;

@property(nonatomic,copy)NSString*getDataUrl;


@property(nonatomic,weak)id<XXYTurnNextPageDelegate>turnDelegate;


@end

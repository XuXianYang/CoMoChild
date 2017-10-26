//
//  BSTabBar.h
//  51微博分享
//
//  Created by zhangxueming on 16/4/11.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSTabBar;

@protocol BSTabBarDelegate <NSObject>

- (void)tabBarDidClicked:(BSTabBar *)tabBar selectedIndex:(NSInteger)selectedIndex;

@end


@interface BSTabBar : UIView

@property (nonatomic,copy)NSArray <UITabBarItem *>*items;

@property (nonatomic,weak)id <BSTabBarDelegate>delegate;

@end

//
//  UIView+XXYBageValue.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/11/22.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "UIView+XXYBageValue.h"

@implementation UIView (XXYBageValue)

//显示小红点
- (void)showViewBadgeOnItemIndex:(int)index{
    //移除之前的小红点
    [self removeViewBadgeOnItemIndex:index];
    
    //新建小红点
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = 222 + index;
    badgeView.layer.cornerRadius = 4;//圆形
    badgeView.backgroundColor = [UIColor redColor];//颜色：红色
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    CGFloat x = ceilf(tabFrame.size.width);
    CGFloat y = ceilf(0.4 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 8, 8);//圆形大小为10
    [self addSubview:badgeView];
}
//隐藏小红点
- (void)hideViewBadgeOnItemIndex:(int)index{
    //移除小红点
    [self removeViewBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeViewBadgeOnItemIndex:(int)index
{
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        if (subView.tag == 222+index) {
            [subView removeFromSuperview];
        }
    }
}

@end

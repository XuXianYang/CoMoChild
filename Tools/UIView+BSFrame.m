//
//  UIView+BSFrame.m
//  51微博分享
//
//  Created by zhangxueming on 16/4/12.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "UIView+BSFrame.h"

@implementation UIView (BSFrame)

- (CGFloat)X
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)X
{
    CGRect frame = self.frame;
    frame.origin.x = X;
    self.frame = frame;
}

- (CGFloat)Y
{
    return self.frame.origin.y;
}


- (void)setY:(CGFloat)Y
{
    CGRect frame = self.frame;
    frame.origin.y = Y;
    self.frame = frame;
}


- (CGFloat)W
{
    return self.frame.size.width;
}

- (void)setW:(CGFloat)W
{
    CGRect frame = self.frame;
    frame.size.width = W;
    self.frame = frame;
}

- (CGFloat)H
{
    return self.frame.size.height;
}

- (void)setH:(CGFloat)H
{
    CGRect frame = self.frame;
    frame.size.height= H;
    self.frame = frame;
}

@end

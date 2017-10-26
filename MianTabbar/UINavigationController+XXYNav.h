//
//  UINavigationController+XXYNav.h
//  点线
//
//  Created by 徐显洋 on 17/3/3.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (XXYNav)
/*
- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition;
- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition;
*/
- (void)pushViewControllerWithAnimation:(UIViewController*)controller;
- (void)popViewControllerWithAnimation;

@end

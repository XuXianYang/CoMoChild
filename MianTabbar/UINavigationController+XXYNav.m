//
//  UINavigationController+XXYNav.m
//  点线
//
//  Created by 徐显洋 on 17/3/3.
//  Copyright © 2017年 徐显洋. All rights reserved.
//

#import "UINavigationController+XXYNav.h"

@implementation UINavigationController (XXYNav)
- (void)pushViewControllerWithAnimation:(UIViewController*)controller
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.4];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self pushViewController:controller animated:NO];
    [self.view.layer addAnimation:animation forKey:nil];
    
}
- (void)popViewControllerWithAnimation
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.4];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];    
    [self popViewControllerAnimated:NO];
    [self.view.layer addAnimation:animation forKey:nil];
}

/*
- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition {
    
    [self pushViewController:controller animated:NO];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:YES];
    [UIView commitAnimations];
}

- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition {
    
    UIViewController* poppedController = [self popViewControllerAnimated:NO];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:NO];
    [UIView commitAnimations];
    
    return poppedController;
}
*/
@end

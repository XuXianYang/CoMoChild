//
//  XXYBackButton.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/10/8.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYBackButton.h"

@implementation XXYBackButton
+(XXYBackButton*)setUpBackButton
{
    
    XXYBackButton*btn=[XXYBackButton buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
    
    btn.frame=CGRectMake(0, 0, 30, 30);

    return btn ;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  XXYNullViewController.m
//  点线
//
//  Created by 徐显洋 on 16/12/7.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYNullViewController.h"

@interface XXYNullViewController ()

@end

@implementation XXYNullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView*imageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.clipsToBounds=YES;
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    imageView.image=[UIImage imageNamed:@"nullViewIcon"];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

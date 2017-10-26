//
//  XXYWebViewController.m
//  CoMoClassTeachers
//
//  Created by 徐显洋 on 16/11/3.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import "XXYWebViewController.h"
#import "XXYBackButton.h"
@interface XXYWebViewController ()

@end

@implementation XXYWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"官方网站";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIWebView *webView= [[UIWebView alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    [self.view addSubview:webView];
    NSString*urlString=@"http://www.comoclass.com";
    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 2.设置缓存策略(有缓存就用缓存，没有缓存就重新请求)
    request.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    
    webView.userInteractionEnabled=YES;
    webView.scrollView.scrollEnabled = YES;
    webView.scrollView.bounces=NO;
    [webView loadRequest:request];

}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
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

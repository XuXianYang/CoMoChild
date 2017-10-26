#import "XXYNavigationController.h"

@interface XXYNavigationController ()<UIGestureRecognizerDelegate>
@end
@implementation XXYNavigationController
+(void)initialize
{
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    1.先打印了导航控制器的interactivePopGestureRecognizer
//    NSLog(@"%@",self.interactivePopGestureRecognizer);
    
    //获取系统手势target对象
    
    id target = self.interactivePopGestureRecognizer.delegate;
    //创建移动手势,执行的方法是系统手势底层的方法
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    //禁止系统自带的手势
    self.interactivePopGestureRecognizer.enabled = NO;

}
//解决左划返回上一页与cell右划删除冲突的问题
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    // 打印touch到的视图
////    NSLog(@"%@", NSStringFromClass([touch.view class]));
////     如果视图为UITableViewCellContentView（即点击tableViewCell），则不截获Touch事件
////    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
////    {
////        return NO;
////    }
//    return  YES;
//}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // 首先判断otherGestureRecognizer是不是系统pop手势
    //NSLog(@"gestureRecognizer=%@",gestureRecognizer);
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UIScrollView")]) {
        UIScrollView*scroview=(UIScrollView*)otherGestureRecognizer.view;
        // 再判断系统手势的state是began还是fail，同时判断scrollView的位置是不是正好在最左边
    
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && scroview.contentOffset.x == 0)
        {
            return YES;
        }
    }
    
    return NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer*pan=(UIPanGestureRecognizer *)gestureRecognizer;
        ;
        if ([pan translationInView:self.view].y>0||[pan translationInView:self.view].y<0)
        {
            return NO;
        }
    }
    
    return self.childViewControllers.count==1?NO:YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

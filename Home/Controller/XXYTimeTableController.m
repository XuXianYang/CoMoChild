#import "XXYTimeTableController.h"
#import"XXYBackButton.h"
#import "BSHttpRequest.h"

#import "YXScrollMenu.h"
#import "XXYTimeTableView.h"
#import "XXYTimeTableModel.h"

@interface XXYTimeTableController ()
<YXScrollMenuDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) YXScrollMenu *menu;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger previousIndex;

@end

@implementation XXYTimeTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithRed:239.0/255 green:239.0/255 blue:244.0/255 alpha:1.0];
    self.navigationItem.title=@"课程表";
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];

    [self setUpSubViews];
    [self setUpSubTabViews];
}
-(void)setUpSubTabViews
{
    for(int i=0;i<5;i++)
    {
        XXYTimeTableView*timeTableView= [XXYTimeTableView contentTableView];
        timeTableView.frame=CGRectMake(_scrollView.frame.size.width*i+10, 10, _scrollView.frame.size.width-20, _scrollView.frame.size.height-20);
        timeTableView.backgroundColor=[UIColor whiteColor];
        timeTableView.bounces=NO;
        timeTableView.index=i+1;
        timeTableView.tag=i+1;
        timeTableView.showsVerticalScrollIndicator=NO;
        [timeTableView addRefreshLoadMore];
        [_scrollView addSubview:timeTableView];
    }
}
-(void)setUpSubViews
{
    YXScrollMenu *menu = [[YXScrollMenu alloc] initWithFrame:CGRectMake(15,15,MainScreenW-30, 50)];
    menu.backgroundColor=[UIColor purpleColor];
    menu.titleArray = @[@"星期一", @"星期二", @"星期三",@"星期四",@"星期五"];
    menu.cellWidth =(MainScreenW-30)/5;
    menu.delegate = self;
    menu.isHiddenSeparator = YES;
    menu.selectedTextColor=[UIColor whiteColor];
    menu.normalBackgroundColor=[UIColor whiteColor];
    menu.selectedBackgroundColor=[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0];
    [self.view addSubview:menu];
    
    _menu = menu;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 80, MainScreenW-30, 420)];
    //回弹
    scrollView.bounces=NO;
    //分页
    scrollView.pagingEnabled = YES;
    //横向滚动条
    scrollView.showsHorizontalScrollIndicator=NO;
    
    scrollView.backgroundColor=[UIColor whiteColor];
    
    scrollView.contentSize = CGSizeMake(menu.titleArray.count * (MainScreenW-30), 0);
    scrollView.delegate = self;
    scrollView.scrollEnabled=YES;
    
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
    
}
#pragma mark - YXScrollMenu delgate
- (void)scrollMenu:(YXScrollMenu *)scrollMenu selectedIndex:(NSInteger)selectedIndex
{
    [UIView animateWithDuration:0.2 * ABS(selectedIndex - _previousIndex)   animations:^{
        _scrollView.contentOffset = CGPointMake(selectedIndex * (MainScreenW-30), 0);
        
    }];
    
    _previousIndex = selectedIndex;
}
#pragma mark - UIScrollView delegate
//结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    _menu.currentIndex = scrollView.contentOffset.x / (MainScreenW-30);
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _menu.currentIndex = scrollView.contentOffset.x / (MainScreenW-30);
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //状态栏颜色为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
-(void)backClicked:(UIButton*)btn
{
    [self.navigationController popViewControllerWithAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

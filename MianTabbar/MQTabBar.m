//
//高仿微博
//作者：强子哥哥
//https://github.com/xieminqiang/weibo
//

#import "MQTabBar.h"
#import "UIImage+XXYImage.h"
#import "UIBarButtonItem+Extension.h"

#import "UIView+Extension.h"
#import "BSHttpRequest.h"
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

@interface MQTabBar()
@property (nonatomic, weak) UIButton *plusButton;
@end

@implementation MQTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!iOS7) {
            self.backgroundImage = [UIImage imageWithName:@"img-blak"];
            
        }
       self.backgroundImage = [UIImage imageWithName:@"img-blak"];
        self.selectionIndicatorImage = [UIImage imageWithName:@"navigationbar_button_background"];
        // 添加加号按钮
        [self setupPlusButton];
        
    }
    return self;
}

/**
 *  添加加号按钮
 */
- (void)setupPlusButton
{
    UIButton *plusButton = [[UIButton alloc] init];
    // 设置背景
//   [plusButton setBackgroundImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateNormal];
//    [plusButton setBackgroundImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateHighlighted];
    // 设置图标
    [plusButton setImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateNormal];
    [plusButton setImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateHighlighted];
    [plusButton addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
    // 添加
    [self addSubview:plusButton];
    self.plusButton = plusButton;
}

- (void)plusClick
{
    //HMLog(@"plusClick----");
    
    // 通知代理
    //取消上一次btn的选中状态
    _plusButton.selected = !_plusButton.isSelected;
    
    if(_plusButton.isSelected==YES)
    {
//        [_plusButton setBackgroundImage:[UIImage imageWithName:@"nav-safe-up"] forState:UIControlStateNormal];
//        [_plusButton setBackgroundImage:[UIImage imageWithName:@"nav-safe-up"] forState:UIControlStateHighlighted];
        [self getUpNewUserInfoData];
        
    }
    else
    {
        [_plusButton setImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateNormal];
        [_plusButton setImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateHighlighted];
//        [_plusButton setBackgroundImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateNormal];
//        [_plusButton setBackgroundImage:[UIImage imageWithName:@"nav-safe"] forState:UIControlStateHighlighted];

        if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
            [self.tabBarDelegate tabBarDidClicked:self selectedIndex:100];
        }
    }
}
-(void)getUpNewUserInfoData
{
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSDictionary*userInfoDict=[defaults objectForKey:@"joinClass"];
    
    if(userInfoDict[@"classId"]&&userInfoDict[@"schoolId"])
    {
        [_plusButton setImage:[UIImage imageWithName:@"nav-safe-up"] forState:UIControlStateNormal];
        [_plusButton setImage:[UIImage imageWithName:@"nav-safe-up"] forState:UIControlStateHighlighted];
        if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
            [self.tabBarDelegate tabBarDidClicked:self selectedIndex:101];
        }
      
    }
    else
        [BSHttpRequest GET:requestUrl parameters:@{@"sid":userSidString} success:^(id responseObject){
            
            //        NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSDictionary*dict=objString[@"data"][@"studentInfo"];
            NSUserDefaults *defaultss = [NSUserDefaults standardUserDefaults];
            [defaultss setObject:dict forKey:@"joinClass"];
            
            if(dict[@"classId"]&&dict[@"schoolId"])
            {
                [_plusButton setImage:[UIImage imageWithName:@"nav-safe-up"] forState:UIControlStateNormal];
                [_plusButton setImage:[UIImage imageWithName:@"nav-safe-up"] forState:UIControlStateHighlighted];
                if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
                    [self.tabBarDelegate tabBarDidClicked:self selectedIndex:101];
                }

            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
                    [self.tabBarDelegate tabBarDidClicked:self selectedIndex:102];
                }

            }
        } failure:^(NSError *error) {
        
            if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
                [self.tabBarDelegate tabBarDidClicked:self selectedIndex:103];
            }
        
        }];
}

/**
 *  布局子控件
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置plusButton的frame
    [self setupPlusButtonFrame];
    
    // 设置所有tabbarButton的frame
    [self setupAllTabBarButtonsFrame];
    
    self.backgroundColor=[UIColor whiteColor];
}

/**
 *  设置所有plusButton的frame
 */
- (void)setupPlusButtonFrame
{
    self.plusButton.size = CGSizeMake(60, 60);
    self.plusButton.center = CGPointMake(self.width * 0.5, self.height * 0.2+3);
}

/**
 *  设置所有tabbarButton的frame
 */
- (void)setupAllTabBarButtonsFrame
{
    int index = 0;
    
    // 遍历所有的button
    for (UIView *tabBarButton in self.subviews) {
        // 如果不是UITabBarButton， 直接跳过
        if (![tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) continue;
        
        // 根据索引调整位置
        [self setupTabBarButtonFrame:tabBarButton atIndex:index];
        
        // 索引增加
        index++;
    }
}

/**
 *  设置某个按钮的frame
 *
 *  @param tabBarButton 需要设置的按钮
 *  @param index        按钮所在的索引
 */
- (void)setupTabBarButtonFrame:(UIView *)tabBarButton atIndex:(int)index
{
    // 计算button的尺寸
    CGFloat buttonW = self.width / (self.items.count + 1);
    CGFloat buttonH = self.height;
    
    tabBarButton.width = buttonW;
    tabBarButton.height = buttonH;
    if (index >= 2) {
        tabBarButton.x = buttonW * (index + 1);
    } else {
        tabBarButton.x = buttonW * index;
    }
    tabBarButton.y = 0;
}
@end

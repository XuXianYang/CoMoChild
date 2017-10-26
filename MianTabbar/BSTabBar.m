//
//  BSTabBar.m
//  51微博分享
//
//  Created by zhangxueming on 16/4/11.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "BSTabBar.h"
#import "BSTabBarButton.h"


@interface BSTabBar ()

//添加按钮
@property (nonatomic,strong)UIButton *plusBtn;
//button数组
@property (nonatomic,retain)NSMutableArray <BSTabBarButton *>*buttons;
//记录被选中的button
@property (nonatomic,strong)UIButton *selectedButton;

@end


@implementation BSTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.plusBtn];
    }
    return self;
}

- (NSArray *)buttons
{
    if (_buttons==nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (UIButton *)plusBtn
{
    if (_plusBtn==nil) {
        _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_plusBtn setImage:[UIImage imageNamed:@"nav-safe"] forState:UIControlStateNormal];
       // [_plusBtn setBackgroundImage:[UIImage imageNamed:@"tabbar_compose_button"] forState:UIControlStateNormal];
        //[_plusBtn setImage:[UIImage imageNamed:@"nav-safe-up"] forState:UIControlStateHighlighted];
        
        //[_plusBtn setBackgroundImage:[UIImage imageNamed:@"nav-safe-up"] forState:UIControlStateSelected];
        //设置plueBtn大小
        [_plusBtn sizeToFit];
        [_plusBtn addTarget:self action:@selector(plusBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusBtn;
}

- (void)setItems:(NSArray<UITabBarItem *> *)items
{
    _items = items;
    NSInteger tagIndex = 0;
    for (UITabBarItem *item in items) {
        BSTabBarButton *btn = [BSTabBarButton buttonWithType:UIButtonTypeCustom];
        btn.item = item;
        btn.tag  = tagIndex;
        if (tagIndex == 0) {
            _selectedButton = btn;
            _selectedButton.selected = YES;
        }
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:btn];
        [self addSubview:btn];
        tagIndex++;
    }
}

- (void)btnClicked:(BSTabBarButton *)btn
{
    //取消上一次btn的选中状态
    _selectedButton.selected = NO;
    _selectedButton = btn;
    //设置当前选中状态的Btn
    _selectedButton.selected = YES;
    
    if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
        [self.delegate tabBarDidClicked:self selectedIndex:_selectedButton.tag];
    }
}

- (void)plusBtnClicked:(UIButton *)btn
{
    //取消上一次btn的选中状态
    _plusBtn.selected = !_plusBtn.isSelected;
    
    if(_plusBtn.isSelected==YES)
    {
        [_plusBtn setImage:[UIImage imageNamed:@"nav-safe-up"] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
            [self.delegate tabBarDidClicked:self selectedIndex:101];
        }

    }
    else
    {
        [_plusBtn setImage:[UIImage imageNamed:@"nav-safe"] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(tabBarDidClicked:selectedIndex:)]) {
            [self.delegate tabBarDidClicked:self selectedIndex:100];
        }

    }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = w / (self.items.count + 1);
    CGFloat btnH = self.bounds.size.height;
    //_plusBtn.frame=CGRectMake(0, 0, w*2, h*2);
    int i = 0;
    // 设置tabBarButton的frame
    for (UIView *tabBarButton in self.buttons) {
        if (i == 2) {
            i = 3;
        }
        btnX = i * btnW;
        tabBarButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
        i++;
    }
    
    _plusBtn.center = CGPointMake(w*0.5, 0.5*h);
}

@end

#import "YXScrollMenu.h"
#import "YXMenuModel.h"
#import "YXScrollMenuCell.h"
#import "UIView+Extension.h"

@interface YXScrollMenu () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) YXMenuModel *previousModel;

@end

@implementation YXScrollMenu

- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _selectedBackgroundColor = [UIColor purpleColor];
        _selectedTextColor = [UIColor orangeColor];
        _normalBackgroundColor = [UIColor lightGrayColor];
        
        // 添加子视图
        [self setUpSubviews];
    }
    return self;
}

- (void)setUpSubviews {
    CGFloat defaultWidth = 80.0f;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.height, self.width) style:UITableViewStylePlain];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = defaultWidth;
    tableView.bounces = NO;
    tableView.scrollEnabled=NO;
    tableView.center = CGPointMake(self.width / 2, self.height / 2);
    tableView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    tableView.showsVerticalScrollIndicator = NO;
    [self addSubview:tableView];
    
    _tableView = tableView;
    
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    
    for (int i = 0; i < _titleArray.count; i ++) {
        YXMenuModel *menuModel = [[YXMenuModel alloc] init];
        menuModel.selected = (i == 0) ? YES : NO;
        menuModel.text = _titleArray[i];
        
        [self.modelArray addObject:menuModel];
    }
    
    _previousModel = self.modelArray[0];
    
    [_tableView reloadData];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    
    [self refreshTableViewWithRow:currentIndex];
}

- (void)setCellWidth:(CGFloat)cellWidth {
    _cellWidth = cellWidth;
    
    _tableView.rowHeight = cellWidth;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXScrollMenuCell *cell = [YXScrollMenuCell cellWithTableView:tableView index:indexPath.row count:_titleArray.count];
    
    cell.scrollMenu = self;
    cell.menuModel = self.modelArray[indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self refreshTableViewWithRow:indexPath.row];
    
    if ([_delegate respondsToSelector:@selector(scrollMenu:selectedIndex:)]) {
        [_delegate scrollMenu:self selectedIndex:indexPath.row];
    }
}

- (void)refreshTableViewWithRow:(NSInteger)row {
    _previousModel.selected = NO;
    
    YXMenuModel *currentModel = self.modelArray[row];
    currentModel.selected = YES;
    
    _previousModel = currentModel;
    
    [self.tableView reloadData];
    
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}



@end

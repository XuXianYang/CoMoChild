#import "XXYCampusDynamicCell.h"
#import "XXYCampusDynamicFrame.h"
#import "XXYCampusToolsView.h"
#import "XXYCampusOrginalView.h"
#import "XXYCampusPictureView.h"
#import "XXYCampusDynamicModel.h"
@interface XXYCampusDynamicCell()<XXYOrginalPushDetailDelegate,XXYCampusToolsDelegate>

@property (nonatomic,weak)XXYCampusOrginalView *originalView;
@property (nonatomic,weak)XXYCampusPictureView *pictureView;
@property (nonatomic,weak)XXYCampusToolsView *toolView;

@end
@implementation XXYCampusDynamicCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setUpChildViews];
    }
    return self;
}
-(void)turnNextPage:(XXYCampusDynamicFrame*)campusFrame
{
    if([self.pushDelegate respondsToSelector:@selector(turnNextPageFromToolsView:)])
    {
        [self.pushDelegate turnNextPageFromToolsView:campusFrame];
    }
}
-(void)deleteMyDynamicAndreload:(NSString *)dynamicId
{
    if([self.pushDelegate respondsToSelector:@selector(deleteMyDynamicAndreload:)])
    {
        [self.pushDelegate deleteMyDynamicAndreload:dynamicId];
    }
}
- (void)setUpChildViews
{

    
    //添加原创视图
    XXYCampusOrginalView *originalView =[[XXYCampusOrginalView alloc] init];
    originalView.pushDelegate=self;
    [self addSubview:originalView];
    _originalView = originalView;
    
    //图片
    XXYCampusPictureView *pictureView = [[XXYCampusPictureView alloc] init];
    [self addSubview:pictureView];
    _pictureView = pictureView;
    
    //添加工具视图
    XXYCampusToolsView *toolView = [[XXYCampusToolsView alloc] init];
    toolView.turnDelegate=self;
    [self addSubview:toolView];
    _toolView = toolView;
}
-(void)setCampusFrame:(XXYCampusDynamicFrame *)campusFrame
{
    _campusFrame=campusFrame;
    
    _originalView.campusFrame=campusFrame;
    _originalView.frame=campusFrame.originalViewFrame;
    
    _pictureView.campusFrame=campusFrame;
    _pictureView.frame=campusFrame.pictureViewFrame;
    
    _toolView.campusFrame=campusFrame;
    _toolView.frame=campusFrame.toolsViewFrame;
    
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
       if(self.selTool)
    {
        self.toolView.hidden=YES;
        self.originalView.moreButton.hidden=YES;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

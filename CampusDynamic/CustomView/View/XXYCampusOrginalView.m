#import "XXYCampusOrginalView.h"
#import "XXYCampusDynamicFrame.h"
#import "XXYCampusDynamicModel.h"
#import "XXYCampusVideoButtonView.h"
#import <UIImageView+WebCache.h>
#import "HTCopyableLabel.h"
@interface XXYCampusOrginalView ()<HTCopyableLabelDelegate>

@property (nonatomic,strong)UIImageView * iconImageView;
@property (nonatomic,strong)UILabel *nickLabel;
@property (nonatomic,strong)UILabel *timeLabel;
@property (nonatomic,strong)HTCopyableLabel *textLabel;
@property (nonatomic,strong)XXYCampusVideoButtonView *videoButtonView;
@property (nonatomic, strong)  UIView  *labelContainer2;

@end

@implementation XXYCampusOrginalView
/*全局变量 */
static NSDateFormatter *fmt_;
static NSCalendar *calendar_;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpChildViews];
    }
    return self;
}
- (void)setUpChildViews
{
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.clipsToBounds=YES;
    _iconImageView.layer.cornerRadius=17.5;
    [self addSubview:_iconImageView];
    
    _nickLabel = [[UILabel alloc] init];
    _nickLabel.textColor=[UIColor darkGrayColor];
    [self addSubview:_nickLabel];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:_moreButton];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textColor=[UIColor lightGrayColor];
    [self addSubview:_timeLabel];
    
    _textLabel = [[HTCopyableLabel alloc] init];
    _textLabel.copyableLabelDelegate=self;
    [self.labelContainer2 addGestureRecognizer:_textLabel.longPressGestureRecognizer];
    _textLabel.numberOfLines = 0;
    [self addSubview:_textLabel];
    
    _videoButtonView=[[XXYCampusVideoButtonView alloc]init];
    [self addSubview:_videoButtonView];
}
#pragma mark - HTCopyableLabelDelegate

- (NSString *)stringToCopyForCopyableLabel:(HTCopyableLabel *)copyableLabel
{
    NSString *stringToCopy = @"";
    
     if (copyableLabel == self.textLabel)
    {
        stringToCopy = self.textLabel.text;
    }
    return stringToCopy;
}
- (CGRect)copyMenuTargetRectInCopyableLabelCoordinates:(HTCopyableLabel *)copyableLabel
{
    CGRect rect=CGRectZero;
    
    if(copyableLabel == self.textLabel)
    {
        // The UIMenuController will appear close to the label itself
        rect = copyableLabel.bounds;
    }
    return rect;
}
-(void)layoutSubviews
{
    [super layoutSubviews];    
    [_moreButton addTarget:self action:@selector(morebtnCliked) forControlEvents:
     UIControlEventTouchUpInside];
}
/**
 弹框
 */
- (void)morebtnCliked {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary*imUserInfo=[defaults objectForKey:@"userInfo"];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if([[NSString stringWithFormat:@"%@",self.campusFrame.dataModel.userId] isEqualToString:[NSString stringWithFormat:@"%@",imUserInfo[@"user"][@"id"]]])
    {
        [controller addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self deleteMyDynamic];
        }]];
    }
    [controller addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        SVProgressHUD.minimumDismissTimeInterval=1.0  ;
        SVProgressHUD.maximumDismissTimeInterval=1.5  ;
        [SVProgressHUD showSuccessWithStatus:@"举报成功"];
    }]];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}
-(void)deleteMyDynamic
{
    if([self.pushDelegate respondsToSelector:@selector(deleteMyDynamicAndreload:)])
    {
        [self.pushDelegate deleteMyDynamicAndreload:self.campusFrame.dataModel.dynamicId];
    }
}
-(void)setCampusFrame:(XXYCampusDynamicFrame *)campusFrame
{
    _campusFrame = campusFrame;
    //icon
    _iconImageView.frame = _campusFrame.originalIconFrame;
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:_campusFrame.dataModel.profile_image] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    //nickLabel
    
    _nickLabel.frame = _campusFrame.originalNickFrame;
    _nickLabel.font = [UIFont systemFontOfSize:15];
    _nickLabel.text = _campusFrame.dataModel.name;
    //vip
    
    //timeLabel
    _timeLabel.frame = _campusFrame.originalTimeFrame;
    _timeLabel.font = [UIFont systemFontOfSize:13];
    _timeLabel.text = [self created_at:_campusFrame.dataModel.created_at];
    
    //sourceLabel
    _moreButton.frame = _campusFrame.originalMoreBtnFrame;
    
    [_moreButton setImage:[UIImage imageNamed:@"school_content_more"] forState:UIControlStateNormal];
    //textLabel
    _textLabel.frame = _campusFrame.originalTextFrame;
    _textLabel.font = [UIFont systemFontOfSize:16];
    _textLabel.text = _campusFrame.dataModel.text;
    
    _videoButtonView.frame=_campusFrame.videoButtonFrame;
    _videoButtonView.videoUrl=campusFrame.dataModel.vedioUrl;
}
/**
 只调用一次
 */
+(void)initialize
{
    fmt_ = [[NSDateFormatter alloc] init];
    calendar_ = [NSCalendar gf_calendar];
}

/**
 日期处理get方法
 */
-(NSString *)created_at:(NSString*)_created_at
{
    //将服务器返回的数据进行处理
    fmt_.dateFormat = @"yyyy-MM-dd HH-mm-ss";
    NSDate *creatAtDate = [fmt_ dateFromString:_created_at];
    //    NSLog(@"_created_at=%@",_created_at);
    //判断
    if (creatAtDate.isThisYear) {//今年
        if ([calendar_ isDateInToday:creatAtDate]) {//今天
            //当前时间
            NSDate *nowDate = [NSDate date];
            
            NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *comps = [calendar_ components:unit fromDate:creatAtDate toDate:nowDate options:0];
            
            if (comps.hour >= 1) {
                return [NSString stringWithFormat:@"%zd小时前",comps.hour];
            }else if (comps.minute >= 1){
                return [NSString stringWithFormat:@"%zd分钟前",comps.minute];
            }else
            {
                return @"刚刚";
            }
            
        }else if ([calendar_ isDateInYesterday:creatAtDate]){//昨天
            fmt_.dateFormat = @"昨天 HH:mm:ss";
            return [fmt_ stringFromDate:creatAtDate];
            
        }else{//其他
            fmt_.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt_ stringFromDate:creatAtDate];
        }
    }else{//非今年
        return _created_at;
    }
    return _created_at;
}

/**
 今年
 今天
 时间间隔 >= 一个小时 @“5小时前”
 1分钟 > 时间间隔 >= 1分钟  @"10分钟前"
 1分钟 < 时间间隔  @“刚刚”
 昨天
 @“昨天 23:13:02”
 其他
 @“10-13 12:13:02”
 
 非今年
 @“2015-02-10 08:09:10”
 */
@end

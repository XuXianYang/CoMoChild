#import "XXYCampusToolsView.h"
#import "XXYCampusDynamicFrame.h"
#import "XXYCampusDynamicModel.h"
#import "XXYPublishDynamicController.h"
#import "BSHttpRequest.h"
#import "XXYCamDyDetailController.h"
@interface XXYCampusToolsView ()<XXYReloadNewDataDelegate>

@property (nonatomic,strong)UIImageView * horizontalLineView;
@property (nonatomic,strong)UIImageView *verticalLineView;
@property (nonatomic,strong)UIButton *praiseButton;
@property (nonatomic,strong)UIButton *commentButton;

@end

@implementation XXYCampusToolsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpChildViews];
    }
    return self;
}
- (void)setUpChildViews
{
    _horizontalLineView = [[UIImageView alloc] init];
    _horizontalLineView.image=[UIImage imageNamed:@"cell-content-line"];
    [self addSubview:_horizontalLineView];
    
    _verticalLineView = [[UIImageView alloc] init];
    _verticalLineView.image=[UIImage imageNamed:@"cell-button-line"];
    [self addSubview:_verticalLineView];
    
    _praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _praiseButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [_praiseButton addTarget:self action:@selector(btnCliked:) forControlEvents:
     UIControlEventTouchUpInside];
    [self addSubview:_praiseButton];
    
    _commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.titleLabel.font=[UIFont systemFontOfSize:14];
    [_commentButton setImage:[UIImage imageNamed:@"mainCellComment"] forState:UIControlStateNormal];
    [_commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_commentButton addTarget:self action:@selector(btnCliked:) forControlEvents:
     UIControlEventTouchUpInside];
    [self addSubview:_commentButton];
}
-(void)setCampusFrame:(XXYCampusDynamicFrame *)campusFrame
{
    _campusFrame = campusFrame;
    
    _horizontalLineView.frame = _campusFrame.horizontalLineViewFrame;
    _verticalLineView.frame=_campusFrame.verticalLineViewFrame;
    
    _praiseButton.frame=_campusFrame.praiseButtonFrame;
    _commentButton.frame=_campusFrame.commentButtonFrame;
    
    [self setUpButton:_praiseButton number:campusFrame.dataModel.ding placeholder:@"顶"];
    [self setUpButton:_commentButton number:campusFrame.dataModel.comment placeholder:@"评论"];
    
    if(campusFrame.dataModel.isZan4Me==1)
    {
        [_praiseButton setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateNormal];
        [_praiseButton setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
    }
    else
    {
        [_praiseButton setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
        [_praiseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}
/**
 设置按钮数字
 */
-(void)setUpButton:(UIButton *)button number:(NSInteger)number placeholder:(NSString *)placeholder
{
    if (number >= 10000)
    {
        [button setTitle:[NSString stringWithFormat:@"%.1f万",number / 10000.0] forState:UIControlStateNormal];
    }
    else if (number > 0)
    {
        [button setTitle:[NSString stringWithFormat:@"%zd",number] forState:UIControlStateNormal];
    }
    else
    {
        [button setTitle:placeholder forState:UIControlStateNormal];
    }
}
-(void)btnCliked:(UIButton*)btn
{
    if(btn==self.praiseButton)
    {
        self.campusFrame.dataModel.isZan4Me=!self.campusFrame.dataModel.isZan4Me;
        if(self.campusFrame.dataModel.isZan4Me)
        {
            [self priase];
        }
        
        else
        {
            [self canclePriase];
            //NSLog(@"取消赞");
        }
    }
    if(btn==self.commentButton)
    {
        if(self.campusFrame.dataModel.comment==0)
        {
            XXYPublishDynamicController*pubCon=[[XXYPublishDynamicController alloc]init];
            pubCon.reloadDelegate=self;
            pubCon.index=1;
            pubCon.actId=self.campusFrame.dataModel.dynamicId;
            [self.window.rootViewController presentViewController:pubCon animated:YES completion:nil];
        }
        else
        {
            if([self.turnDelegate respondsToSelector:@selector(turnNextPage:)])
            {
                [self.turnDelegate turnNextPage:self.campusFrame];
            }
            
        }
    }
}

-(void)reloadNewDataOfPublished
{
    self.campusFrame.dataModel.comment++;
    
    if([self.commentButton.titleLabel.text isEqualToString:@"评论"])
    {
        [self setUpButton:self.commentButton number:1 placeholder:@"评论"];
    }
    else
    {
        [self setUpButton:self.commentButton number:[self.commentButton.titleLabel.text  integerValue]+1 placeholder:@"评论"];
    }
    
}
-(void)priase
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/saveZan"];
    
    if(self.campusFrame.dataModel.dynamicId)
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"actId":self.campusFrame.dataModel.dynamicId} success:^(id responseObject){
            
            //         NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                self.campusFrame.dataModel.ding++;
                self.campusFrame.dataModel.isZan4Me=YES;
                [self.praiseButton setImage:[UIImage imageNamed:@"mainCellDingClick"] forState:UIControlStateNormal];
                if([self.praiseButton.titleLabel.text isEqualToString:@"顶"])
                {
                    [self setUpButton:self.praiseButton number:1 placeholder:@"顶"];
                }
                else
                {
                    [self setUpButton:self.praiseButton number:[self.praiseButton.titleLabel.text  integerValue]+1 placeholder:@"顶"];
                }
                [self.praiseButton setTitleColor:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
            }
            else if([objString[@"message"] hasPrefix:@"只能赞一次"]&&[codeString isEqualToString:@"9112"])
            {
                [self setUpAlertController:@"只能赞一次哦"];
            }
            else
            {
                [self setUpAlertController:@"赞失败,稍后再试!"];
            }
        } failure:^(NSError *error) {
            [self setUpAlertController:@"赞失败,稍后再试!"];
        }];
    
    else
    {
        [self setUpAlertController:@"赞失败,稍后再试!"];
    }
}
-(void)setUpAlertController:(NSString*)str
{
    UIAlertController*alertCon = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [action setValue:[UIColor colorWithRed:248.0/255 green:143.0/255 blue:51.0/255 alpha:1.0] forKey:@"titleTextColor"];
    [alertCon addAction:action];
    [self.window.rootViewController presentViewController:alertCon animated:YES completion:nil];
}

-(void)canclePriase
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString*userSidString=[defaults objectForKey:@"userSid"];
    NSString*requestUrl=[NSString stringWithFormat:@"%@%@",BaseUrl,@"/student/pg/removeZan"];
    
    if(self.campusFrame.dataModel.dynamicId)
        [BSHttpRequest POST:requestUrl parameters:@{@"sid":userSidString,@"actId":self.campusFrame.dataModel.dynamicId} success:^(id responseObject){
            
            //         NSLog(@"Success: %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            
            id objString = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *codeString=[NSString stringWithFormat:@"%@",objString[@"code"]];
            
            if([objString[@"message"] isEqualToString:@"success"])
            {
                self.campusFrame.dataModel.ding--;
                self.campusFrame.dataModel.isZan4Me=NO;
                [self.praiseButton setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
                [self setUpButton:self.praiseButton number:[self.praiseButton.titleLabel.text  integerValue]-1 placeholder:@"顶"];
                [self.praiseButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            else if([objString[@"message"] hasPrefix:@"只能赞一次"]&&[codeString isEqualToString:@"9112"])
            {
                [self setUpAlertController:@"已经取消赞了!"];
            }
            else
            {
                [self setUpAlertController:@"取消赞失败,稍后再试!"];
            }
        } failure:^(NSError *error) {
            
            [self setUpAlertController:@"取消赞失败,稍后再试!"];
        }];
    
    else
        [self setUpAlertController:@"取消赞失败,稍后再试!"];
    
}

@end

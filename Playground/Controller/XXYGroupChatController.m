#import "XXYGroupChatController.h"
#import "XXYBackButton.h"
@interface XXYGroupChatController ()
@end
@implementation XXYGroupChatController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navBg"]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    XXYBackButton*backButton=[XXYBackButton setUpBackButton];
    [backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.enableUnreadMessageIcon=YES;
            //设置进入聊天室需要获取的历史消息数量（仅在当前会话为聊天室时生效）
    self.defaultHistoryMessageCountOfChatRoom=50;
    // 当收到的消息超过一个屏幕时，进入会话之后，是否在右上角提示上方存在的未读消息数
    self.enableUnreadMessageIcon=YES;
    //滚动到列表最下方是否开启动画效果
    [self scrollToBottomAnimated:YES];
    //NSLog(@"111-%i",chat.unReadMessage);
    //收到的消息是否显示发送者的名字
    self.displayUserNameInCell=YES;
    [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
}
- (void)fuctionYouWillLeave
{
    //在您即将离开界面时，比如点击navigationbar左键时，
    //调用一下RCConversationViewController的leftBarButtonItemPressed方法。
    [super leftBarButtonItemPressed:nil];
}
-(void)backClicked:(UIButton*)btn
{
    if(self.isPush)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self fuctionYouWillLeave];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

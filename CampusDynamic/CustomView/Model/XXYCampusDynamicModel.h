#import <Foundation/Foundation.h>

@interface XXYCampusDynamicModel : NSObject

/*userId*/
@property (nonatomic, copy) NSString *userId;
//我是否赞过
@property (nonatomic, assign) BOOL isZan4Me;
/** id */
@property (nonatomic, copy) NSString *dynamicId;
/** 用户的名字 */
@property (nonatomic, copy) NSString *name;
/** 用户的头像 */
@property (nonatomic, copy) NSString *profile_image;
/** 帖子的文字内容 */
@property (nonatomic, copy) NSString *text;
/** 帖子审核通过的时间 */
@property (nonatomic, copy) NSString *created_at;
/** 顶数量 */
@property (nonatomic, assign) NSInteger ding;
/** 评论数量 */
@property (nonatomic, assign) NSInteger comment;
/** 视频播放的url地址 */
@property (nonatomic,copy) NSString *vedioUrl;
///** 音频的url */
//@property (nonatomic,copy) NSString *voiceuri;
/*****额外增加的属性*****/
/** cell高度 */
//@property (nonatomic, assign) CGFloat cellHeight;
/** 中间内容的Frame */
@property (nonatomic, assign) CGRect middleF;
/** 视频按钮的Frame */
@property (nonatomic, assign) CGRect videoBtnFrame;

//多图的情况
@property (nonatomic, assign) BOOL is_morePic;
@property (nonatomic, assign) NSInteger picCount;
@property(nonatomic,retain)NSArray*imageArray;

@end

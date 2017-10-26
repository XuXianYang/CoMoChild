#import <Foundation/Foundation.h>

@interface XXYCommentModel : NSObject
/*
{
    "id": 52,
    "actId": 88,
    "srcId": 51,
    "content": "敢不敢与哥一战",
    "createdAt": "Feb 17, 2017 5:56:04 PM",
    "srcDto":
    {
        "id": 51,
        "username": "13112312312",
        "mobileNo": "13112312312",
        "realName": "陈世明",
        "avatarUrl": "http://oci9mtj7o.bkt.clouddn.com/user/51/avatar/00f40997-4cbf-4f23-ac32-c355d8905a89/avatar.png"
    },
    "strCreatedAt": "2017-02-17 17:56"
}
*/
@property(nonatomic,copy)NSString*ID;
@property(nonatomic,copy)NSString*actId;
@property(nonatomic,copy)NSString*srcId;
@property(nonatomic,copy)NSString*content;
@property(nonatomic,copy)NSString*createdAt;
@property(nonatomic,copy)NSString*username;
@property(nonatomic,copy)NSString*realName;
@property(nonatomic,copy)NSString*avatarUrl;

/** cell高度 */
@property (nonatomic, assign) CGFloat cellHeight;


@end

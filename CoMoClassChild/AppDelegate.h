//
//  AppDelegate.h
//  点线
//
//  Created by 徐显洋 on 16/9/20.
//  Copyright © 2016年 徐显洋. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

static NSString *appKey = @"cffa630f53017b07c16bbe18";
static NSString *channel = @"App Store";
static BOOL isProduction = true;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;
-(void)showWindowHome:(NSString *)windowType;

-(void)setUpLogOutAppAlert;


@end


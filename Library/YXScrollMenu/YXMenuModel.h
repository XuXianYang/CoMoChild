//
//  YXMenuModel.h
//  YXScrollMenuDemo
//
//  Created by Yangxin on 16/3/29.
//  Copyright © 2016年 51Baishi.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YXMenuModel : NSObject

/**
 *  文字
 */
@property (nonatomic, strong) NSString *text;

/**
 *  是否被选中
 */
@property (nonatomic, assign, getter=isSelected) BOOL selected;


@end

//
//  CustomPlayerView.m
//  01_自定义视频控制器
//
//  Created by Yangxin on 16/3/30.
//  Copyright © 2016年 51Baishi.net. All rights reserved.
//

#import "CustomPlayerView.h"
// 一个视图需要播放视频, 那么它的layer必须是AVPlayerLayer
// 还需要为这个layer指定一个视频播放对象。
@implementation CustomPlayerView

#pragma mark 重写返回layer的一个方法
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    _player = player;
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    
    playerLayer.player = player;
}



@end

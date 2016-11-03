//
//  AVPlayerView.m
//  calcalist
//
//  Created by ido meirov on 18/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import "GAAVPlayerView.h"

@implementation GAAVPlayerView

+(Class)layerClass{
    
    return [AVPlayerLayer class];
}

-(AVPlayer *)player{
    
    return [(AVPlayerLayer*)[self layer] player];
}

-(void)setPlayer:(AVPlayer *)player{
    
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

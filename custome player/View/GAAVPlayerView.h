//
//  AVPlayerView.h
//  calcalist
//
//  Created by ido meirov on 18/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface GAAVPlayerView : UIView
//Needed for hold the controller in string refernce need to release when player not in use
@property (strong,nonatomic) id controllerProtocol;

-(void)setPlayer:(AVPlayer *)player;

-(AVPlayer *)player;

- (void)setVideoFillMode:(NSString *)fillMode;

@end

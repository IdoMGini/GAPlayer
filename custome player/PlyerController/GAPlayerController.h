//
//  AVCustomPlayerController.h
//  calcalist
//
//  Created by ido meirov on 18/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//


#import "GAAVPlayerView.h"
#import "GAView.h"

typedef enum {
    
    GAPlayerControllerModeDefault,
    GAPlayerControllerModeSmall,
    GAPlayerControllerModeFullScreen,
    GAPlayerControllerModeMinimize,
    
}GAPlayerControllerMode;

typedef enum {
 
    GAPlayerControllerActionTypePlay,
    GAPlayerControllerActionTypePause,
    GAPlayerControllerActionTypeEnterFullScreen,
    GAPlayerControllerActionTypeExitFullScreen,
    
}GAPlayerControllerActionType;

@protocol GAPlayerControllerDelegate <NSObject>

@optional

- (void)player:(nullable AVPlayer *)player didFinishPlayingItem:(nullable AVPlayerItem *)playerItem;
- (void)player:(nullable AVPlayer *)player didFailToLoadItem:(nullable AVPlayerItem *)playerItem withError:(nullable NSError *)error;

- (BOOL)player:(nullable AVPlayer *)player ShouldTogglePlayPauseAction:(GAPlayerControllerActionType)action;
- (BOOL)player:(nullable AVPlayer *)player ShouldToggleFullScreenAction:(GAPlayerControllerActionType)action;

@end

typedef void (^AnimationCompletion)();

extern NSString * _Nonnull const AVCustomPlayerWillExitFullscreenNotification;
extern NSString * _Nonnull const AVCustomPlayerWillEnterFullscreenNotification;


@interface GAPlayerController : NSObject <GAViewDelegate>


@property (nonatomic,nullable,copy) UIColor * barColor; // bars backgrund color can be change with set
@property (nonatomic,nullable,copy) UIColor *textColor; // label text color can be change with set
@property (nonatomic,nullable,copy) UIColor *tintColor; // buttons tint color can be change with set also change the button images color

@property (nonatomic,readonly) GAPlayerControllerMode currentMode;
@property (nonatomic,readonly) BOOL isFullScreen;
@property (nonatomic,assign)   BOOL topToolBarHidden;
@property (nonatomic,assign)   BOOL bottomToolBarHidden;
@property (nonatomic,assign)   BOOL enableMinimaize; // default NO;

@property (nonatomic,assign)   CGRect minimazeFrame; //default MINIMAZE_FRAME(window)

@property (nonatomic,readonly,nullable) AVPlayer *player;

@property (nonatomic,nullable,weak) id<GAPlayerControllerDelegate> delegate;

// add the player view to selcted superView with add subView
- (void)addPlayerToSuperview:(nullable UIView *)superView withItemURL:(nullable NSURL *)URLObject targetFrame:(CGRect)frame;
- (void)addPlayerToSuperview:(nullable UIView *)superView withItemURL:(nullable NSURL *)URLObject; //set fame to default (window frame)

- (void)play;
- (void)pause;

- (void)forward;
- (void)backward;

- (void)removePlyer;

- (void)replaceCurrentItemWithUrl:(nullable NSURL *)url;

- (void)replaceCurrentItemWithItem:(nullable AVPlayerItem *)playerItem;

- (nullable AVPlayerItem *)currentItem;

- (void)toggleFullScreenWithCompletion:(nullable AnimationCompletion)completion;

- (void)exitFullScreenWithAnimationAndCompletion:(nullable AnimationCompletion)completion;

- (void)enterFullScreenWithAniamtionAndCompletion:(nullable AnimationCompletion)completion;

- (void)enterMinimizeWithAnimationAndCompletion:(nullable AnimationCompletion)completion ToSuperView:(nullable UIView *)superView;

@end

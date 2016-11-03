//
//  AVCustomPlayerController.m
//  calcalist
//
//  Created by ido meirov on 18/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import "GAPlayerController.h"
#import "UIView+Constraints.h"
#import "UIView+GAAnimations.h"
#import "GADragController.h"

#define NIB_NAME @"AVCustomPlayerController"

#define PAUSE_ICON_NAME         @"moviePause.png"
#define PLAY_ICON_NAME          @"moviePlay.png"
#define FULL_SCREEN_ICON_NAME   @"movieFullscreen.png"
#define FORWARD_ICON_NAME       @"FastForward"
#define BACKWARD_ICON_NAME      @"Rewind"

#define ANIMATION_DURATION     0.3
#define FADE_DELAY             5.0

#define IS_IPHONE_5_AND_BEFORE          CGRectGetWidth([[UIScreen mainScreen] bounds]) < 375

#define MINIMAZE_WIDTH         120.0f
#define MINIMAZE_HEIGHT        80.0f
#define MINIMAZE_MARGIN        30.0f
#define MINIMAZE_FRAME(window) CGRectMake(CGRectGetMaxX(window.frame) - (MINIMAZE_WIDTH + MINIMAZE_MARGIN), CGRectGetMaxY(window.frame) - (MINIMAZE_HEIGHT + MINIMAZE_MARGIN + 44.0f), MINIMAZE_WIDTH, MINIMAZE_HEIGHT)

NSString * _Nonnull const AVCustomPlayerWillExitFullscreenNotification  = @"AVCustomPlayerWillExitFullscreenNotification";
NSString * _Nonnull const AVCustomPlayerWillEnterFullscreenNotification = @"AVCustomPlayerWillEnterFullscreenNotification";
NSString * _Nonnull const AVCustomPlayerDidChangeSreenModeNotification  = @"AVCustomPlayerDidChangeSreenModeNotification";

@interface GAPlayerController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic)     UIView          *mainViewOriginalParentView;
@property (assign, nonatomic)   CGRect          mainViewOriginalFrame;
@property (strong, nonatomic)   GAAVPlayerView    *avPlayerView;
@property (nonatomic,strong,nullable,readwrite)   GAView  *gaView;

@property (assign, nonatomic)   GAPlayerControllerMode currentMode;

@property (assign, nonatomic)   BOOL isPlaying;
@property (assign, nonatomic)   BOOL isSeeking;
@property (assign, nonatomic)   BOOL isShowingToolBars;

@property (strong,nonatomic,readwrite)   AVPlayer *player;

@property (strong,nonatomic) GADragController *dragController;


@end

@implementation GAPlayerController
@synthesize currentMode = currentMode;



-(void)initialize{
    
    [self setGaView:[[GAView alloc] init]];
    [[self gaView] setDelegate:self];
    [self setBarColor:[UIColor colorWithRed:195/255.0 green:29/255.0 blue:29/255.0 alpha:0.5]];
    [self setTextColor:[UIColor whiteColor]];
    [self setTintColor:[UIColor lightTextColor]];
    [self setIsPlaying:NO];
    [self setIsShowingToolBars:YES];
    [self setDragController:[[GADragController alloc] init]];
    [self setEnableMinimaize:NO];
    [self setMinimazeFrame:MINIMAZE_FRAME([[[UIApplication sharedApplication] delegate] window])];

    [[[self gaView] singelTapGestureRecognizer] requireGestureRecognizerToFail:[[self gaView] doubleTapGestureRecognizer]];
}

-(void)dealloc{
    
    [self setDragController:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removePlyer];
}

#pragma mark - Public

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)addPlayerToSuperview:(nullable UIView *)superView withItemURL:(nullable NSURL *)URLObject{
    
    CGRect frame = [[[[UIApplication sharedApplication] delegate] window] frame];
    [self addPlayerToSuperview:superView WithPlayer:[AVPlayer playerWithURL:URLObject] targetFrame:frame andPlayerControllerMode:GAPlayerControllerModeDefault];
}

-(void)addPlayerToSuperview:(nullable UIView *)superView withItemURL:(nullable NSURL *)URLObject targetFrame:(CGRect)frame{
    
    [self addPlayerToSuperview:superView WithPlayer:[AVPlayer playerWithURL:URLObject] targetFrame:frame andPlayerControllerMode:GAPlayerControllerModeSmall];
    
}

-(void)addPlayerToSuperview:(UIView *)superView WithPlayer:(AVPlayer *)player targetFrame:(CGRect)frame{
    
    [self addPlayerToSuperview:superView WithPlayer:player targetFrame:frame andPlayerControllerMode:GAPlayerControllerModeSmall];
}

-(void)setViewFrame:(CGRect)frame InSuperView:(UIView *)superView{
    
    if ([self gaView]) {
        
        [[self gaView] setFrame:frame];
        
        [self setMainViewOriginalFrame:frame];
        [self setMainViewOriginalParentView:superView];
        
        if (IS_IPHONE_5_AND_BEFORE) {
            
            [[[self gaView] bottomSliderWidthConstrintForIphone6Up] setActive:NO];
            [[[self gaView] bottomSliderWidthConstrintForIphone5AndDown] setActive:YES];
            
            [[[self gaView] topSliderWidthConstrintForIphone6Up] setActive:NO];
            [[[self gaView] topSliderWidthConstrintForIphone5AndDown] setActive:YES];
            
        }
        else{
            [[[self gaView] bottomSliderWidthConstrintForIphone6Up] setActive:YES];
            [[[self gaView] bottomSliderWidthConstrintForIphone5AndDown] setActive:NO];
            
            [[[self gaView] topSliderWidthConstrintForIphone6Up] setActive:YES];
            [[[self gaView] topSliderWidthConstrintForIphone5AndDown] setActive:NO];
        }
        
        [superView addSubview:[self gaView]];
    }
    
}

-(void)play{
    
    if ([self player]) {
        
        [[self  player] play];
        
        [self setIsPlaying:YES];
        
        [self setPlayButtonMode];
        
    }
}

-(void)pause{
    
    if ([self player]) {
        
        [[self player] pause];
        
        [self setIsPlaying:NO];
        
        [self setPlayButtonMode];
        
    }
    
}

-(void)replaceCurrentItemWithUrl:(NSURL *)url{
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    [self replaceCurrentItemWithItem:item];
    
}

-(void)replaceCurrentItemWithItem:(AVPlayerItem *)playerItem{
    
    [[[self player] currentItem] removeObserver:self forKeyPath:@"status" context:nil];
    
    [[self player] replaceCurrentItemWithPlayerItem:playerItem];
    
    [[[self gaView] activityIndicatorView] startAnimating];
    
    [[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
}

-(AVPlayerItem *)currentItem{
    
    return [[self player] currentItem];
}

-(void)forward{
    
    AVPlayer *player = [self player];
    
    if ([[player currentItem] canPlayFastForward]) {
        
        [player setRate:[player rate] + 1];
    }
}

-(void)backward{
    
    AVPlayer *player = [self player];
    
    CGFloat currantRate = [player rate];
    if (currantRate > 1 && [[player currentItem] canPlaySlowForward]) {
        
        [player setRate:currantRate - 1];
    }
    else if ([[player currentItem] canPlayFastReverse]) {
        if (currantRate == 1) {
            currantRate = 0;
        }
        [player setRate:currantRate -1];
    }
}

//override isFullScreen
-(BOOL)isFullScreen {
    
    if (![self player]) {
        return NO;
    }
    
    switch ([self currentMode]) {
        case GAPlayerControllerModeSmall:
            return NO; break;
            
        case GAPlayerControllerModeDefault:
            return YES; break;
            
        case GAPlayerControllerModeFullScreen:
            return YES; break;
            
        case GAPlayerControllerModeMinimize:
            return NO; break;
    }
}

-(void)removePlyer{
    
    if ([self gaView]) {
        
        [self pause];
        [[self avPlayerView] setControllerProtocol:nil];
        [[self avPlayerView] removeFromSuperview];
        
        [[[self player] currentItem] removeObserver:self forKeyPath:@"status" context:nil];
        
        [self setPlayer:nil];
        [self setAvPlayerView:nil];
        [[self gaView] removeFromSuperview];
        
    }
}

#pragma mark - EnableMinimaize

-(void)setEnableMinimaize:(BOOL)enableMinimaize{
  
    _enableMinimaize = enableMinimaize;
    
    [[[self gaView] panGestureRecognizer] setEnabled:enableMinimaize];
}

#pragma mark - Hidden Tool Bars

-(void)setTopToolBarHidden:(BOOL)topToolBarHidden{

    _topToolBarHidden = topToolBarHidden;
    
    [[[self gaView] fullScreenTopTollBarView] setHidden:topToolBarHidden];
}

-(void)setBottomToolBarHidden:(BOOL)bottomToolBarHidden{
    
    _bottomToolBarHidden = bottomToolBarHidden;
    
    [[[self gaView] bottomToolBarView] setHidden:bottomToolBarHidden];
    [[[self gaView] fullScreenBottomtoolBarView] setHidden:bottomToolBarHidden];
}

#pragma mark - color manger

-(void)setBarColor:(UIColor *)barColor{
    
    if (_barColor != barColor) {
        
        _barColor = barColor;
        
        [[[self gaView] fullScreenTopTollBarView] setBackgroundColor:barColor];
        [[[self gaView] bottomToolBarView] setBackgroundColor:barColor];
        [[[self gaView] fullScreenBottomtoolBarView] setBackgroundColor:barColor];
    }
    
    
}

-(void)setTintColor:(UIColor *)tintColor{
    
    if (_tintColor != tintColor) {
        
        _tintColor = tintColor;
        
        [[[self gaView] playButton] setTintColor:tintColor];
        [[[self gaView] fullScreenButton] setTintColor:tintColor];
        [[[self gaView] fullScreenPlayButton] setTintColor:tintColor];
        [[[self gaView] seekForwardButton] setTintColor:tintColor];
        [[[self gaView] seekBackwardButton] setTintColor:tintColor];
        [[[self gaView] fullScreenDoneButton] setTintColor:tintColor];
        [[[self gaView] fullScreenDoneButton] setTitleColor:tintColor forState:UIControlStateNormal];
    }
}

-(void)setTextColor:(UIColor *)textColor{
    
    if (_textColor != textColor) {
        
        _textColor = textColor;
        
        [[[self gaView] timePassLabel] setTextColor:textColor];
        [[[self gaView] timeRemainingLabel] setTextColor:textColor];
        [[[self gaView] fullScreenPassLabel] setTextColor:textColor];
        [[[self gaView] fullScreentimeRemainingLabel] setTextColor:textColor];
    }
}



#pragma mark - Privet

-(void)addPlayerToSuperview:(UIView *)superView WithPlayer:(AVPlayer *)player targetFrame:(CGRect)frame andPlayerControllerMode:(GAPlayerControllerMode)mode{
    
    [self setCurrentMode:mode];
    [self playerDidChangeMode];
    
    [self setViewFrame:frame InSuperView:superView];
    
    [self updateButtons];
    
    [self setAVPlayerViewWithPlayer:player];
    
    [[self gaView] layoutIfNeeded];

    
    [self performSelector:@selector(hidePlyerControlsWithCompletion:) withObject:nil afterDelay:FADE_DELAY];
}


-(void)updateButtons{
    
    [self setPlayButtonMode];
    
    [[[self gaView] airPlayButton] setShowsVolumeSlider:NO];
    [[[self gaView] airPlayButton] setShowsRouteButton:YES];
    
    [[[self gaView] fullScreenAirPlayButton] setShowsVolumeSlider:NO];
    [[[self gaView] fullScreenAirPlayButton] setShowsRouteButton:YES];
    
    [[[self gaView] fullScreenButton] setImage:[[UIImage imageNamed:FULL_SCREEN_ICON_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [[[self gaView] seekForwardButton] setImage:[[UIImage imageNamed:FORWARD_ICON_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [[[self gaView] seekBackwardButton] setImage:[[UIImage imageNamed:BACKWARD_ICON_NAME] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
}

-(void)setAVPlayerViewWithPlayer:(AVPlayer *)player{
    
    if (![self avPlayerView]) {
        
        [self setAvPlayerView:[[GAAVPlayerView alloc] initWithFrame:self.gaView.frame]];
        [[[self gaView] playerContinerView] insertSubview:[self avPlayerView] atIndex:0];
        
        [UIView addViewConstraintsForTopLevelView:[self avPlayerView] superView:[[self gaView] playerContinerView]];
        
    }
    
    if (player) {
        
        if (![self player]) {
            
            self.player = player;
            
            [[self player] setAllowsExternalPlayback:YES];
    
            [[self avPlayerView] setPlayer:[self player]];
            
            [self updateProgressByPlayer:[self player]];
            
            [[self avPlayerView] setControllerProtocol:self];
            
            [[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        }
        else{
            
            [self replaceCurrentItemWithItem:[[player currentItem] copy]];
        }
        
        [[[self gaView] bottomToolBarView] setHidden:YES];
        [[[self gaView] fullScreenBottomtoolBarView] setHidden:YES];
        [[[self gaView] fullScreenTopTollBarView] setHidden:YES];
        
        [[[self gaView] activityIndicatorView] startAnimating];
    }
    else{
        
        [self failDelegateCallWithError:nil];
    }
    
}

-(void)playerItemDidReachEnd{
    
    switch ([self currentMode]) {
        case GAPlayerControllerModeDefault:
        case GAPlayerControllerModeMinimize:
            [self removePlyer];
            break;
            
        case GAPlayerControllerModeSmall:
        case GAPlayerControllerModeFullScreen:
            
            [[self player] seekToTime:kCMTimeZero];
            [self pause];
            break;
    }
    
    [self playerDidFinishPlayingDelegateCall];
}

-(void)updateProgressByPlayer:(AVPlayer *)player{
    
    CMTime interval = CMTimeMake(1, NSEC_PER_SEC);
    __weak GAPlayerController *weakSelf = self;
    [player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        AVPlayerItem *playerItem = [[weakSelf player] currentItem];
        double currentTime = CMTimeGetSeconds(playerItem.currentTime);
        double totalTime = CMTimeGetSeconds(playerItem.duration);
        
        if (![weakSelf isSeeking]) {
            [weakSelf syncSlider:[[weakSelf gaView] progerssSlider] currentTime:playerItem.currentTime duration:playerItem.duration];
            [weakSelf syncSlider:[[weakSelf gaView] fullScreenProgressSlider] currentTime:playerItem.currentTime duration:playerItem.duration];
            [weakSelf updateTimeLabelValuesCurrentTime:currentTime totalTime:totalTime];
        }
    }];
}

-(void)setPlayButtonMode{
    
    UIImage *buttonImage;
    
    if ([self isPlaying]) {
        buttonImage = [UIImage imageNamed:PAUSE_ICON_NAME];
    }
    else{
        buttonImage = [UIImage imageNamed:PLAY_ICON_NAME];
    }
    
    [[[self gaView] playButton] setImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [[[self gaView] fullScreenPlayButton] setImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

-(CMTime)playerItemDuration{
    AVPlayerItem *playerItem = [[self player] currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

-(void)updateToolBars{
    
    BOOL fullScreenTopTollBarViewHidden = NO;
    BOOL fullScreenBottomtoolBarViewHidden = NO;
    BOOL bottomToolBarViewHidden = NO;
    BOOL statusBarHidden = NO;
    
    switch ([self currentMode]) {
        case GAPlayerControllerModeDefault:
            
            fullScreenTopTollBarViewHidden = NO;
            fullScreenBottomtoolBarViewHidden = NO;
            bottomToolBarViewHidden = YES;
            statusBarHidden = YES;
            
            break;
            
        case GAPlayerControllerModeSmall:
            
            fullScreenTopTollBarViewHidden =YES;
            fullScreenBottomtoolBarViewHidden = YES;
            bottomToolBarViewHidden = NO;
            statusBarHidden = NO;
            
            break;
            
        case GAPlayerControllerModeFullScreen:
            
            fullScreenTopTollBarViewHidden = NO;
            fullScreenBottomtoolBarViewHidden = NO;
            bottomToolBarViewHidden = YES;
            statusBarHidden = YES;

            break;
            
        case GAPlayerControllerModeMinimize:
            
            fullScreenTopTollBarViewHidden =YES;
            fullScreenBottomtoolBarViewHidden = YES;
            bottomToolBarViewHidden = YES;
            statusBarHidden = NO;

            break;
    }
    
    if ([self topToolBarHidden]) {
        
        fullScreenTopTollBarViewHidden = YES;
    }
    
    if ([self bottomToolBarHidden]) {
        
        fullScreenBottomtoolBarViewHidden = YES;
        bottomToolBarViewHidden = YES;
    }
    
    
    [[[self gaView] fullScreenTopTollBarView] setHidden:fullScreenTopTollBarViewHidden];
    [[[self gaView] fullScreenBottomtoolBarView] setHidden:fullScreenBottomtoolBarViewHidden];
    [[[self gaView] bottomToolBarView] setHidden:bottomToolBarViewHidden];
    [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden];

}

#pragma mark - Full Screen

-(void)toggleFullScreenWithCompletion:(AnimationCompletion)completion{
    
    
    switch ([self currentMode]) {
        case GAPlayerControllerModeFullScreen:
            
            if ([self shouldToggleFullScreenAction:GAPlayerControllerActionTypeExitFullScreen]) {
                [self exitFullScreenWithAnimationAndCompletion:completion];
            }
            
            break;
            
        case GAPlayerControllerModeSmall:
            
            if ([self shouldToggleFullScreenAction:GAPlayerControllerActionTypeEnterFullScreen]) {
            
                [self enterFullScreenWithAniamtionAndCompletion:completion];
            }
            
            //[self enterMinimizeWithAnimationAndCompletion:completion ToSuperView:[[[UIApplication sharedApplication] delegate] window]];

            break;
            
        case GAPlayerControllerModeMinimize:
            
            if ([self shouldToggleFullScreenAction:GAPlayerControllerActionTypeEnterFullScreen]) {
                
                [self enterFullScreenWithAniamtionAndCompletion:completion];
            }

            break;
            
        case GAPlayerControllerModeDefault:break;
    }
    
}

-(void)enterFullScreenWithAniamtionAndCompletion:(AnimationCompletion)completion{
    
    if ([self currentMode] == GAPlayerControllerModeFullScreen) {return;}
    
    [self hidePlyerControlsWithCompletion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AVCustomPlayerWillEnterFullscreenNotification object:nil];
     __weak GAPlayerController *weakSelf = self;
    [UIView  moveView:[self gaView] ToWindowWithAnimationAndDuration:ANIMATION_DURATION Delay:0.0f Completion:^{
        [weakSelf setCurrentMode:GAPlayerControllerModeFullScreen];
        [weakSelf playerDidChangeMode];
        [weakSelf updateToolBars];
        
        if (completion) {
            
            completion();
        }
    }];
}

-(void)exitFullScreenWithAnimationAndCompletion:(AnimationCompletion)completion{
    
    if ([self currentMode] == GAPlayerControllerModeSmall) {return;}
    
    [self hidePlyerControlsWithCompletion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AVCustomPlayerWillExitFullscreenNotification object:nil];
    
    __weak GAPlayerController *weakSelf = self;
    [UIView moveView:[self gaView] FromWindowToView:[self mainViewOriginalParentView] toRect:[self mainViewOriginalFrame] WithAnimationAndDuration:ANIMATION_DURATION Delay:0.0f Completion:^{
        
        [weakSelf setCurrentMode:GAPlayerControllerModeSmall];
        [weakSelf playerDidChangeMode];
        [weakSelf updateToolBars];
        
        if (completion) {
            
            completion();
        }
    }];
    
}

-(void)enterMinimizeWithAnimationAndCompletion:(AnimationCompletion)completion ToSuperView:(UIView *)superView{
    
    [self hidePlyerControlsWithCompletion:nil];
    
     __weak GAPlayerController *weakSelf = self;
    
    [UIView minimazeAnimationOnView:[self gaView] ToSuperView:superView toFrame:[self minimazeFrame] WithAnimationDuration:ANIMATION_DURATION Delay:0.0f Completion:^{
        
        [weakSelf setCurrentMode:GAPlayerControllerModeMinimize];
        [weakSelf playerDidChangeMode];
        [weakSelf updateToolBars];
        
        if (completion) {
            
            completion();
        }


    }];
    
}

-(void)removePlayerFromMinimizeWithAnimationAndCompletion:(AnimationCompletion)completion{
    
    CGFloat xPoint = CGRectGetMinX([[[self gaView] superview] bounds]) - CGRectGetWidth([[self gaView] frame]);
    __weak GAPlayerController *weakSelf = self;
    [UIView swipeAnimationOnView:[self gaView] ToXPoint:xPoint WithAnimationDuration:ANIMATION_DURATION Delay:0.0 Completion:^{
        
        [weakSelf removePlyer];
        
        if (completion) {
            
            completion();
        }
    }];
}

#pragma mark - Hide And Show tool bars

-(void)showPlayerControlsWithCompletion:(AnimationCompletion)completion{
    
    
    if (!self.isShowingToolBars) {
        [self updateToolBars];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePlyerControlsWithCompletion:) object:nil];
        
        [UIView fadeInAnimationOnViews:@[[[self gaView] bottomToolBarView],[[self gaView] fullScreenTopTollBarView],[[self gaView] fullScreenBottomtoolBarView]] WithAnimationDuration:ANIMATION_DURATION Delay:0.0 Completion:^{
           
            [self setIsShowingToolBars:YES];
            if (completion){
                completion();
            }
            [self performSelector:@selector(hidePlyerControlsWithCompletion:) withObject:nil afterDelay:FADE_DELAY];
        }];
        
    }
    else {
        if (completion)
            completion();
    }
}

-(void)hidePlyerControlsWithCompletion:(AnimationCompletion)completion{
    
    if (self.isShowingToolBars) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePlyerControlsWithCompletion:) object:nil];
        
        [UIView fadeOutAnimationOnViews:@[[[self gaView] bottomToolBarView],[[self gaView] fullScreenTopTollBarView],[[self gaView] fullScreenBottomtoolBarView]] WithAnimationDuration:ANIMATION_DURATION Delay:0.0 Completion:^{
            
            [self setIsShowingToolBars:NO];
            if (completion){
                completion();
            }
        
        }];
    }
    else {
        if (completion)
            completion();
    }
}


#pragma mark - UpdateLabels

-(void)updateTimeLabelValuesCurrentTime:(double)currentTime totalTime:(double)totalTime {
    
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    [[[self gaView] timePassLabel] setText:[NSString stringWithFormat:@"%.0f:%02.0f", minutesElapsed, secondsElapsed]];
    [[[self gaView] fullScreenPassLabel] setText:[[[self gaView] timePassLabel] text]];
    
    double minutesRemaining;
    double secondsRemaining;
    if (isnan(totalTime) || isnan(currentTime)) {
        minutesRemaining = 0;
        secondsRemaining = 0;
    } else {
        minutesRemaining = floor((totalTime - currentTime) / 60.0);
        secondsRemaining = fmod((totalTime - currentTime), 60.0);
    }
    [[[self gaView] timeRemainingLabel] setText:[NSString stringWithFormat:@"-%.0f:%02.0f", minutesRemaining, secondsRemaining]];
    [[[self gaView] fullScreentimeRemainingLabel] setText:[[[self gaView] timeRemainingLabel] text]];
    
    
}

#pragma mark - Slider

-(void)syncSlider:(UISlider *)slider currentTime:(CMTime)currentTime duration:(CMTime)duration {
    
    if (CMTIME_IS_INVALID(duration))
    {
        [slider setMinimumValue:0.0];
    }
    else
    {
        
        double durationInSeconds = CMTimeGetSeconds(duration);
        
        if (isfinite(durationInSeconds))
        {
            float minValue = [slider minimumValue];
            float maxValue = [slider maximumValue];
            
            double timeInSeconds = CMTimeGetSeconds(currentTime);
            
            [slider setValue:(maxValue - minValue) * timeInSeconds / durationInSeconds + minValue];
        }
    }
}

-(void)seekTimeInPlayerWithSlider:(UISlider *)slider{
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        [self setIsSeeking:NO];
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        
        float minValue = [slider minimumValue];
        float maxValue = [slider maximumValue];
        float value = [slider value];
        
        double time = duration * (value - minValue) / (maxValue - minValue);
        
        [[self  player] seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setIsSeeking:NO];
            });
        }];
    }
}


#pragma mark - Delegate calls

-(void)playerDidFinishPlayingDelegateCall{
    if ([[self delegate] respondsToSelector:@selector(player:didFinishPlayingItem:)]) {
        
        [[self delegate] player:[self player] didFinishPlayingItem:[[self player] currentItem]];
    }
}

-(void)failDelegateCallWithError:(NSError *)error{
    if ([[self delegate]respondsToSelector:@selector(player:didFailToLoadItem:withError:)]) {
        
        [[self delegate] player:[self player] didFailToLoadItem:[[self player] currentItem] withError:error];
    }
}

-(BOOL)shouldTogglePlayAction:(GAPlayerControllerActionType)action{
    
    if ([[self delegate] respondsToSelector:@selector(player:ShouldTogglePlayPauseAction:)]) {
        
        return [[self delegate] player:[self player] ShouldTogglePlayPauseAction:action];
    }
    
    return YES;
}

-(BOOL)shouldToggleFullScreenAction:(GAPlayerControllerActionType)action{
    
    if ([[self delegate] respondsToSelector:@selector(player:ShouldToggleFullScreenAction:)]) {
        
        return [[self delegate] player:[self player] ShouldToggleFullScreenAction:action];
    }
    
    return YES;
}

-(void)playerDidChangeMode{
  
    [[NSNotificationCenter defaultCenter] postNotificationName:AVCustomPlayerDidChangeSreenModeNotification object:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (object == [[self player] currentItem] && [keyPath isEqualToString:@"status"]) {
        
        if ([[[self player] currentItem] status] == AVPlayerItemStatusReadyToPlay) {
            
            [[[self gaView] activityIndicatorView] stopAnimating];
            [self updateToolBars];
            
        } else if ([[[self player] currentItem] status] == AVPlayerItemStatusFailed) {
            
            [self updateToolBars];
            [self failDelegateCallWithError:nil];
        }
    }
}

#pragma mark - GAViewDelegate

-(void)gaView:(UIView *)view doneAction:(id)sender {
    
    switch ([self currentMode]) {
        case GAPlayerControllerModeDefault:
            
            [self removePlyer];
            break;
            
        case GAPlayerControllerModeFullScreen:
            
            [self exitFullScreenWithAnimationAndCompletion:nil];
            break;
            
        case GAPlayerControllerModeSmall:
        case GAPlayerControllerModeMinimize:
            break;
            
    }
    
    [self playerDidFinishPlayingDelegateCall];
}

-(void)gaView:(UIView *)view viewDidClick:(UITapGestureRecognizer *)sender {
    
    if ([self isShowingToolBars]) {
        
        [self hidePlyerControlsWithCompletion:nil];
    }
    else{
        [self showPlayerControlsWithCompletion:nil];
    }
}

-(void)gaView:(UIView *)view playAction:(id)sender {
    
    if ([self isPlaying]) {
        
        if ([self shouldTogglePlayAction:GAPlayerControllerActionTypePause]) {
        
            [self pause];
        }
    }
    else{
       
        if ([self shouldTogglePlayAction:GAPlayerControllerActionTypePlay]) {
        
            [self play];
        }
        
    }
    
    [self performSelector:@selector(hidePlyerControlsWithCompletion:) withObject:nil afterDelay:FADE_DELAY];
}

-(void)gaView:(UIView *)view fullScreenAction:(id)sender {
    
    
    [self toggleFullScreenWithCompletion:nil];
}

-(void)gaView:(UIView *)view sliderAction:(UISlider *)sender {
    
    double duration = CMTimeGetSeconds([self playerItemDuration]);
    double time = duration * ([sender value] - [sender minimumValue]) / ([sender maximumValue] - [sender minimumValue]);
    [self updateTimeLabelValuesCurrentTime:time totalTime:duration];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePlyerControlsWithCompletion:) object:nil];
}

-(void)gaView:(UIView *)view durationSliderTouchBegan:(id)sender{
    [self setIsSeeking:YES];
}

-(void)gaView:(UIView *)view durationSliderTouchEnded:(UISlider *)sender{
    
    [self seekTimeInPlayerWithSlider:sender];
    [self performSelector:@selector(hidePlyerControlsWithCompletion:) withObject:nil afterDelay:FADE_DELAY];
}

-(void)gaView:(UIView *)view seekBackwardAction:(id)sender{
    
    [self backward];
}

-(void)gaView:(UIView *)view seekForwardAction:(id)sender{
    
    [self forward];
}

-(void)gaView:(UIView *)view panAction:(UIPanGestureRecognizer *)recognizer {
    
    if ([self enableMinimaize]) {
     
        if ([self currentMode] == GAPlayerControllerModeMinimize) {
            
            CGFloat xPoint = CGRectGetMidX([self minimazeFrame]);
            
            CGFloat windowMidXPoint = CGRectGetMidX([[[[UIApplication sharedApplication] delegate] window] bounds]);
           
             __weak GAPlayerController *weakSelf = self;
            
            CGPoint thresHoldPoint = CGPointMake(CGRectGetMidX([[[self gaView] superview] bounds]), 0.0);
            
            if (xPoint >  windowMidXPoint) {
            
                [[self dragController] hendelLeftDragWithPanGesture:recognizer OnView:[self gaView] thresHoldPoint:thresHoldPoint
                                                  SuccessCompletion:^{
                                                      
                                                      [weakSelf removePlyer];
                                                      
                                                  } FailedCompletion:nil];

            }
            else{
                
                [[self dragController] hendelRightDragWithPanGesture:recognizer OnView:[self gaView] thresHoldPoint:thresHoldPoint
                                                  SuccessCompletion:^{
                                                      
                                                      [weakSelf removePlyer];
                                                      
                                                  } FailedCompletion:nil];
            }
            
        }
        
        else if ([self currentMode] == GAPlayerControllerModeFullScreen){
            
            __weak GAPlayerController *weakSelf = self;
            
            [[self dragController] hendelInteractiveMinimizeWithPanGesture:recognizer OnView:[self gaView] thresHoldPoint:CGPointMake(CGRectGetMidX([[[self gaView] superview] bounds]), CGRectGetMidY([[[self gaView] superview] bounds]) - 90.0f)  SuccessCompletion:^{
                
                [weakSelf setCurrentMode:GAPlayerControllerModeMinimize];
                [weakSelf playerDidChangeMode];
                [weakSelf updateToolBars];
                
            }FailedCompletion:nil toDestinationFame:[self minimazeFrame]];
            
        }

    }
    
}

@end

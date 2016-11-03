//
//  GAView.h
//  GAPLayer
//
//  Created by Ido Meirov on 27/09/2016.
//  Copyright © 2016 ido.meirov.app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol GAViewDelegate <NSObject>

@optional
-(void)gaView:(UIView *)view doneAction:(id)sender;
-(void)gaView:(UIView *)view viewDidClick:(UITapGestureRecognizer *)sender;
-(void)gaView:(UIView *)view playAction:(id)sender;
-(void)gaView:(UIView *)view fullScreenAction:(id)sender;
-(void)gaView:(UIView *)view sliderAction:(UISlider *)sender;
-(void)gaView:(UIView *)view durationSliderTouchBegan:(id)sender;
-(void)gaView:(UIView *)view durationSliderTouchEnded:(UISlider *)sender;
-(void)gaView:(UIView *)view seekBackwardAction:(id)sender;
-(void)gaView:(UIView *)view seekForwardAction:(id)sender;
-(void)gaView:(UIView *)view panAction:(UIPanGestureRecognizer *)recognizer;

@end


@interface GAView : UIView

@property (weak, nonatomic)     IBOutlet UIView         *playerContinerView;
@property (weak, nonatomic)     IBOutlet UIButton       *playButton;
@property (weak, nonatomic)     IBOutlet UISlider       *progerssSlider;
@property (weak, nonatomic)     IBOutlet UIButton       *fullScreenButton;
@property (weak, nonatomic)     IBOutlet UILabel        *timeRemainingLabel;
@property (weak, nonatomic)     IBOutlet UILabel        *timePassLabel;
@property (weak, nonatomic)     IBOutlet UIView         *fullScreenTopTollBarView;
@property (weak, nonatomic)     IBOutlet UIView         *fullScreenBottomtoolBarView;
@property (weak, nonatomic)     IBOutlet UIView         *bottomToolBarView;
@property (weak, nonatomic)     IBOutlet MPVolumeView   *airPlayButton;
@property (weak, nonatomic)     IBOutlet UILabel        *fullScreentimeRemainingLabel;
@property (weak, nonatomic)     IBOutlet UILabel        *fullScreenPassLabel;
@property (weak, nonatomic)     IBOutlet UISlider       *fullScreenProgressSlider;
@property (weak, nonatomic)     IBOutlet UIButton       *fullScreenDoneButton;
@property (weak, nonatomic)     IBOutlet UIButton       *seekForwardButton;
@property (weak, nonatomic)     IBOutlet UIButton       *seekBackwardButton;
@property (weak, nonatomic)     IBOutlet UIButton       *fullScreenPlayButton;
@property (weak, nonatomic)     IBOutlet MPVolumeView   *fullScreenAirPlayButton;


@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *singelTapGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (weak, nonatomic)     IBOutlet UIActivityIndicatorView *activityIndicatorView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSliderWidthConstrintForIphone6Up;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSliderWidthConstrintForIphone5AndDown;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSliderWidthConstrintForIphone6Up;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSliderWidthConstrintForIphone5AndDown;

@property (weak,nonatomic) id<GAViewDelegate> delegate;

-(void)setupNib;

@end

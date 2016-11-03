//
//  UIView+GAAnimations.h
//  calcalist
//
//  Created by ido meirov on 13/09/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimationCompletion)();

@interface UIView (GAAnimations)


+(void)moveView:(UIView*)view ToWindowWithAnimationAndDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion;

+(void)moveView:(UIView *)view FromWindowToView:(UIView *)superView toRect:(CGRect)frame WithAnimationAndDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion;

+(void)minimazeAnimationOnView:(UIView *)view ToSuperView:(UIView *)superView toFrame:(CGRect)minimazeFrame WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion;

+(void)fadeInAnimationOnViews:(NSArray *)viewsArray WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion;

+(void)fadeOutAnimationOnViews:(NSArray *)viewsArray WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion;

+(void)swipeAnimationOnView:(UIView *)view ToXPoint:(CGFloat)xPoint WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion;

@end

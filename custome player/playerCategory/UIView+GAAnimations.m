//
//  UIView+GAAnimations.m
//  calcalist
//
//  Created by ido meirov on 13/09/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import "UIView+GAAnimations.h"
#import "UIView+Constraints.h"

@implementation UIView (GAAnimations)

// move view to thw window view on full screen
+(void)moveView:(UIView*)view ToWindowWithAnimationAndDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect tempFrame = [view frame];
    CGPoint p = [[view superview] convertPoint:[view frame].origin toView:window];
    tempFrame.origin = p;
    [view removeFromSuperview];
    [view setFrame:tempFrame];
    [window addSubview:view];
    
    UIView *tampView = [[UIView alloc] initWithFrame:[window bounds]];
    [tampView setBackgroundColor:[UIColor clearColor]];
    [[view superview] insertSubview:tampView belowSubview:view];
    
    
    [UIView animateKeyframesWithDuration:animationDuration delay:delay options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        [view setFrame:window.bounds];
        
    } completion:^(BOOL finished) {
        
        
        [UIView addViewConstraintsForTopLevelView:view superView:[view superview]]; // add Constraints for full screen video
        [[view superview] layoutIfNeeded];
        
        [tampView removeFromSuperview];
        
        
        
        if (completion) {
            
            completion();
        }
        
    }];
}

// remove a view from the window to new super view
+(void)moveView:(UIView *)view FromWindowToView:(UIView *)superView toRect:(CGRect)frame WithAnimationAndDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion{
    
    [view removeConstraintsfromSuperView:[view superview]];
    [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect tempFrame = frame;
    CGPoint p = [superView convertPoint:frame.origin toView:window];
    tempFrame.origin = p;
    
    UIView *tampView = [[UIView alloc] initWithFrame:[window bounds]];
    [tampView setBackgroundColor:[UIColor clearColor]];
    [[view superview] insertSubview:tampView belowSubview:view];
    
    [UIView animateKeyframesWithDuration:animationDuration delay:delay options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        [view setFrame:tempFrame];
        
    } completion:^(BOOL finished) {
        
        [view removeFromSuperview];
        [view setFrame:frame];
        [superView addSubview:view];
        
        [tampView removeFromSuperview];
        
        if (completion) {
            
            completion();
        }
        
        
    }];
}

// move view to window and minimaze it to the minimazeFrame rect
+(void)minimazeAnimationOnView:(UIView *)view ToSuperView:(UIView *)superView toFrame:(CGRect)minimazeFrame WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion{
    
   
    
    CGRect tempFrame = [view frame];
    CGPoint p = [[view superview] convertPoint:[view frame].origin toView:superView];
    tempFrame.origin = p;
    [view removeFromSuperview];
    [view setFrame:tempFrame];
    [superView addSubview:view];
    
     UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIView *tampView = [[UIView alloc] initWithFrame:[window bounds]];
    [tampView setBackgroundColor:[UIColor clearColor]];
    [[view superview] insertSubview:tampView belowSubview:view];
    
    [UIView animateKeyframesWithDuration:animationDuration delay:delay options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        [view setFrame:minimazeFrame];
        
    } completion:^(BOOL finished) {
        
        [tampView removeFromSuperview];
        
        if (completion) {
            
            completion();
        }
        
    }];
    
}

// chnage alpha to 1.0 with animtion to array of views
+(void)fadeInAnimationOnViews:(NSArray *)viewsArray WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion{

    
    [UIView beginAnimations:@"fadeIn" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    [UIView setAnimationDelay:delay];
    
    for (UIView *view in viewsArray) {
        
        [view setAlpha:1.0f];
        
    }
    
    [UIView commitAnimations];
    
    if (completion) {
        completion();
    }

}

// chnage alpha to 0.0 with animtion to array of views
+(void)fadeOutAnimationOnViews:(NSArray *)viewsArray WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion{
    
    
    [UIView beginAnimations:@"fadeOut" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    [UIView setAnimationDelay:delay];
    
    for (UIView *view in viewsArray) {
    
        [view setAlpha:0.0f];
        
    }
    
    [UIView commitAnimations];
    
    if (completion) {
        completion();
    }
    
}

// swipe animationmove chnage the x point of view frame
+(void)swipeAnimationOnView:(UIView *)view ToXPoint:(CGFloat)xPoint WithAnimationDuration:(CGFloat)animationDuration Delay:(CGFloat)delay Completion:(AnimationCompletion)completion{
    
    CGRect frame = [view frame];
    frame.origin.x = xPoint;
    
    [UIView animateKeyframesWithDuration:animationDuration delay:delay options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        [view setFrame:frame];
        
    } completion:^(BOOL finished) {
        
        if (completion) {
            
            completion();
        }
        
    }];
}

@end

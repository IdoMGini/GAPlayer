//
//  GADragController.m
//  calcalist
//
//  Created by ido meirov on 13/09/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import "GADragController.h"
#import "UIView+GAAnimations.h"
#import "UIView+Constraints.h"

@interface GADragController ()

@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGRect  panViewStartFrame;

@end

@implementation GADragController

//set panStartPoint and panViewStartPoint to CGPointZero for the next use
-(void)cleanStartData{
    
    [self setPanStartPoint:CGPointZero];
    [self setPanViewStartFrame:CGRectZero];
    
}

-(void)hendelLeftDragWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view thresHoldPoint:(CGPoint)point SuccessCompletion:(SuccessCompletion)successCompletion FailedCompletion:(FailedCompletion)failedCompletion{
    
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            
            [self hendelUIGestureRecognizerStateBeganWithPanGesture:recognizer OnView:view];
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            failedCompletion();
            [self cleanStartData];
            break;
            
        case UIGestureRecognizerStateChanged:
            
            [self hendelLeftDragUIGestureRecognizerStateChangedWithPanGesture:recognizer OnView:view];
            break;
            
        case UIGestureRecognizerStateEnded:
            
            if (CGRectGetMidX([view frame]) < point.x) {
               
                [self swipeAnimationOnView:view WithCompletion:successCompletion];
            }
            else{
                
                [self failedAniamtionOnVIew:view WithCompletion:failedCompletion AddConstraints:NO];
            }
            
            break;
            
        default:
            break;
    }
    
}

-(void)swipeAnimationOnView:(UIView *)view WithCompletion:(AnimationCompletion)completion{
    
    CGFloat xPoint = CGRectGetMinX([[view superview] bounds]) - CGRectGetWidth([view frame]);
    [UIView swipeAnimationOnView:view ToXPoint:xPoint WithAnimationDuration:0.3 Delay:0 Completion:^{
        
        [self cleanStartData];
        if (completion) {
            
            completion();
        }
        
    }];
}

-(void)hendelInteractiveMinimizeWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view thresHoldPoint:(CGPoint)point SuccessCompletion:(SuccessCompletion)successCompletion FailedCompletion:(FailedCompletion)failedCompletion toDestinationFame:(CGRect)destinationFrame
{
    
    
    switch ([recognizer state]) {
        case UIGestureRecognizerStateBegan:
            
            [self hendelUIGestureRecognizerStateBeganWithPanGesture:recognizer OnView:view];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            failedCompletion();
            [self cleanStartData];
            break;
            
            
        case UIGestureRecognizerStateChanged:
            
            [self hendelInteractiveMinimizeUIGestureRecognizerStateChangedWithPanGesture:recognizer OnView:view AndDestinationFrame:destinationFrame];
            
            break;
            
        case UIGestureRecognizerStateEnded:
            
            if (CGRectGetMinY([view frame]) > point.y) {
                
                
                [self minimazeAnimationOnView:view ToFrame:destinationFrame WithCompletion:successCompletion];
                
                
            }
            else{
                
                [self failedAniamtionOnVIew:view WithCompletion:failedCompletion AddConstraints:YES];
              
            }
            
            
           
            
            break;
            
        default:
            break;
    }
}

-(void)minimazeAnimationOnView:(UIView *)view ToFrame:(CGRect)destinationFrame WithCompletion:(AnimationCompletion)completion{
    
    [UIView minimazeAnimationOnView:view ToSuperView:[view superview] toFrame:destinationFrame WithAnimationDuration:0.3 Delay:0 Completion:^{
        
        [self cleanStartData];
        
        if (completion) {
            
            completion();
        }
        
        
    }];
    
}

-(void)failedAniamtionOnVIew:(UIView *)view WithCompletion:(FailedCompletion)failedCompletion AddConstraints:(BOOL)needToAddConstraints{
    
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        [view setFrame:[self panViewStartFrame]];
        
    } completion:^(BOOL finished) {
        [self cleanStartData];
        
        if (needToAddConstraints) {
            
            [UIView addViewConstraintsForTopLevelView:view superView:[view superview]]; // add Constraints for full screen video
            [[view superview] layoutIfNeeded];
        }
        
        if (failedCompletion) {
        
            failedCompletion();
        }
        
       
    }];
}

-(void)hendelUIGestureRecognizerStateBeganWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view{
    
    [view removeConstraintsfromSuperView:[view superview]];
    [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.panStartPoint = [recognizer translationInView:view];
    self.panViewStartFrame = [view frame];
    
}

-(void)hendelLeftDragUIGestureRecognizerStateChangedWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view{
    
    CGPoint currentPoint = [recognizer translationInView:view];
    CGFloat deltaX = self.panViewStartFrame.origin.x - ( self.panStartPoint.x - currentPoint.x );
    CGRect frame = [view frame];
    NSLog(@"deltaX = %f currentPoint.x = %f self.panStartPoint.x = %f frame.origin.x = %f",deltaX,currentPoint.x,self.panStartPoint.x,frame.origin.x);
    if (currentPoint.x < self.panStartPoint.x) {  //1
        
        frame.origin.x =  deltaX;
        [view setFrame:frame];
    }
}

-(void)hendelInteractiveMinimizeUIGestureRecognizerStateChangedWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view AndDestinationFrame:(CGRect)destinationFame{
    
    CGPoint currentPoint = [recognizer translationInView:view];
    
    CGFloat minScale = 0.0f;
    CGFloat maxScale = 1.0f;
    
    CGFloat currentScale = (currentPoint.y - self.panStartPoint.y) / (CGRectGetHeight([self panViewStartFrame]) - (CGRectGetHeight([self panViewStartFrame]) - CGRectGetHeight([view frame])) / 2);
    
    if (currentPoint.y == CGRectGetMinY(destinationFame)) {
        
        currentScale = maxScale;
    }
    
    if (currentPoint.y == [self panStartPoint].y) {
        
        currentScale = minScale;
    }
    
    if (currentScale < 0) {
        
        currentScale = 0;
    }
    
    if (currentScale > 1) {
        
        currentScale = 1;
    }
    
    CGFloat newHeight   = CGRectGetHeight([self panViewStartFrame])  - (CGRectGetHeight([self panViewStartFrame]) - CGRectGetHeight(destinationFame)) * currentScale;
    
    CGFloat newWidth    = CGRectGetWidth([self panViewStartFrame]) - (CGRectGetWidth([self panViewStartFrame]) - CGRectGetWidth(destinationFame)) * currentScale;
    
    CGFloat newY        = CGRectGetMinY([self panViewStartFrame]) - (CGRectGetMinY([self panViewStartFrame]) -CGRectGetMinY(destinationFame)) * currentScale;
    
    CGFloat newX        = CGRectGetMinX([self panViewStartFrame]) - (CGRectGetMinX([self panViewStartFrame]) - CGRectGetMinX(destinationFame)) * currentScale;
    
    CGRect newFame = [view frame];
    
    newFame.size.width = newWidth;
    newFame.size.height = newHeight;
    newFame.origin.y = newY;
    newFame.origin.x = newX;
    
    [view setFrame:newFame];
    
    NSLog(@"currentScale:%f aaa:%f",currentScale,newHeight);
}


@end

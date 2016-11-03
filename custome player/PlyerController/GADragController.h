//
//  GADragController.h
//  calcalist
//
//  Created by ido meirov on 13/09/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessCompletion)();
typedef void (^FailedCompletion)();

@interface GADragController : NSObject

// crate drag to view by pan Gesture add thresHoldPoint to determine whene successCompletion will cell and successCompletion
-(void)hendelLeftDragWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view thresHoldPoint:(CGPoint)point SuccessCompletion:(SuccessCompletion)successCompletion FailedCompletion:(FailedCompletion)successCompletion;

-(void)hendelInteractiveMinimizeWithPanGesture:(UIPanGestureRecognizer *)recognizer OnView:(UIView *)view thresHoldPoint:(CGPoint)point SuccessCompletion:(SuccessCompletion)successCompletion FailedCompletion:(FailedCompletion)failedCompletion toDestinationFame:(CGRect)destinationFame;

@end

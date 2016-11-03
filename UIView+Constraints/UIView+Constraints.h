//
//  UIView+Constraints.h
//  calcalist
//
//  Created by ido meirov on 21/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Constraints)

+(void)addViewConstraintsForTopLevelView:(UIView*)view superView:(UIView *)superView;
-(NSArray*)removeConstraintsfromSuperView:(UIView*)superview;

@end

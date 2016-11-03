//
//  UIView+Constraints.m
//  calcalist
//
//  Created by ido meirov on 21/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import "UIView+Constraints.h"

@implementation UIView (Constraints)


+(void)addViewConstraintsForTopLevelView:(UIView*)view superView:(UIView *)superView{
    
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *topConstraint       = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *bottomConstraint    = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *leadingConstraint   = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    NSLayoutConstraint *trailingConstraint  = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
    
    [superView addConstraints:@[leadingConstraint,trailingConstraint,topConstraint,bottomConstraint]];
}

-(NSArray*)removeConstraintsfromSuperView:(UIView*)superview{
    NSMutableArray *const constraints = [NSMutableArray new];
    
    UIView *searchView = self;
    while(searchView.superview && searchView!= superview)
    {
        searchView = searchView.superview;
        
        NSArray *const affectingConstraints =
        [searchView.constraints filteredArrayUsingPredicate:
         [NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint *constraint, NSDictionary *bindings)
          {
              return constraint.firstItem == self || constraint.secondItem == self;
          }]];
        
        [searchView removeConstraints: affectingConstraints];
        [constraints addObjectsFromArray: affectingConstraints];
    }
    
    return constraints;
}

@end

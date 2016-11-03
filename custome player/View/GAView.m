//
//  GAView.m
//  GAPLayer
//
//  Created by Ido Meirov on 27/09/2016.
//  Copyright © 2016 ido.meirov.app. All rights reserved.
//

#import "GAView.h"
#import "UIView+Constraints.h"

#define NIB_NAME @"GAView"

@implementation GAView


-(UIView *)loadNib{
    
    UINib *nib = [UINib nibWithNibName:NIB_NAME bundle:nil];
    
    return (UIView *) [[nib instantiateWithOwner:self options:0] firstObject];
}

-(void)setupNib{
    
    UIView *view = [self loadNib];
    
    [self addSubview:view];
    
    [UIView addViewConstraintsForTopLevelView:view superView:self];
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    
        [self setupNib];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
       
        [self setupNib];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
       [self setupNib];
    }
    
    return self;
}

#pragma mark - IBAction

-(IBAction)doneAction:(id)sender {
    
    if ([[self delegate] respondsToSelector:@selector(gaView:doneAction:)]) {
        
        [[self delegate] gaView:self doneAction:sender];
    }

}

-(IBAction)viewDidClick:(UITapGestureRecognizer *)sender {
    
    if ([[self delegate] respondsToSelector:@selector(gaView:viewDidClick:)]) {
        
        [[self delegate] gaView:self viewDidClick:sender];
    }

}

-(IBAction)playAction:(id)sender {
    

    if ([[self delegate] respondsToSelector:@selector(gaView:playAction:)]) {
        
        [[self delegate] gaView:self playAction:sender];
    }
}

-(IBAction)fullScreenAction:(id)sender {
    
    if ([[self delegate] respondsToSelector:@selector(gaView:fullScreenAction:)]) {
        
        [[self delegate] gaView:self fullScreenAction:sender];
    }
}

-(IBAction)sliderAction:(UISlider *)sender {
    
    if ([[self delegate] respondsToSelector:@selector(gaView:sliderAction:)]) {
        
        [[self delegate] gaView:self sliderAction:sender];
    }

}

-(IBAction)durationSliderTouchBegan:(id)sender{

    if ([[self delegate] respondsToSelector:@selector(gaView:durationSliderTouchBegan:)]) {
        
        [[self delegate] gaView:self durationSliderTouchBegan:sender];
    }
}

-(IBAction)durationSliderTouchEnded:(UISlider *)sender{
    
    if ([[self delegate] respondsToSelector:@selector(gaView:durationSliderTouchEnded:)]) {
        
        [[self delegate] gaView:self durationSliderTouchEnded:sender];
    }
}

-(IBAction)seekBackwardAction:(id)sender{
    
    if ([[self delegate] respondsToSelector:@selector(gaView:seekBackwardAction:)]) {
        
        [[self delegate] gaView:self seekBackwardAction:sender];
    }
   
}

-(IBAction)seekForwardAction:(id)sender{
    
    if ([[self delegate] respondsToSelector:@selector(gaView:seekForwardAction:)]) {
        
        [[self delegate] gaView:self seekForwardAction:sender];
    }
   
}

-(IBAction)panAction:(UIPanGestureRecognizer *)recognizer {
    
    if ([[self delegate] respondsToSelector:@selector(gaView:panAction:)]) {
        
        [[self delegate] gaView:self panAction:recognizer];
    }
   
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

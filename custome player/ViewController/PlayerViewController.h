//
//  PlyerViewController.h
//  calcalist
//
//  Created by ido meirov on 22/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAPlayerController.h"

@interface PlayerViewController : UIViewController


@property(strong,nonatomic) GAPlayerController *playerController;
- (instancetype)initWithUrl:(NSURL *)url;

@end

//
//  PlyerViewController.m
//  calcalist
//
//  Created by ido meirov on 22/08/2016.
//  Copyright © 2016 yit. All rights reserved.
//

#import "PlayerViewController.h"

@interface PlayerViewController ()<GAPlayerControllerDelegate>

@property(strong,nonatomic) NSURL *url;

@end

@implementation PlayerViewController

- (instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        
        [self setUrl:url];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![self view]) {
        [self setView:[[UIView alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]]];
    }
    [self setPlayerController:[[GAPlayerController alloc] init]];
    
    [[self playerController] setDelegate:self];
    [[self playerController] addPlayerToSuperview:[self view] withItemURL:[self url]];
    [[self playerController] play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[self playerController] removePlyer];
    [self setPlayerController:nil];
}

-(void)dismissViewController{

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - AVCustomPlayerControllerDelegate

-(void)player:(AVPlayer *)player didFinishPlayingItem:(AVPlayerItem *)playerItem{
    
    [self dismissViewController];
}

-(void)player:(AVPlayer *)player didFailToLoadItem:(AVPlayerItem *)playerItem withError:(NSError *)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self dismissViewController];
    });
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

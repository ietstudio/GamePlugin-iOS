//
//  IETViewController.m
//  GamePluginIOS
//
//  Created by gaoyang on 08/26/2015.
//  Copyright (c) 2015 gaoyang. All rights reserved.
//

#import "IETViewController.h"
#import "IOSGamePlugin.h"
#import "IOSAdvertiseHelper.h"

@interface IETViewController ()
@property (weak, nonatomic) IBOutlet UIView *commonView;
@property (weak, nonatomic) IBOutlet UIView *advertiseView;
@property (weak, nonatomic) IBOutlet UIView *analyticsView;
@property (weak, nonatomic) IBOutlet UIView *feedbackView;
@property (weak, nonatomic) IBOutlet UIView *amazonAWSView;
@property (weak, nonatomic) IBOutlet UIView *facebookView;

@end

@implementation IETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self hideAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAll {
    self.commonView.hidden = YES;
    self.advertiseView.hidden = YES;
    self.analyticsView.hidden = YES;
    self.feedbackView.hidden = YES;
    self.amazonAWSView.hidden = YES;
    self.facebookView.hidden = YES;
}

- (IBAction)enterCommon:(id)sender {
    self.commonView.hidden = NO;
}

- (IBAction)enterAdvertise:(id)sender {
    self.advertiseView.hidden = NO;
}

- (IBAction)enterAnalytics:(id)sender {
    self.analyticsView.hidden = NO;
}

- (IBAction)enterFeedback:(id)sender {
    self.feedbackView.hidden = NO;
}

- (IBAction)enterAmazonAWS:(id)sender {
    self.amazonAWSView.hidden = NO;
}

- (IBAction)enterFacebook:(id)sender {
    self.facebookView.hidden = NO;
}

- (IBAction)back:(id)sender {
    [self hideAll];
}

#pragma mark - Common

- (IBAction)getBuild:(id)sender {
    NSLog(@"%@", [[IOSGamePlugin getInstance] getAppVersion]);
}

- (IBAction)getCountryCode:(id)sender {
    NSLog(@"%@", [[IOSGamePlugin getInstance] getCountryCode]);
}

- (IBAction)getLanguageCode:(id)sender {
    NSLog(@"%@", [[IOSGamePlugin getInstance] getLanguageCode]);
}

- (IBAction)getDeviceName:(id)sender {
    NSLog(@"%@", [[IOSGamePlugin getInstance] getDeviceName]);
}

- (IBAction)getSystemVersion:(id)sender {
    NSLog(@"%@", [[IOSGamePlugin getInstance] getSystemVersion]);
}

- (IBAction)getGameClock:(id)sender {
    NSLog(@"%ld", [[IOSGamePlugin getInstance] getGameClock]);
}

- (IBAction)showChooseView:(id)sender {
    [[IOSGamePlugin getInstance] showChooseView:@"title" :@"message" :@"yes" :@"no" :^(BOOL ret) {
        NSLog(@"%@", ret==YES?@"YES":@"NO");
    }];
}

- (IBAction)getNetworkState:(id)sender {
    NSLog(@"%@", [[IOSGamePlugin getInstance] getNetworkState]);
}

- (IBAction)rate:(id)sender {
    [[IOSGamePlugin getInstance] rate:YES];
}

- (IBAction)sendEmail:(id)sender {
    [[IOSGamePlugin getInstance] sendEmail:@"title" :@[@"574920212@qq.com"] :@"body" :^(BOOL ret, NSString *msg) {
        NSLog(@"%@", ret==YES?@"YES":@"NO");
        NSLog(@"%@", msg);
    }];
}

#pragma mark - Advertise

- (IBAction)showSpot:(id)sender {
    BOOL result = [[IOSAdvertiseHelper getInstance] showSpotAd:^(BOOL result) {
        NSLog(@"SpotAd Click: %@", result?@"YES":@"NO");
    }];
    NSLog(@"SpotAd Show: %@", result?@"YES":@"NO");
}

- (IBAction)isVedioReady:(id)sender {
    BOOL result = [[IOSAdvertiseHelper getInstance] isVedioAdReady];
    NSLog(@"VedioAd Ready: %@", result?@"YES":@"NO");
}

- (IBAction)showVedio:(id)sender {
    BOOL result = [[IOSAdvertiseHelper getInstance] showVedioAd:^(BOOL result) {
        NSLog(@"VedioAd Valid: %@", result?@"YES":@"NO");
    } :^(BOOL result) {
        NSLog(@"VedioAd Click: %@", result?@"YES":@"NO");
    }];
    NSLog(@"VedioAd Show: %@", result?@"YES":@"NO");
}

@end

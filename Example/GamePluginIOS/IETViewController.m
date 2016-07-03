//
//  IETViewController.m
//  GamePluginIOS
//
//  Created by gaoyang on 06/11/2016.
//  Copyright (c) 2016 gaoyang. All rights reserved.
//

#import "IETViewController.h"
#import "IOSSystemUtil.h"
#import "IOSGamePlugin.h"
#import "IOSAdvertiseHelper.h"
#import "NSString+MD5.h"

@interface IETViewController ()

@property (weak, nonatomic) IBOutlet UIView *commonView;
@property (weak, nonatomic) IBOutlet UIView *advertiseView;
@property (weak, nonatomic) IBOutlet UIView *analyticsView;
@property (weak, nonatomic) IBOutlet UIView *amazonAWSView;
@property (weak, nonatomic) IBOutlet UIView *facebookView;

@end

@implementation IETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self hideAll];
    [self setRestoreCallback:nil];
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
    NSLog(@"%@", [[IOSSystemUtil getInstance] getAppVersion]);
}

- (IBAction)getCountryCode:(id)sender {
    NSLog(@"%@", [[IOSSystemUtil getInstance] getCountryCode]);
}

- (IBAction)getLanguageCode:(id)sender {
    NSLog(@"%@", [[IOSSystemUtil getInstance] getLanguageCode]);
}

- (IBAction)getDeviceName:(id)sender {
    NSLog(@"%@", [[IOSSystemUtil getInstance] getDeviceName]);
}

- (IBAction)getSystemVersion:(id)sender {
    NSLog(@"%@", [[IOSSystemUtil getInstance] getSystemVersion]);
}

- (IBAction)getGameClock:(id)sender {
    NSLog(@"%ld", [[IOSSystemUtil getInstance] getCpuTime]);
}

- (IBAction)showChooseView:(id)sender {
    [[IOSSystemUtil getInstance] showChooseDialog:@"title" :@"message" :@"yes" :@"no" :^(BOOL ret) {
        NSLog(@"%@", ret==YES?@"YES":@"NO");
    }];
}

- (IBAction)getNetworkState:(id)sender {
    NSLog(@"%@", [[IOSSystemUtil getInstance] getNetworkState]);
}

- (IBAction)showGameLoading:(id)sender {
    [[IOSGamePlugin getInstance] showGameLoading:@"12.png" :CGPointMake(0.5, 0.25) :0.5f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
        [[IOSGamePlugin getInstance] hideGameLoading];
    });
}

- (IBAction)showLoading:(id)sender {
    [[IOSSystemUtil getInstance] showLoading:@"Loading..."];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5), dispatch_get_main_queue(), ^{
        [[IOSSystemUtil getInstance] hideLoading];
    });
}

- (IBAction)setGenVerifyUrlCallFunc:(id)sender {
    [[IOSGamePlugin getInstance] setGenVerifyUrlCallFunc:^NSString *(NSDictionary *userInfo) {
        NSString* userId = [userInfo objectForKey:@"userId"];
        NSString* productId = [userInfo objectForKey:@"productId"];
        NSString* receipt = [userInfo objectForKey:@"receipt"];
        NSString* sign = [[NSString stringWithFormat:@"iet_studio%@%@%@", userId, productId, receipt] MD5Digest];
        NSString* url = [NSString stringWithFormat:@"http://192.168.1.180:7999/mayaslots/iap_verify?user_id=%@&product_id=%@&receipt=%@&sign=%@", userId, productId, receipt, sign];
        return url;
    }];
}

- (IBAction)doIap:(id)sender {
    [[IOSGamePlugin getInstance] doIap:@[@"mayaslot.coin5"]
                                      :@"mayaslot.coin5"
                                      :@"guest"
                                      :^(BOOL result, NSString *msg) {
                                          NSLog(@"result=%@", result?@"YES":@"NO");
                                          NSLog(@"%@", msg);
                                          [[IOSSystemUtil getInstance] showChooseDialog:result?@"YES":@"NO"
                                                                                     :msg
                                                                                     :@"OK"
                                                                                     :nil
                                                                                     :nil];
                                      }];
}

- (IBAction)setRestoreCallback:(id)sender {
    [[IOSGamePlugin getInstance] setRestoreCallback:^(BOOL result, NSString * msg) {
        NSLog(@"%@", result?@"YES":@"NO");
        NSLog(@"%@", msg);
        [[IOSSystemUtil getInstance] showChooseDialog:result?@"YES":@"NO" :msg :@"OK" :nil :nil];
    }];
}

- (IBAction)rate:(id)sender {
    [[IOSGamePlugin getInstance] rate:YES];
}

- (IBAction)saveImg:(id)sender {
    [[IOSGamePlugin getInstance] saveImage:@"12.png" toAlbum:@"test" :^(BOOL result, NSString *msg) {
        NSLog(@"result=%@", result?@"YES":@"NO");
        NSLog(@"%@", msg);
    }];
}

- (IBAction)sendEmail:(id)sender {
    [[IOSGamePlugin getInstance] sendEmail:@"title" :@[@"574920212@qq.com"] :@"body" :^(BOOL ret, NSString *msg) {
        NSLog(@"%@", ret==YES?@"YES":@"NO");
        NSLog(@"%@", msg);
    }];
}

- (IBAction)setNotificationState:(id)sender {
    [[IOSGamePlugin getInstance] setNotificationState:YES];
}

- (IBAction)postNotification:(id)sender {
    NSDictionary* userInfo1 = @{@"message":@"Message1",@"delay":@(5),@"badge":@(1)};
    NSDictionary* userInfo2 = @{@"message":@"Message2",@"delay":@(10),@"badge":@(2)};
    NSDictionary* userInfo3 = @{@"message":@"Message3",@"delay":@(15),@"badge":@(3)};
    NSDictionary* userInfo4 = @{@"message":@"Message4",@"delay":@(20),@"badge":@(4)};
    NSDictionary* userInfo5 = @{@"message":@"Message5",@"delay":@(25),@"badge":@(5)};
    [[IOSGamePlugin getInstance] postNotification:userInfo1];
    [[IOSGamePlugin getInstance] postNotification:userInfo2];
    [[IOSGamePlugin getInstance] postNotification:userInfo3];
    [[IOSGamePlugin getInstance] postNotification:userInfo4];
    [[IOSGamePlugin getInstance] postNotification:userInfo5];
}

- (IBAction)showImgDialog:(id)sender {
    [[IOSGamePlugin getInstance] showImageDialog:@"2048x1536_01.png" :@"12.png" :^(BOOL result) {
        NSLog(@"%@", result?@"YES":@"NO");
    }];
}

- (IBAction)showProgressDialog:(id)sender {
    [[IOSSystemUtil getInstance] showProgressDialog:@"loading" :20];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*2), dispatch_get_main_queue(), ^{
        [[IOSSystemUtil getInstance] showProgressDialog:@"uncompress" :80];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*2), dispatch_get_main_queue(), ^{
            [[IOSSystemUtil getInstance] hideProgressDialog];
        });
    });
}

- (IBAction)gcReportScore:(id)sender {
    [[IOSGamePlugin getInstance] gcReportScore:10 leaderboard:@"level" sortH2L:YES];
}

- (IBAction)gcGetScore:(id)sender {
    NSLog(@"%d", [[IOSGamePlugin getInstance] gcGetScore:@"level"]);
}

- (IBAction)gcReportAchievement:(id)sender {
    [[IOSGamePlugin getInstance] gcReportAchievement:@"millionaire" percentComplete:80];
}

- (IBAction)gcGetAchievement:(id)sender {
    NSLog(@"%f", [[IOSGamePlugin getInstance] gcGetAchievement:@"millionaire"]);
}

- (IBAction)gcLeaderBoard:(id)sender {
    [[IOSGamePlugin getInstance] gcShowLeaderBoard];
}

- (IBAction)gcAchievement:(id)sender {
    [[IOSGamePlugin getInstance] gcShowArchievement];
}

- (IBAction)gcReset:(id)sender {
    [[IOSGamePlugin getInstance] gcReset];
}

- (IBAction)virbrate:(id)sender {
    [[IOSSystemUtil getInstance] vibrate];
}

- (IBAction)showToast:(id)sender {
    [[IOSSystemUtil getInstance] showMessage:@"Hello World Hello World Hello World Hello World Hello World Hello World"];
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

- (IBAction)showBanner:(id)sender {
    [[IOSAdvertiseHelper getInstance] showBannerAd:YES :YES];
}

- (IBAction)hideBanner:(id)sender {
    [[IOSAdvertiseHelper getInstance] hideBannerAd];
}





#pragma mark - Analytic

@end

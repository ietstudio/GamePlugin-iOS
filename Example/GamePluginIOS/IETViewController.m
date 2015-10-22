//
//  IETViewController.m
//  GamePluginIOS
//
//  Created by gaoyang on 08/26/2015.
//  Copyright (c) 2015 gaoyang. All rights reserved.
//

#import "IETViewController.h"
#import "IOSGamePlugin.h"

@interface IETViewController ()

@end

@implementation IETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sad:(id)sender {
//    [[IOSGamePlugin getInstance] showLoading:@"Loading"];
//    [[IOSGamePlugin getInstance] doIap:@[@"com.ietstudio.mayaslot.coin2"]
//                                      :@"com.ietstudio.mayaslot.coin2"
//                                      :@"00001"
//                                      :^(BOOL result, NSString *msg) {
//                                          [[IOSGamePlugin getInstance] hideLoading];
//                                          [[IOSGamePlugin getInstance] showChooseView:@""
//                                                                                     :msg
//                                                                                     :@"cancel"
//                                                                                     :@"ok"
//                                                                                     :nil];
//                                      }];
    [[IOSGamePlugin getInstance] showLoading:@"Loading"];
    [[IOSGamePlugin getInstance] hideLoading];
}
- (IBAction)restore:(id)sender {
//    [[IOSGamePlugin getInstance] showLoading:@"Loading"];
//    [[IOSGamePlugin getInstance] doIap:@[@"com.ietstudio.mayaslot.coin10"]
//                                      :@"com.ietstudio.mayaslot.coin10"
//                                      :@"00001"
//                                      :^(BOOL result, NSString *msg) {
//                                          [[IOSGamePlugin getInstance] hideLoading];
//                                          [[IOSGamePlugin getInstance] showChooseView:@""
//                                                                                     :msg
//                                                                                     :@"cancel"
//                                                                                     :@"ok"
//                                                                                     :nil];
//                                      }];
//    [[IOSGamePlugin getInstance] showChartViewWithArr:@[@1.0, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2, @0.2,@0.5,@0.2] multiply:1];
    [[IOSGamePlugin getInstance] hideLoading];
}

@end

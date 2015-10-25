//
//  AMAdvertiseDelegate.m
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import "AMAdvertiseDelegate.h"
#import "AMAdvertiseHelper.h"

@implementation AMAdvertiseDelegate

SINGLETON_DEFINITION(AMAdvertiseDelegate)

- (instancetype)init {
    if (self = [super init]) {
        _clicked = NO;
    }
    return self;
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"interstitial:didFailToReceiveAdWithError");
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10*NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [[AMAdvertiseHelper getInstance] createAndLoadInterstitial];
    });
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    _clicked = YES;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    _spotFunc(_clicked);
}

@end

//
//  CBAdvertiseDelegate.m
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import "CBAdvertiseDelegate.h"

@implementation CBAdvertiseDelegate

SINGLETON_DEFINITION(CBAdvertiseDelegate)

- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error {
    NSLog(@"didFailToLoadInterstitial");
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10*NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [Chartboost cacheInterstitial:CBLocationDefault];
    });
}

- (void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error {
    NSLog(@"didFailToLoadRewardedVideo");
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10*NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [Chartboost cacheRewardedVideo:CBLocationDefault];
    });
}

- (void)didClickInterstitial:(CBLocation)location {
    _spotFunc(YES);
}

- (void)didCloseInterstitial:(CBLocation)location {
    _spotFunc(NO);
}

- (void)didClickRewardedVideo:(CBLocation)location {
    _vedioClickFunc(YES);
}

- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    _vedioViewFunc(YES);
}

@end

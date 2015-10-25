//
//  AMAdvertiseHelper.m
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import "AMAdvertiseHelper.h"
#import "SystemUtil.h"
#import "AMAdvertiseDelegate.h"
@import GoogleMobileAds;

@implementation AMAdvertiseHelper
{
    NSString* _admobSpotId;
    GADInterstitial* _interstitial;
}

SINGLETON_DEFINITION(AMAdvertiseHelper)

- (void)createAndLoadInterstitial {
    _interstitial = [[GADInterstitial alloc] initWithAdUnitID:_admobSpotId];
    [_interstitial setDelegate:[AMAdvertiseDelegate getInstance]];
    GADRequest *request = [GADRequest request];
    [_interstitial loadRequest:request];
}

#pragma mark - AdvertiseDelegate

- (BOOL)showSpotAd:(void (^)(BOOL))func {
    if ([_interstitial isReady]) {
        UIViewController* controller = [[SystemUtil getInstance] getCurrentViewController];
        [_interstitial presentFromRootViewController:controller];
        [self createAndLoadInterstitial];
        [AMAdvertiseDelegate getInstance]->_spotFunc = func;
        return YES;
    }
    return NO;
}

- (BOOL)isVedioAdReady {
    NSLog(@"don't support");
    return NO;
}

- (BOOL)showVedioAd:(void (^)(BOOL))viewFunc :(void (^)(BOOL))clickFunc {
    NSLog(@"don't support");
    return NO;
}

- (NSString *)getName {
    return Admob_Name;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    _admobSpotId = [[SystemUtil getInstance] getConfigValueWithKey:Admob_UnitId];
    [self createAndLoadInterstitial];
    return YES;
}

@end

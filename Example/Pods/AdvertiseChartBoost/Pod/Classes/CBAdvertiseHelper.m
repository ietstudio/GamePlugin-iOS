//
//  CBAdvertiseHelper.m
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import "CBAdvertiseHelper.h"
#import "SystemUtil.h"
#import "CBAdvertiseDelegate.h"

#pragma mark - CBAdvertiseHelper

@implementation CBAdvertiseHelper

SINGLETON_DEFINITION(CBAdvertiseHelper)

#pragma mark - AdvertiseDelegate

- (BOOL)showSpotAd:(void (^)(BOOL))func {
    if ([Chartboost hasInterstitial:CBLocationDefault]) {
        [Chartboost showInterstitial:CBLocationDefault];
        [CBAdvertiseDelegate getInstance]->_spotFunc = func;
        return YES;
    }
    return NO;
}

- (BOOL)isVedioAdReady {
    return [Chartboost hasRewardedVideo:CBLocationDefault];
}

- (BOOL)showVedioAd:(void (^)(BOOL))viewFunc :(void (^)(BOOL))clickFunc {
    if ([self isVedioAdReady]) {
        [CBAdvertiseDelegate getInstance]->_vedioViewFunc = viewFunc;
        [CBAdvertiseDelegate getInstance]->_vedioClickFunc = clickFunc;
        [Chartboost showRewardedVideo:CBLocationDefault];
        return YES;
    }
    return NO;
}

- (NSString *)getName {
    return ChartBoost_Name;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString* appId = [[SystemUtil getInstance] getConfigValueWithKey:ChartBoost_AppId];
    NSString* appSignature = [[SystemUtil getInstance] getConfigValueWithKey:ChartBoost_AppSignature];
    CBAdvertiseDelegate* delegate = [CBAdvertiseDelegate getInstance];
    [Chartboost startWithAppId:appId
                  appSignature:appSignature
                      delegate:delegate];
    [Chartboost cacheInterstitial:CBLocationDefault];
    [Chartboost cacheRewardedVideo:CBLocationDefault];
    [Chartboost setAutoCacheAds:YES];
    return YES;
}



@end

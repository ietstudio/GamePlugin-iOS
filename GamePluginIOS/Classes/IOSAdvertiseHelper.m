//
//  IOSAdvertiseHelper.m
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import "IOSAdvertiseHelper.h"
#import "IOSAnalyticHelper.h"
#import "IOSSystemUtil.h"
#import "AFNetworking.h"

@implementation IOSAdvertiseHelper
{
    NSDictionary* _advertiseHelpers;
    
    NSString* _bannerName;
    id<AdvertiseDelegate> _bannerHelper;
    
    NSArray* _spotNames;
    id<AdvertiseDelegate> _spotHelper;
    
    NSArray* _videoNames;
    id<AdvertiseDelegate> _videoHelper;
}

SINGLETON_DEFINITION(IOSAdvertiseHelper)

- (instancetype)init {
    if (self = [super init]) {
        NSArray* helperNames = @[
                         @"AMAdvertiseHelper",//admob
                         @"CBAdvertiseHelper",//chartboost
                         @"UAAdvertiseHelper",//unityads
                         @"ACAdvertiseHelper",//adcolony
                         @"VGAdvertiseHelper",//vungle
                         @"ALAdvertiseHelper",//applovin
                         @"IMAdvertiseHelper",//immobi
                         @"TGAdvertiseHelper",//tencentgdt
                         ];
        NSMutableDictionary* helpers = [NSMutableDictionary dictionary];
        for (int i=0; i<[helperNames count]; i++) {
            NSString* helperName = [helperNames objectAtIndex:i];
            id helper = [NSClassFromString(helperName) getInstance];
            if (helper) {
                [helpers setObject:helper forKey:helperName];
            }
        }
        _advertiseHelpers = helpers;
    }
    return self;
}

- (void)setBannerAdName:(NSString *)name {
    _bannerName = name;
}

- (void)setSpotAdNames:(NSArray *)names {
    _spotNames = names;
}

- (void)setVideoAdNames:(NSArray *)names {
    _videoNames = names;
}

#pragma mark - AdvertiseDelegate

- (int)showBannerAd:(BOOL)portrait :(BOOL)bottom {
    if (_bannerHelper != nil) {
        return -1;
    }
    _bannerHelper = [_advertiseHelpers objectForKey:_bannerName];
    if (_bannerHelper == nil) {
        return -1;
    }
    int height = [_bannerHelper showBannerAd:portrait :bottom];
    NSLog(@"showBannerAd: %@", [_bannerHelper getName]);
    return height;
}

- (void)hideBannerAd {
    if (_bannerHelper == nil) {
        return;
    }
    NSLog(@"hideBannerAd: %@", [_bannerHelper getName]);
    [_bannerHelper hideBannerAd];
    _bannerHelper = nil;
}

- (BOOL)isSpotAdReady {
    id<AdvertiseDelegate> _advertiseHelper = nil;
    BOOL result = NO;
    for (NSString* videoName in _videoNames) {
        _advertiseHelper = [_advertiseHelpers objectForKey:videoName];
        if ([_advertiseHelper performSelector:@selector(isSpotAdReady)]) {
            result = [_advertiseHelper isVedioAdReady];
            if (result) {
                break;
            }
        }
    }
    return result;
}

- (BOOL)showSpotAd:(void (^)(BOOL))func {
    id<AdvertiseDelegate> _advertiseHelper = nil;
    BOOL result = NO;
    for (NSString* spotName in _spotNames) {
        _advertiseHelper = [_advertiseHelpers objectForKey:spotName];
        result = [_advertiseHelper showSpotAd:^(BOOL result) {
            if (result) {
                NSString* name = [_advertiseHelper getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Spot ad clicked", name]);
                [[IOSAnalyticHelper getInstance] onEvent:@"SpotAd Clicked" Label:name];
            } else {
                NSString* name = [_advertiseHelper getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Spot ad dismiss", name]);
                [[IOSAnalyticHelper getInstance] onEvent:@"SpotAd Dismiss" Label:name];
            }
            func(result);
        }];
        if (result) {
            break;
        }
    }
    if (result) {
        NSString* name = [_advertiseHelper getName];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ Spot ad show Success", name]);
        [[IOSAnalyticHelper getInstance] onEvent:@"SpotAd Show Success" Label:name];
    } else {
        NSLog(@"Spot ad show Failed");
        [[IOSAnalyticHelper getInstance] onEvent:@"SpotAd Show Failed"];
    }
    return result;
}

- (BOOL)isVedioAdReady {
    id<AdvertiseDelegate> _advertiseHelper = nil;
    BOOL result = NO;
    for (NSString* videoName in _videoNames) {
        _advertiseHelper = [_advertiseHelpers objectForKey:videoName];
        result = [_advertiseHelper isVedioAdReady];
        if (result) {
            break;
        }
    }
    return result;
}

- (BOOL)showVedioAd:(void (^)(BOOL))viewFunc :(void (^)(BOOL))clickFunc {
    id<AdvertiseDelegate> _advertiseHelper = nil;
    BOOL result = NO;
    for (NSString* videoName in _videoNames) {
        _advertiseHelper = [_advertiseHelpers objectForKey:videoName];
        result = [_advertiseHelper showVedioAd:^(BOOL result) {
            if (result) {
                NSString* name = [_advertiseHelper getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Vedio ad play finish", name]);
                [[IOSAnalyticHelper getInstance] onEvent:@"VedioAd Play Finish" Label:name];
            }
            viewFunc(result);
        } :^(BOOL result) {
            if (result) {
                NSString* name = [_advertiseHelper getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Vedio ad clicked", name]);
                [[IOSAnalyticHelper getInstance] onEvent:@"VedioAd Clicked" Label:name];
            }
            clickFunc(result);
        }];
        if (result) {
            break;
        }
    }
    if (result) {
        NSString* name = [_advertiseHelper getName];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ Vedio ad show Success", name]);
        [[IOSAnalyticHelper getInstance] onEvent:@"VedioAd Show Success" Label:name];
    } else {
        NSLog(@"Vedio ad show Failed");
        [[IOSAnalyticHelper getInstance] onEvent:@"VedioAd Show Failed"];
    }
    return result;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    for (NSString* key in _advertiseHelpers) {
        id<AdvertiseDelegate> advertiseHelper = [_advertiseHelpers objectForKey:key];
        [advertiseHelper application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
//    @"AMAdvertiseHelper",//admob
//    @"CBAdvertiseHelper",//chartboost
//    @"ALAdvertiseHelper",//applovin
//    @"UAAdvertiseHelper",//unityads
//    @"ACAdvertiseHelper",//adcolony
//    @"VGAdvertiseHelper",//vungle
    // default helper
    [self setBannerAdName:@"AMAdvertiseHelper"];
    [self setSpotAdNames:@[@"AMAdvertiseHelper",
                           @"CBAdvertiseHelper",
                           @"ALAdvertiseHelper"]];
    [self setVideoAdNames:@[@"AMAdvertiseHelper",
                            @"ACAdvertiseHelper",
                            @"ALAdvertiseHelper",
                            @"VGAdvertiseHelper",
                            @"UAAdvertiseHelper",
                            @"CBAdvertiseHelper"]];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {

}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
}

@end









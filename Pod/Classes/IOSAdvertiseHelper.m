//
//  IOSAdvertiseHelper.m
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import "IOSAdvertiseHelper.h"

@implementation IOSAdvertiseHelper
{
    NSMutableArray *_spotDelegates;
    NSMutableArray *_vedioDelegates;
}

SINGLETON_DEFINITION(IOSAdvertiseHelper)

- (instancetype)init {
    if (self = [super init]) {
        _spotDelegates = [NSMutableArray array];
        id admobHelper = [NSClassFromString(@"AMAdvertiseHelper") getInstance];
        if (admobHelper) {
            [_spotDelegates addObject:admobHelper];
        }
        id chartBoostHelper = [NSClassFromString(@"CBAdvertiseHelper") getInstance];
        if (chartBoostHelper) {
            [_spotDelegates addObject:chartBoostHelper];
        }
        
        _vedioDelegates = [NSMutableArray array];
    }
    return self;
}

#pragma mark - public method

- (BOOL)showSpotAd:(void (^)(BOOL))func {
    id<AdvertiseDelegate> spotDelegate = nil;
    BOOL result = NO;
    
    // 按照优先级显示插屏
    for (spotDelegate in _spotDelegates) {
        result = [spotDelegate showSpotAd:^(BOOL result) {
            if (result) {
                NSString* name = [spotDelegate getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Spot ad clicked", name]);
            }
            func(result);
        }];
        GGBREAK_IF(result)
    }
    
    if (result) {
        NSString* name = [spotDelegate getName];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ Spot ad show Success", name]);
    } else {
        NSLog(@"Spot ad show Failed");
    }
    return result;
}

- (BOOL)isVedioAdReady {
    BOOL result = NO;
    for (id<AdvertiseDelegate> delegate in _vedioDelegates) {
        result = [delegate isVedioAdReady];
        NSString* name = [delegate getName];
        NSString* state = result?@"YES":@"NO";
        NSLog(@"%@ vedio %@", name, state);
        GGBREAK_IF(result)
    }
    return result;
}

- (BOOL)showVedioAd:(void (^)(BOOL))viewFunc :(void (^)(BOOL))clickFunc {
    id<AdvertiseDelegate> vedioDelegate = nil;
    BOOL result = NO;
    
    // 按照优先级显示视频
    for (vedioDelegate in _vedioDelegates) {
        result = [vedioDelegate showVedioAd:^(BOOL result) {
            if (result) {
                NSString* name = [vedioDelegate getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Vedio ad play finish", name]);
            }
            viewFunc(result);
        } :^(BOOL result) {
            if (result) {
                NSString* name = [vedioDelegate getName];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ Vedio ad clicked", name]);
            }
            clickFunc(result);
        }];
        GGBREAK_IF(result)
    }
    
    if (result) {
        NSString* name = [vedioDelegate getName];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ Vedio ad show Success", name]);
    } else {
        NSLog(@"Vedio ad show Failed");
    }
    return result;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    for (id<AdvertiseDelegate> delegate in _spotDelegates) {
        [delegate application:application didFinishLaunchingWithOptions:launchOptions];
    }
    for (id<AdvertiseDelegate> delegate in _vedioDelegates) {
        [delegate application:application didFinishLaunchingWithOptions:launchOptions];
    }
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
}

@end









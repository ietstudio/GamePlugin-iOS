//
//  IOSAnalyticHelper.m
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import "IOSAnalyticHelper.h"

#ifdef COCOAPODS_POD_AVAILABLE_AnalyticTD
#import "TDAnalyticHelper.h"
#endif//COCOAPODS_POD_AVAILABLE_AnalyticTD

#ifdef COCOAPODS_POD_AVAILABLE_AnalyticUM
#import "UMAnalyticHelper.h"
#endif//COCOAPODS_POD_AVAILABLE_AnalyticUM

@implementation IOSAnalyticHelper
{
    NSMutableArray *_delegates;
}

SINGLETON_DEFINITION(IOSAnalyticHelper)

- (instancetype)init {
    if (self = [super init]) {
        _delegates = [NSMutableArray array];
#ifdef COCOAPODS_POD_AVAILABLE_AnalyticTD
        [_delegates addObject:[TDAnalyticHelper getInstance]];
#endif//COCOAPODS_POD_AVAILABLE_AnalyticTD
#ifdef COCOAPODS_POD_AVAILABLE_AnalyticUM
        [_delegates addObject:[UMAnalyticHelper getInstance]];
#endif//COCOAPODS_POD_AVAILABLE_AnalyticUM
    }
    // 在DEBUG下不发送统计事件
#if DEBUG
    return nil;
#else
    return self;
#endif
}

#pragma mark - public method

- (void)setAccoutInfo:(NSDictionary *)dict {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate setAccoutInfo:dict];
    }
}

- (void)onEvent:(NSString *)eventId {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate onEvent:eventId];
    }
}

- (void)onEvent:(NSString *)eventId Label:(NSString *)label {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate onEvent:eventId Label:label];
    }
}

- (void)setLevel:(int)level {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate setLevel:level];
    }
}

- (void)charge:(NSString *)name :(double)cash :(double)coin :(int)type {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate charge:name :cash :coin :type];
    }
}

- (void)reward:(double)coin :(int)type {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate reward:coin :type];
    }
}

- (void)purchase:(NSString *)name :(int)amount :(double)coin {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate purchase:name :amount :coin];
    }
}

- (void)use:(NSString *)name :(int)amount :(double)coin {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate use:name :amount :coin];
    }
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    for (id<AnalyticDelegate> delegate in _delegates) {
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

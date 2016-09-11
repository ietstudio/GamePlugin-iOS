//
//  IOSAnalyticHelper.m
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import "IOSAnalyticHelper.h"

@implementation IOSAnalyticHelper
{
    NSMutableArray *_delegates;
}

SINGLETON_DEFINITION(IOSAnalyticHelper)

- (instancetype)init {
    if (self = [super init]) {
        _delegates = [NSMutableArray array];
        id talkingdataHelper = [NSClassFromString(@"TDAnalyticHelper") getInstance];
        if (talkingdataHelper) {
            [_delegates addObject:talkingdataHelper];
        }
        id umengHelper = [NSClassFromString(@"UMAnalyticHelper") getInstance];
        if (umengHelper) {
            [_delegates addObject:umengHelper];
        }
        id flurryHelper = [NSClassFromString(@"FLAnalyticHelper") getInstance];
        if (flurryHelper) {
            [_delegates addObject:flurryHelper];
        }
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

- (void)onEvent:(NSString *)eventId eventData:(NSDictionary *)userInfo {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate onEvent:eventId eventData:userInfo];
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

- (void)missionStart:(NSString *)missionId {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate missionStart:missionId];
    }
}

- (void)missionSuccess:(NSString *)missionId {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate missionSuccess:missionId];
    }
}

- (void)missionFailed:(NSString *)missionId because:(NSString *)reason {
    for (id<AnalyticDelegate> delegate in _delegates) {
        [delegate missionFailed:missionId because:reason];
    }
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
            [delegate application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [delegate applicationDidBecomeActive:application];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(applicationWillResignActive:)]) {
            [delegate applicationWillResignActive:application];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [delegate applicationDidEnterBackground:application];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [delegate applicationWillEnterForeground:application];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
            [delegate application:application
                          openURL:url
                sourceApplication:sourceApplication
                       annotation:annotation];
        }
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [delegate application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            [delegate application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            [delegate application:application didReceiveRemoteNotification:userInfo];
        }
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(application:handleActionWithIdentifier:forRemoteNotification:completionHandler:)]) {
            [delegate application:application
       handleActionWithIdentifier:identifier
            forRemoteNotification:userInfo
                completionHandler:completionHandler];
        }
    }
}

@end

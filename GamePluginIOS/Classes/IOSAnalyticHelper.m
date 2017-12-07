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
        NSArray *classNames = @[@"TDAnalyticHelper",
                                @"FLAnalyticHelper",
                                @"FacebookHelper"];
        for (NSString* className in classNames) {
            id analyticHelper = [NSClassFromString(className) getInstance];
            if (analyticHelper) {
                NSString *name = [analyticHelper getName];
                [_delegates addObject:analyticHelper];
                NSLog(@"Analytic added: %@", name);
            }
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
        if ([delegate respondsToSelector:@selector(setAccoutInfo:)]) {
            [delegate setAccoutInfo:dict];
            NSLog(@"Analytic setAccoutInfo: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic setAccoutInfo: %@", dict);
}

- (void)onEvent:(NSString *)eventId {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(onEvent:)]) {
            [delegate onEvent:eventId];
            NSLog(@"Analytic onEvent1: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic onEvent1: %@", eventId);
}

- (void)onEvent:(NSString *)eventId Label:(NSString *)label {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(onEvent:Label:)]) {
            [delegate onEvent:eventId Label:label];
            NSLog(@"Analytic onEvent2: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic onEvent2: %@, %@", eventId, label);
}

- (void)onEvent:(NSString *)eventId eventData:(NSDictionary *)userInfo {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(onEvent:eventData:)]) {
            [delegate onEvent:eventId eventData:userInfo];
            NSLog(@"Analytic onEvent3: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic onEvent3: %@, %@", eventId, userInfo);
}

- (void)setLevel:(int)level {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(setLevel:)]) {
            [delegate setLevel:level];
            NSLog(@"Analytic setLevel: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic setLevel: %d", level);
}

- (void)charge:(NSString *)name :(double)cash :(double)coin :(int)type {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(charge::::)]) {
            [delegate charge:name :cash :coin :type];
            NSLog(@"Analytic charge1: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic charge1: %@, %f, %f, %d", name, cash, coin, type);
}

- (void)charge:(SKPaymentTransaction *)transaction {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(charge:)]) {
            [delegate charge:transaction];
            NSLog(@"Analytic charge2: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic charge2: %@", transaction);
}

- (void)reward:(double)coin :(int)type {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(reward::)]) {
            [delegate reward:coin :type];
            NSLog(@"Analytic reward: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic reward: %f, %d", coin, type);
}

- (void)purchase:(NSString *)name :(int)amount :(double)coin {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(purchase:::)]) {
            [delegate purchase:name :amount :coin];
            NSLog(@"Analytic purchase: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic purchase: %@, %d, %f", name, amount, coin);
}

- (void)use:(NSString *)name :(int)amount :(double)coin {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(use:::)]) {
            [delegate use:name :amount :coin];
            NSLog(@"Analytic use: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic use: %@, %d, %f", name, amount, coin);
}

- (void)missionStart:(NSString *)missionId {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(missionStart:)]) {
            [delegate missionStart:missionId];
            NSLog(@"Analytic missionStart: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic missionStart: %@", missionId);
}

- (void)missionSuccess:(NSString *)missionId {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(missionSuccess:)]) {
            [delegate missionSuccess:missionId];
            NSLog(@"Analytic missionSuccess: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic missionSuccess: %@", missionId);
}

- (void)missionFailed:(NSString *)missionId because:(NSString *)reason {
    for (id<AnalyticDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(missionFailed:because:)]) {
            [delegate missionFailed:missionId because:reason];
            NSLog(@"Analytic missionFailed: %@", [delegate getName]);
        }
    }
    NSLog(@"Analytic missionFailed: %@, %@", missionId, reason);
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

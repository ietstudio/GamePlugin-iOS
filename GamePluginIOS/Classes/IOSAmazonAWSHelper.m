//
//  IOSAmazonAWSHelper.m
//  Pods
//
//  Created by geekgy on 15/10/28.
//
//

#import "IOSAmazonAWSHelper.h"

@implementation IOSAmazonAWSHelper
{
    id _instance;
}

SINGLETON_DEFINITION(IOSAmazonAWSHelper)

- (instancetype)init {
    if (self = [super init]) {
        _instance = [NSClassFromString(@"AmazonAWSHelper") getInstance];
    }
    return self;
}

- (void)sync:(NSString *)data :(void (^)(BOOL, NSString *))callback {
    [_instance sync:data :callback];
}

- (NSString *)getUserId {
    return [_instance getUserId];
}

- (void)connectFb:(NSString *)token {
    [_instance connectFb:token];
}

- (void)setNotificationFunc:(void (^)(NSDictionary *))callback {
    [_instance setNotificationFunc:callback];
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [_instance application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [_instance applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [_instance applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [_instance applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [_instance applicationWillEnterForeground:application];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [_instance application:application
                   openURL:url
         sourceApplication:sourceApplication
                annotation:annotation];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [_instance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [_instance application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_instance application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [_instance application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
}

@end

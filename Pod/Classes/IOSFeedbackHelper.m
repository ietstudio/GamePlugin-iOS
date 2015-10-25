//
//  IOSFeedbackHelper.m
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import "IOSFeedbackHelper.h"

@implementation IOSFeedbackHelper
{
    NSMutableArray *_delegates;
}

SINGLETON_DEFINITION(IOSFeedbackHelper)

- (instancetype)init {
    if (self = [super init]) {
        _delegates = [NSMutableArray array];
        id freshDeskHelper = [NSClassFromString(@"FDFeedbackHelper") getInstance];
        if (freshDeskHelper) {
            [_delegates addObject:freshDeskHelper];
        }
    }
    return self;
}

#pragma mark - public method

- (BOOL)showFeedBack:(NSDictionary *)userInfo {
    BOOL result = NO;
    for (id<FeedbackDelegate> delegate in _delegates) {
        result = [delegate showFeedBack:userInfo];
        if (result) {
            break;
        }
    }
    return YES;
}

- (int)checkFeedBack {
    int result = 0;
    for (id<FeedbackDelegate> delegate in _delegates) {
        result = [delegate checkFeedBack];
        if (result>0) {
            break;
        }
    }
    return result;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    for (id<FeedbackDelegate> delegate in _delegates) {
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

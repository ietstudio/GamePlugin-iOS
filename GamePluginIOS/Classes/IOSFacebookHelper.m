//
//  IOSFacebookHelper.m
//  Pods
//
//  Created by geekgy on 15/10/28.
//
//

#import "IOSFacebookHelper.h"
#import "IOSAnalyticHelper.h"

@implementation IOSFacebookHelper
{
    id _instance;
}

SINGLETON_DEFINITION(IOSFacebookHelper)

- (instancetype)init {
    if (self = [super init]) {
        _instance = [NSClassFromString(@"FacebookHelper") getInstance];
    }
    return self;
}

- (void)setLoginFunc:(void (^)(NSString *, NSString *))func {
    [_instance setLoginFunc:func];
}

- (void)setAppLinkFunc:(void (^)(NSDictionary *))func {
    [_instance setAppLinkFunc:func];
}

- (void)openFacebookPage:(NSString *)installUrl :(NSString *)url {
    [_instance openFacebookPage:installUrl :url];
}

- (BOOL)isLogin {
    return [_instance isLogin];
}

- (void)login {
    [_instance login];
}

- (void)logout {
    [_instance logout];
}

- (NSString *)getUserID {
    return [_instance getUserID];
}

- (NSString *)getAccessToken {
    return [_instance getAccessToken];
}

- (void)getUserProfile:(void (^)(NSDictionary *))func {
    [_instance getUserProfile:func];
}

- (void)getInvitableFriends:(NSArray *)inviteTokens :(void (^)(NSDictionary *))func {
    [_instance getInvitableFriends:inviteTokens :func];
}

- (void)getFriends:(void (^)(NSDictionary *))func {
    [_instance getFriends:func];
}

- (void)confirmRequest:(NSArray *)fidOrTokens withTitle:(NSString *)title withMsg:(NSString *)msg :(void (^)(NSDictionary *))func {
    [_instance confirmRequest:fidOrTokens
                    withTitle:title
                      withMsg:msg
                             :func];
}

- (void)queryRequest:(void (^)(NSDictionary *))func {
    [_instance queryRequest:func];
}

- (void)acceptRequest:(NSString *)requestId :(void (^)(BOOL))func {
    [_instance acceptRequest:requestId :func];
}

- (void)shareName:(NSString *)name description:(NSString *)description imageUrl:(NSString *)imageUrl contentUrl:(NSString *)contentUrl caption:(NSString *)caption :(void (^)(BOOL))func {
    [_instance shareName:name
             description:description
                imageUrl:imageUrl
              contentUrl:contentUrl
                 caption:caption
                        :func];
}

- (void)setLevel:(int)level {
    [_instance setLevel:level];
}

- (void)getLevel:(NSString *)fid :(void (^)(int))func {
    [_instance getLevel:fid :func];
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

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [_instance application:application handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:completionHandler];
}

@end

//
//  IETAppDelegate.m
//  GamePluginIOS
//
//  Created by gaoyang on 06/11/2016.
//  Copyright (c) 2016 gaoyang. All rights reserved.
//

#import "IETAppDelegate.h"
#import "IOSGamePlugin.h"
#import "IOSSystemUtil.h"

@implementation IETAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    self.window.rootViewController=[storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    [[IOSSystemUtil getInstance] setWindow:self.window];
    [[IOSSystemUtil getInstance] setController:self.window.rootViewController];
    [[IOSGamePlugin getInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[IOSGamePlugin getInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[IOSGamePlugin getInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[IOSGamePlugin getInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[IOSGamePlugin getInstance] applicationDidBecomeActive:application];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[IOSGamePlugin getInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[IOSGamePlugin getInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[IOSGamePlugin getInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[IOSGamePlugin getInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [[IOSGamePlugin getInstance] application:application
                  handleActionWithIdentifier:identifier
                       forRemoteNotification:userInfo
                           completionHandler:completionHandler];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

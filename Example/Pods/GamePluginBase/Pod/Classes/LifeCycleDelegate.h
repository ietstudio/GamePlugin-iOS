//
//  LifeCycleDelegate.h
//  Pods
//
//  Created by geekgy on 15-5-2.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LifeCycleDelegate <NSObject>

@optional

/**
 *  代理启动基本完成程序准备开始运行
 *
 *  @param application
 *  @param launchOptions
 *
 *  @return
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 *  当应用程序入活动状态执行，这个刚好跟上面那个方法相反
 *
 *  @param application
 */
- (void)applicationDidBecomeActive:(UIApplication *)application;

/**
 *  当应用程序将要入非活动状态执行，在此期间，应用程序不接收消息或事件，比如来电话了
 *
 *  @param applicationDidEnterBackground
 *  @param application
 */
- (void)applicationWillResignActive:(UIApplication *)application;

/**
 *  当程序被推送到后台的时候调用。所以要设置后台继续运行，则在这个函数里面设置即可
 *
 *  @param application
 */
- (void)applicationDidEnterBackground:(UIApplication *)application;

/**
 *  当程序从后台将要重新回到前台时候调用，这个刚好跟上面的那个方法相反。
 *
 *  @param application
 */
- (void)applicationWillEnterForeground:(UIApplication *)application;

/**
 *
 *
 *  @param application
 *  @param url
 *  @param sourceApplication
 *  @param annotation
 *
 *  @return 
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 *
 *
 *  @param application
 *  @param deviceToken
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 *
 *
 *  @param application
 *  @param error
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 *
 *
 *  @param application
 *  @param userInfo
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 *
 *
 *  @param application
 *  @param identifier
 *  @param userInfo
 *  @param completionHandler
 */
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler;


@end

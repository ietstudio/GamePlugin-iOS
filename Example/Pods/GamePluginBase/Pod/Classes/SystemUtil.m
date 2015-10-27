//
//  SystemUtil.m
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import "SystemUtil.h"

// 默认国家
#define DEFAULT_COUNTRY_CODE @"US"

// 配置信息
#define IETCONFIGS_KEY                      @"IETConfigs"

@implementation SystemUtil

SINGLETON_DEFINITION(SystemUtil)

#pragma mark - private

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

#pragma mark - public

- (NSString *)getCountryCode {
    NSString *country = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    if(!country) {
        country = [[NSLocale systemLocale] objectForKey:NSLocaleCountryCode];
    }
    country = country==nil ? DEFAULT_COUNTRY_CODE : country;
    return country;
}

- (UIWindow *)getCurrentWindow {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return window;
}

- (UIViewController *)getCurrentViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (NSString *)getConfigValueWithKey:(NSString *)key {
    NSDictionary* configs = [[NSBundle mainBundle] objectForInfoDictionaryKey:IETCONFIGS_KEY];
    return [configs objectForKey:key];
}

@end

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
    UIViewController *controller = [[self getCurrentWindow] rootViewController];
    return controller;
}

- (NSString *)getConfigValueWithKey:(NSString *)key {
    NSDictionary* configs = [[NSBundle mainBundle] objectForInfoDictionaryKey:IETCONFIGS_KEY];
    return [configs objectForKey:key];
}

@end

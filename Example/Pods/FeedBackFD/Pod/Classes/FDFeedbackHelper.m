//
//  FDFeedbackHelper.m
//  Pods
//
//  Created by geekgy on 15/9/15.
//
//

#import "FDFeedbackHelper.h"
#import "SystemUtil.h"
#import "Mobihelp.h"

@implementation FDFeedbackHelper

SINGLETON_DEFINITION(FDFeedbackHelper)

#pragma mark - private method

#pragma mark - public method

- (BOOL)showFeedBack:(NSDictionary *)userInfo {
    [[Mobihelp sharedInstance] clearCustomData];
    
    NSArray* userInfoKeys = [userInfo allKeys];
    for (int i=0; i<[userInfoKeys count]; i++) {
        NSString* key = [userInfoKeys objectAtIndex:i];
        NSString* value = [userInfo objectForKey:key];
        [[Mobihelp sharedInstance] addCustomDataForKey:key withValue:value];
        if ([key isEqual:@"user_name"]) {
            [[Mobihelp sharedInstance] setUserName:value];
        }
        if ([key isEqual:@"email"]) {
            [[Mobihelp sharedInstance] setEmailAddress:value];
        }
    }
    
    UIWindow* window = [[SystemUtil getInstance] getCurrentWindow];
    [[Mobihelp sharedInstance] presentSupport:[window rootViewController]];
    return YES;
}

- (int)checkFeedBack {
    return (int)[[Mobihelp sharedInstance] unreadCount];
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString* domain = [[SystemUtil getInstance] getConfigValueWithKey:FRESHDESK_DOMAIN];
    NSString* key = [[SystemUtil getInstance] getConfigValueWithKey:FRESHDESK_KEY];
    NSString* secret = [[SystemUtil getInstance] getConfigValueWithKey:FRESHDESK_SECRET];
    NSString* appleId = [[SystemUtil getInstance] getConfigValueWithKey:APPLE_ID];
    MobihelpConfig *config = [[MobihelpConfig alloc]initWithDomain:domain
                                                        withAppKey:key
                                                      andAppSecret:secret];
    config.appStoreId = appleId;
    config.feedbackType = FEEDBACK_TYPE_NAME_AND_EMAIL_REQUIRED;
    [[Mobihelp sharedInstance] initWithConfig:config];
    return YES;
}

@end

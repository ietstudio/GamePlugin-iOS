//
//  UMAnalyticHelper.m
//  Pods
//
//  Created by geekgy on 15-4-17.
//
//

#import "UMAnalyticHelper.h"
#import "SystemUtil.h"
#import "MobClick.h"
#import "MobClickGameAnalytics.h"

@implementation UMAnalyticHelper

SINGLETON_DEFINITION(UMAnalyticHelper)

#pragma mark - private method

#pragma mark - public method

- (void)setAccoutInfo:(NSDictionary *)dict {
    NSString* accountName = [dict objectForKey:@"userId"];
//    NSString* gender = [dict objectForKey:@"gender"];
//    NSString* age = [dict objectForKey:@"age"];
    [MobClickGameAnalytics profileSignInWithPUID:accountName];
}

- (void)onEvent:(NSString *)eventId {
    [MobClick event:eventId];
}

- (void)onEvent:(NSString *)eventId Label:(NSString *)label {
    [MobClick event:eventId label:label];
}

- (void)setLevel:(int)level {
    [MobClickGameAnalytics setUserLevelId:level];
}

- (void)charge:(NSString *)name :(double)cash :(double)coin :(int)type {
    [MobClickGameAnalytics pay:cash source:type coin:coin];
}

- (void)reward:(double)coin :(int)type {
    [MobClickGameAnalytics bonus:coin source:type];
}

- (void)purchase:(NSString *)name :(int)amount :(double)coin {
    [MobClickGameAnalytics buy:name amount:amount price:coin];
}

- (void)use:(NSString *)name :(int)amount :(double)coin {
    [MobClickGameAnalytics use:name amount:amount price:coin];
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(id)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *key = [[SystemUtil getInstance] getConfigValueWithKey:UMENG_KEY];
    NSString *channel = [[SystemUtil getInstance] getConfigValueWithKey:UMENG_CHANNAL];
    [MobClick startWithAppkey:key reportPolicy:BATCH channelId:channel];
    [MobClick setCrashReportEnabled:NO];
    return YES;
}

@end

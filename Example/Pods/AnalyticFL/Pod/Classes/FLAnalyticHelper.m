//
//  FLAnalyticHelper.m
//  Pods
//
//  Created by geekgy on 15/11/3.
//
//

#import "FLAnalyticHelper.h"
#import <CoreLocation/CoreLocation.h>
#import "SystemUtil.h"
#import "Flurry.h"

@implementation FLAnalyticHelper

SINGLETON_DEFINITION(FLAnalyticHelper)

- (void)setAccoutInfo:(NSDictionary *)dict {
    NSString* userId = [dict objectForKey:@"userId"];
    NSString* gender = [dict objectForKey:@"gender"];
    NSString* age = [dict objectForKey:@"age"];
    if (userId != nil) {
        [Flurry setUserID:userId];
    }
    if (gender != nil) {
        if ([gender isEqualToString:@"male"]) {
            [Flurry setGender:@"m"];
        } else if ([gender isEqualToString:@"female"]) {
            [Flurry setGender:@"f"];
        }
    }
    if (age != nil) {
        [Flurry setAge:[age intValue]];
    }
}

- (void)onEvent:(NSString *)eventId {
    [Flurry logEvent:eventId];
}

- (void)onEvent:(NSString *)eventId Label:(NSString *)label {
    NSDictionary* dict = [NSDictionary dictionaryWithObject:label forKey:@"key"];
    [Flurry logEvent:eventId withParameters:dict];
}

- (void)setLevel:(int)level {
    [Flurry logEvent:@"level" withParameters:@{@"level":@(level)}];
}

- (void)charge:(NSString *)name :(double)cash :(double)coin :(int)type {
    NSDictionary* dict = @{@"name":name, @"cash":@(cash), @"coin":@(coin), @"type":@(type)};
    [Flurry logEvent:@"charge" withParameters:dict];
}

- (void)reward:(double)coin :(int)type {
    NSDictionary* dict = @{@"coin":@(coin), @"type":@(type)};
    [Flurry logEvent:@"reward" withParameters:dict];
}

- (void)purchase:(NSString *)name :(int)amount :(double)coin {
    NSDictionary* dict = @{@"name":name, @"amount":@(amount), @"coin":@(coin)};
    [Flurry logEvent:@"purchase" withParameters:dict];
}

- (void)use:(NSString *)name :(int)amount :(double)coin {
    NSDictionary* dict = @{@"name":name, @"amount":@(amount), @"coin":@(coin)};
    [Flurry logEvent:@"use" withParameters:dict];
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString* flurryKey = [[SystemUtil getInstance] getConfigValueWithKey:FLURRY_KEY];
    [Flurry startSession:flurryKey];
    [Flurry setCrashReportingEnabled:NO];
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    CLLocation *location = locationManager.location;
    [Flurry setLatitude:location.coordinate.latitude
              longitude:location.coordinate.longitude
     horizontalAccuracy:location.horizontalAccuracy
       verticalAccuracy:location.verticalAccuracy];
    return YES;
}

@end

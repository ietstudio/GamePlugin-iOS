//
//  IOSAmazonAWSHelper.m
//  Pods
//
//  Created by geekgy on 15/6/13.
//
//

#import "IOSAmazonAWSHelper.h"
#import "SystemUtil.h"
#import "AWSCore.h"
#import "AWSCognito.h"
#import "AWSSNS.h"
#import "AWSMobileAnalytics.h"

@implementation IOSAmazonAWSHelper
{
    void (^_notificationCallback)(NSDictionary *);
    AWSCognitoCredentialsProvider* credentialsProvider;
    NSString* CognitoIdentityPoolId;
    NSString* MobileAnalyticsAppId;
    NSString* SNSPlatformApplicationArn;
}

SINGLETON_DEFINITION(IOSAmazonAWSHelper)

- (void)identityDidChange:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSLog(@"identity changed from %@ to %@",
          [userInfo objectForKey:AWSCognitoNotificationPreviousId],
          [userInfo objectForKey:AWSCognitoNotificationNewId]);
}

#pragma mark - public method

- (void)sync:(NSString *)data :(void (^)(BOOL, NSString *))callback {
    AWSCognito *syncClient = [AWSCognito defaultCognito];
    syncClient.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
        NSLog(@"syncClient conflic use local");
        return [conflict resolveWithLocalRecord];
    };
    AWSCognitoDataset *dataset = [syncClient openOrCreateDataset:@"myDataset"];
    dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
        NSLog(@"dataset conflic use remote");
        return [conflict resolveWithRemoteRecord];
    };
    [dataset setString:data forKey:@"myKey"];
    [[dataset synchronize] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSString* errorCode = [NSString stringWithFormat:@"%ld", (long)task.error.code];
            NSLog(@"error code: %@", errorCode);
            callback(NO, errorCode);
        } else {
            NSString* data = [dataset stringForKey:@"myKey"];
            callback(YES, data);
        }
        return nil;
    }];
}

- (NSString *)getUserId {
    return credentialsProvider.identityId;
}

- (void)connectFb:(NSString *)token {
    credentialsProvider.logins = @{ @(AWSCognitoLoginProviderKeyFacebook): token };
}

- (void)setNotificationFunc:(void (^)(NSDictionary *))callback {
    _notificationCallback = callback;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AWSRegionType CognitoRegionType = AWSRegionUSEast1;
    AWSRegionType DefaultServiceRegionType = AWSRegionUSEast1;
    
    CognitoIdentityPoolId = [[SystemUtil getInstance] getConfigValueWithKey:AWS_CognitoIdentityPoolId];
    MobileAnalyticsAppId = [[SystemUtil getInstance] getConfigValueWithKey:AWS_MobileAnalyticsAppId];
    
#if DEBUG
    SNSPlatformApplicationArn = [[SystemUtil getInstance] getConfigValueWithKey:AWS_SNSPlatformApplicationArnDev];
#else
    SNSPlatformApplicationArn = [[SystemUtil getInstance] getConfigValueWithKey:AWS_SNSPlatformApplicationArn];
#endif
    
    // cognito
    credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                           initWithRegionType:CognitoRegionType
                           identityPoolId:CognitoIdentityPoolId];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]
                                              initWithRegion:DefaultServiceRegionType
                                              credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    // analytic
    AWSMobileAnalyticsConfiguration *mobileAnalyticsConfiguration = [AWSMobileAnalyticsConfiguration new];
    mobileAnalyticsConfiguration.transmitOnWAN = YES;
    AWSMobileAnalytics *analytics = [AWSMobileAnalytics mobileAnalyticsForAppId: MobileAnalyticsAppId
                                                                  configuration: mobileAnalyticsConfiguration
                                                                completionBlock: nil];
    analytics = analytics;
    // look identity change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(identityDidChange:)
                                                 name:AWSCognitoIdentityIdChangedNotification
                                               object:nil];
    
    NSLog(@"cognitoId = %@", credentialsProvider.identityId);
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification * notification in notifications) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
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
    NSString *deviceTokenString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceTokenString: %@", deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    AWSSNS *sns = [AWSSNS defaultSNS];
    AWSSNSCreatePlatformEndpointInput *request = [AWSSNSCreatePlatformEndpointInput new];
    request.token = deviceTokenString;
    request.customUserData = credentialsProvider.identityId;//设置id
    request.platformApplicationArn = SNSPlatformApplicationArn;
    [[sns createPlatformEndpoint:request] continueWithBlock:^id(AWSTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: %@",task.error);
        } else {
            AWSSNSCreateEndpointResponse *createEndPointResponse = task.result;
            NSLog(@"endpointArn: %@",createEndPointResponse);
            [[NSUserDefaults standardUserDefaults] setObject:createEndPointResponse.endpointArn forKey:@"endpointArn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return nil;
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register with error: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo: %@",userInfo);
    if (_notificationCallback != nil) {
        _notificationCallback(userInfo);
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    AWSMobileAnalytics *mobileAnalytics = [AWSMobileAnalytics mobileAnalyticsForAppId:MobileAnalyticsAppId];
    id<AWSMobileAnalyticsEventClient> eventClient = mobileAnalytics.eventClient;
    id<AWSMobileAnalyticsEvent> pushNotificationEvent = [eventClient createEventWithEventType:@"PushNotificationEvent"];
    
    NSString *action = @"Undefined";
    if ([identifier isEqualToString:@"READ_IDENTIFIER"]) {
        action = @"read";
        NSLog(@"User selected 'Read'");
    } else if ([identifier isEqualToString:@"DELETE_IDENTIFIER"]) {
        action = @"Deleted";
        NSLog(@"User selected `Delete`");
    } else {
        action = @"Undefined";
    }
    
    [pushNotificationEvent addAttribute:action forKey:@"Action"];
    [eventClient recordEvent:pushNotificationEvent];
    
    completionHandler();
}


@end

//
//  IOSAmazonAWSHelper.h
//  Pods
//
//  Created by geekgy on 15/6/13.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "LifeCycleDelegate.h"

#define AWS_CognitoIdentityPoolId           @"AWSCognitoIdentityPoolId"
#define AWS_MobileAnalyticsAppId            @"AWSMobileAnalyticsAppId"
#define AWS_SNSPlatformApplicationArn       @"AWSSNSPlatformApplicationArn"
#define AWS_SNSPlatformApplicationArnDev    @"AWSSNSPlatformApplicationArnDev"

@interface IOSAmazonAWSHelper : NSObject <LifeCycleDelegate>

SINGLETON_DECLARE(IOSAmazonAWSHelper)

/**
 *  数据同步
 *
 *  @param data
 *  @param callback 
 */
- (void)sync:(NSString*)data :(void(^)(BOOL, NSString*))callback;

/**
 *  获取亚马逊为玩家分配的id
 *
 *  @return
 */
- (NSString*)getUserId;

/**
 *  绑定facebook
 *
 *  @param token
 */
- (void)connectFb:(NSString*)token;

/**
 *  设置远程推送事件回调接口
 *
 *  @param callback
 */
- (void)setNotificationFunc:(void(^)(NSDictionary*))callback;

@end

//
//  IOSAmazonAWSHelper.h
//  Pods
//
//  Created by geekgy on 15/10/28.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "LifeCycleDelegate.h"

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

@end

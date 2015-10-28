//
//  IOSAmazonAWSHelper.m
//  Pods
//
//  Created by geekgy on 15/10/28.
//
//

#import "IOSAmazonAWSHelper.h"

@implementation IOSAmazonAWSHelper
{
    id _instance;
}

SINGLETON_DEFINITION(IOSAmazonAWSHelper)

- (instancetype)init {
    if (self = [super init]) {
        _instance = [NSClassFromString(@"AmazonAWSHelper") getInstance];
    }
    return self;
}

- (void)sync:(NSString *)data :(void (^)(BOOL, NSString *))callback {
    [_instance sync:data :callback];
}

- (NSString *)getUserId {
    return [_instance getUserId];
}

- (void)connectFb:(NSString *)token {
    [_instance connectFb:token];
}

- (void)setNotificationFunc:(void (^)(NSDictionary *))callback {
    [_instance setNotificationFunc:callback];
}

@end

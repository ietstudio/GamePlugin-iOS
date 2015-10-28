//
//  IOSFacebookHelper.m
//  Pods
//
//  Created by geekgy on 15/10/28.
//
//

#import "IOSFacebookHelper.h"

@implementation IOSFacebookHelper
{
    id _instance;
}

SINGLETON_DEFINITION(IOSFacebookHelper)

- (instancetype)init {
    if (self = [super init]) {
        _instance = [NSClassFromString(@"FacebookHelper") getInstance];
    }
    return self;
}

- (void)setLoginFunc:(void (^)(NSString *, NSString *))func {
    [_instance setLoginFunc:func];
}

- (void)setAppLinkFunc:(void (^)(NSDictionary *))func {
    [_instance setAppLinkFunc:func];
}

- (void)openFacebookPage:(NSString *)installUrl :(NSString *)url {
    [_instance openFacebookPage:installUrl :url];
}

- (BOOL)isLogin {
    return [_instance isLogin];
}

- (void)login {
    [_instance login];
}

- (void)logout {
    [_instance logout];
}

- (NSString *)getUserID {
    return [_instance getUserID];
}

- (NSString *)getAccessToken {
    return [_instance getAccessToken];
}

- (void)getUserProfile:(void (^)(NSDictionary *))func {
    [_instance getUserProfile:func];
}

- (void)getInvitableFriends:(NSArray *)inviteTokens :(void (^)(NSDictionary *))func {
    [_instance getInvitableFriends:inviteTokens :func];
}

- (void)getFriends:(void (^)(NSDictionary *))func {
    [_instance getFriends:func];
}

- (void)confirmRequest:(NSArray *)fidOrTokens withTitle:(NSString *)title withMsg:(NSString *)msg :(void (^)(NSDictionary *))func {
    [_instance confirmRequest:fidOrTokens
                    withTitle:title
                      withMsg:msg
                             :func];
}

- (void)queryRequest:(void (^)(NSDictionary *))func {
    [_instance queryRequest:func];
}

- (void)acceptRequest:(NSString *)requestId :(void (^)(BOOL))func {
    [_instance acceptRequest:requestId :func];
}

- (void)shareName:(NSString *)name description:(NSString *)description imageUrl:(NSString *)imageUrl contentUrl:(NSString *)contentUrl caption:(NSString *)caption :(void (^)(BOOL))func {
    [_instance shareName:name
             description:description
                imageUrl:imageUrl
              contentUrl:contentUrl
                 caption:caption
                        :func];
}

- (void)setLevel:(int)level {
    [_instance setLevel:level];
}

- (void)getLevel:(NSString *)fid :(void (^)(int))func {
    [_instance getLevel:fid :func];
}

@end

//
//  IOSFacebookHelper.h
//  Pods
//
//  Created by geekgy on 15/10/28.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "LifeCycleDelegate.h"

@interface IOSFacebookHelper : NSObject <LifeCycleDelegate>

SINGLETON_DECLARE(IOSFacebookHelper)

/**
 *  设置Login回调
 *
 *  @param func
 */
- (void)setLoginFunc:(void (^)(NSString* userId, NSString* token))func;

/**
 *  设置AppLink回调
 *
 *  @param callback
 */
- (void)setAppLinkFunc:(void (^)(NSDictionary *dict))func;

/**
 *  打开facebook主页
 *
 *  @param installUrl 主页
 *  @param url        主页url
 */
- (void)openFacebookPage:(NSString*)installUrl :(NSString*)url;

/**
 *  是否已经登陆
 *
 *  @return
 */
- (BOOL)isLogin;

/**
 *  开始登陆
 *
 *  @param func 回调block
 */
- (void)login;

/**
 *  登出
 */
- (void)logout;

/**
 *  获取用户ID
 *
 *  @return
 */
- (NSString*)getUserID;

/**
 *  获取accesstoken
 *
 *  @return
 */
- (NSString*)getAccessToken;

/**
 *  获取用户信息，注意，登陆成功以后，用户信息同步是异步的
 *
 *  @return
 */
- (void)getUserProfile:(void(^)(NSDictionary* dict))func;

/**
 *  获取可邀请的好友
 *
 *  @param inviteTokens 排除的token
 *  @param func         回调block
 */
- (void)getInvitableFriends:(NSArray*)inviteTokens :(void(^)(NSDictionary* friends))func;

/**
 *  获取游戏中的好友
 *
 *  @param func 回调block
 */
- (void)getFriends:(void(^)(NSDictionary* friends))func;

/**
 *  发送Request
 *
 *  @param fidOrTokens fid活着InviteToken
 *  @param title       标题（可选）
 *  @param msg         消息内容
 *  @param func        回调block
 */
- (void)confirmRequest:(NSArray*)fidOrTokens withTitle:(NSString*)title withMsg:(NSString*)msg :(void(^)(NSDictionary* result))func;

/**
 *  查询收到的Request
 *
 *  @param func
 */
- (void)queryRequest:(void(^)(NSDictionary* requests))func;

/**
 *  删除request
 *
 *  @param requestId
 *  @param func
 */
- (void)acceptRequest:(NSString*)requestId :(void(^)(BOOL result))func;

/**
 *  分享
 *
 *  @param title       标题
 *  @param description 描述
 *  @param imageUrl    图片url
 *  @param contentUrl  内容url
 */
- (void)shareName:(NSString*)name description:(NSString*)description imageUrl:(NSString*)imageUrl contentUrl:(NSString*)contentUrl caption:(NSString*)caption :(void(^)(BOOL result))func;

/**
 *  设置玩家等级
 *
 *  @param level 等级
 */
- (void)setLevel:(int)level;

/**
 *  获取好友等级
 *
 *  @param fid
 *  @param func
 */
- (void)getLevel:(NSString*)fid :(void(^)(int level))func;

@end

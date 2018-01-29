//
//  IOSGamePlugin.h
//  Pods
//
//  Created by geekgy on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"

@interface IOSGamePlugin : NSObject <UIApplicationDelegate>

SINGLETON_DECLARE(IOSGamePlugin)

#pragma mark - Fabric

/**
 *  崩溃日志收集
 *
 *  @param log          日志
 */
- (void)crashReportLog:(NSString*)log;

/**
 *  崩溃错误收集
 *
 *  @param reason       错误原因
 *  @param traceback    错误堆栈信息
 */
- (void)crashReportExceptionWithReason:(NSString*)reason andTraceback:(NSArray*)traceback;

#pragma mark - Notification

/**
 推送通知回调

 @param handler         推送通知回调
 */
- (void)setNotificationHandler:(void(^)(NSDictionary*))handler;

#pragma mark - In-app-purchase

/**
 设置内购验证Url和签名

 @param url url
 @param sign sign
 */
- (void)setIapVerifyUrl:(NSString*)url sign:(NSString*)sign;

/**
 是否可以发起购买
 */
- (BOOL)canDoIap;

/**
 *  充值
 *
 *  @param iapId   计费点id
 *  @param userId  用户id
 *  @param handler 回调
 */
- (void)doIap:(NSString *)iapId userId:(NSString*)userId handler:(void(^)(BOOL result, NSString *msg))handler;

/**
 获取未处理的订单

 @return 订单信息
 */
- (NSDictionary*)getSuspensiveIap;

/**
 更新未处理的订单

 @param iapInfo 订单信息
 */
- (void)setSuspensiveIap:(NSDictionary*)iapInfo;

#pragma mark - Game Center

/**
 *  GameCenter是否可用
 *
 *  @return 是否可用
 */
- (BOOL)gcIsAvailable;

/**
 *  GameCenter获取用户信息
 *
 *  @return 用户信息
 */
- (NSDictionary*)gcGetPlayerInfo;

/**
 *  GameCenter获取用户好友
 *
 *  @param handler 用户好友
 */
- (void)gcGetPlayerFriends:(void(^)(NSArray*))handler;

/**
 *  GameCenter获取用户头像
 *
 *  @param playerId 玩家Id
 *  @param handler 回调
 */
- (void)gcGetPlayerAvatarWithId:(NSString*)playerId handler:(void(^)(NSString*))handler;

/**
 *  GameCenter获取用户信息
 *
 *  @param playerIds 玩家Id
 *  @param handler 回调
 */
- (void)gcGetPlayerInfoWithIds:(NSArray*)playerIds handler:(void(^)(NSArray*))handler;

/**
 *  GameCenter获取用户信息
 *
 *  @param playerId 玩家Id
 *  @param handler 回调
 */
- (void)gcGetPlayerInfoWithId:(NSString*)playerId handler:(void(^)(NSDictionary*))handler;

/**
 *  GameCenter获取挑战
 *
 *  @param handler 回调
 */
- (void)gcGetChallengesWithhandler:(void(^)(NSArray* challenges))handler;

/**
 *  GameCenter获取分数
 */
- (int)gcGetScore:(NSString*)leaderboard;

/**
 *  GameCenter报告分数
 */
- (void)gcReportScore:(int)score leaderboard:(NSString*)leaderboard sortH2L:(BOOL)h2l;

/**
 *  GameCenter获取成就
 */
- (double)gcGetAchievement:(NSString*)achievement;

/**
 *  GameCenter报告成就
 */
- (void)gcReportAchievement:(NSString*)achievement percentComplete:(double)percent;

/**
 *  GameCenter显示排行
 */
- (void)gcShowLeaderBoard;

/**
 *  GameCenter显示成就
 */
- (void)gcShowArchievement;

/**
 *  GameCenter显示挑战
 */
- (void)gcShowChallenge;

/**
 *  GameCenter重置
 */
- (void)gcReset;

@end

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
 *  设置生成验证支付URL回调函数
 *  已废弃
 *  @param handler      内购验证回调
 */
- (void)setVerifyIapHandler:(void(^)(NSDictionary*, void(^)(int, NSString*)))handler __attribute__((deprecated));

/**
 *  设置恢复购买回调函数
 *  已废弃
 *  @param handler      内购恢复回调
 */
- (void)setRestoreHandler:(void(^)(BOOL result, NSString *msg, NSString *iapId))handler __attribute__((deprecated));

/**
 *  充值
 *
 *  @param iapId   计费点id
 *  @param userId  用户id
 *  @param handler 回调
 */
- (void)doIap:(NSString *)iapId userId:(NSString*)userId handler:(void(^)(BOOL result, NSString *msg))handler;

#pragma mark - Game Center

/**
 *  GameCenter是否可用
 *
 *  @return
 */
- (BOOL)gcIsAvailable;

/**
 *  GameCenter获取用户信息
 *
 *  @return
 */
- (NSDictionary*)gcGetPlayerInfo;

/**
 *  GameCenter获取用户好友
 *
 *  @param handler
 */
- (void)gcGetPlayerFriends:(void(^)(NSArray*))handler;

/**
 *  GameCenter获取用户头像
 *
 *  @param playerId
 *  @param handler  
 */
- (void)gcGetPlayerAvatarWithId:(NSString*)playerId handler:(void(^)(NSString*))handler;

/**
 *  GameCenter获取用户信息
 *
 *  @param playerIds
 *  @param handler
 */
- (void)gcGetPlayerInfoWithIds:(NSArray*)playerIds handler:(void(^)(NSArray*))handler;

/**
 *  GameCenter获取用户信息
 *
 *  @param playerId
 *  @param handler
 */
- (void)gcGetPlayerInfoWithId:(NSString*)playerId handler:(void(^)(NSDictionary*))handler;

/**
 *  GameCenter获取挑战
 *
 *  @param handler
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

//
//  IOSGamePlugin.h
//  Pods
//
//  Created by geekgy on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import "LifeCycleDelegate.h"
#import "Macros.h"

@interface IOSGamePlugin : NSObject <LifeCycleDelegate>

SINGLETON_DECLARE(IOSGamePlugin)

/**
 *  崩溃日志收集
 *
 *  @param log
 */
- (void)crashReportLog:(NSString*)log;

/**
 *  崩溃错误收集
 *
 *  @param reason
 *  @param traceback
 */
- (void)crashReportExceptionWithReason:(NSString*)reason andTraceback:(NSArray*)traceback;


/**
 推送通知回调

 @param handler
 */
- (void)setNotificationHandler:(void(^)(NSDictionary*))handler;

/**
 *  设置生成验证支付URL回调函数
 *
 *  @param handler
 */
- (void)setVerifyIapHandler:(void(^)(NSDictionary*, void(^)(int, NSString*)))handler;

/**
 *  设置恢复购买回调函数
 *
 *  @param handler
 */
- (void)setRestoreHandler:(void(^)(BOOL result, NSString *msg, NSString *iapId))handler;

/**
 *  充值
 *
 *  @param iapId   计费点id
 *  @param userId  用户id
 *  @param handler 回调
 */
- (void)doIap:(NSString *)iapId userId:(NSString*)userId handler:(void(^)(BOOL result, NSString *msg))handler;

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

/**
 *  uuid
 */
- (NSString*)uuidForDevice;

/**
 *  save data into keychain
 */
- (void)keychainSet:(NSString*)value forKey:(NSString*)key;

/**
 *  obtain data from keychain
 */
- (NSString*)keychainValueforKey:(NSString*)key;


/**
 check device is jailbroken or not

 @return is jailbroken
 */
- (BOOL)isJailbroken;

@end

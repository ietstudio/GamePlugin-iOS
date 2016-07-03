//
//  IOSGamePlugin.h
//  Pods
//
//  Created by geekgy on 15-4-14.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "Macros.h"
#import "LifeCycleDelegate.h"
#import "RMStore.h"

@class MBProgressHUD;

@interface IOSGamePlugin : NSObject <LifeCycleDelegate, RMStoreReceiptVerificator, MFMailComposeViewControllerDelegate>

SINGLETON_DECLARE(IOSGamePlugin)

/**
 *  显示游戏loading
 *
 *  @param img 图片路径
 */
- (void)showGameLoading:(NSString*)img :(CGPoint)point :(CGFloat)scale;

/**
 *  隐藏游戏loading
 */
- (void)hideGameLoading;

/**
 *  设置生成验证支付URL回调函数
 *
 *  @param func 回调函数
 */
- (void)setGenVerifyUrlCallFunc:(NSString*(^)(NSDictionary*))func;

/**
 *  充值
 *
 *  @param iapIdsArr 所有计费点id
 *  @param userId    用户id
 *  @param iapId     计费点id
 *  @param callback  回调
 */
- (void)doIap:(NSArray*)iapIdsArr :(NSString *)iapId :(NSString*)userId :(void(^)(BOOL, NSString*))callback;

/**
 *  设置恢复购买回调函数
 *
 *  @param block
 */
- (void)setRestoreCallback:(void(^)(BOOL, NSString*))block;

/**
 *  评论游戏
 *
 *  @param force 强制
 */
- (void)rate:(BOOL)force;

/**
 *  保存图片到相册
 *
 *  @param imgPath 图片路径
 *  @param album   相册名称
 *  @param block   回调
 */
- (void)saveImage:(NSString*)imgPath toAlbum:(NSString*)album :(void(^)(BOOL, NSString*))block;

/**
 *  发送邮件
 *
 *  @param subject      主题
 *  @param toRecipients 收件人数组
 *  @param emailBody    内容，HTML
 *  @param callback     回调
 *
 *  @return 是否可以发送
 */
- (BOOL)sendEmail:(NSString*)subject :(NSArray*)toRecipients :(NSString*)emailBody :(void(^)(BOOL, NSString*))callback;

/**
 *  通知开关
 *
 *  @param enable
 */
- (void)setNotificationState:(BOOL)enable;

/**
 *  发送通知
 *
 *  @param userInfo
 */
- (void)postNotification:(NSDictionary *)userInfo;

/**
 *  显示图片弹框
 *
 *  @param img
 *  @param btnImg
 *  @param func
 */
- (void)showImageDialog:(NSString*)img :(NSString*)btnImg :(void(^)(BOOL))func;

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
 *  GameCenter重置
 */
- (void)gcReset;

/**
 *  获取用户输入文字
 *
 *  @param title        标题
 *  @param message      内容
 *  @param defaultValue 默认返回值
 *  @param block
 */
//- (void)getInputText:(NSString*)title :(NSString*)message :(NSString*)defaultValue :(void(^)(NSString*))block;

@end

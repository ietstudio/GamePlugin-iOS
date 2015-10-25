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
 *  获取App的版本好，是build号
 *
 *  @return
 */
- (NSString*)getAppVersion;

/**
 *  获取国家代码
 *
 *  @return
 */
- (NSString*)getCountryCode;

/**
 *  获取语言代码
 *
 *  @return
 */
- (NSString*)getLanguageCode;

/**
 *  获取设备名称
 *
 *  @return
 */
- (NSString*)getDeviceName;

/**
 *  获取系统版本
 *
 *  @return
 */
- (NSString*)getSystemVersion;

/**
 *  获取游戏时钟
 *
 *  @return
 */
- (time_t)getGameClock;

/**
 *  显示选择框
 *
 *  @param title    标题
 *  @param content  内容
 *  @param ok       确定文本
 *  @param cancel   取消文本
 *  @param callback 回调函数
 */
- (void)showChooseView:(NSString*)title :(NSString*)content :(NSString*)ok :(NSString*)cancel :(void(^)(BOOL))callback;

/**
 *  获取当前的网络状态
 *
 *  @return
 */
- (NSString*)getNetworkState;

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
 *  显示loading
 *
 *  @param msg
 */
- (void)showLoading:(NSString*)msg;

/**
 *  隐藏loading
 */
- (void)hideLoading;

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
 *  显示条形图
 *
 *  @param arr      数组
 *  @param multiply 倍数
 */
- (void)showChartViewWithArr:(NSArray*)arr multiply:(float)multiply;

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

@end







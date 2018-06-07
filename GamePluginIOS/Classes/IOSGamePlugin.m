//
//  IOSGamePlugin.m
//  Pods
//
//  Created by geekgy on 15-4-14.
//
//

#import "IOSGamePlugin.h"
#include <sys/sysctl.h>
#include <sys/utsname.h>

#import "IOSSystemUtil.h"
#import "IOSAdvertiseHelper.h"
#import "IOSAnalyticHelper.h"

#import <NSString+MD5.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <RMStore/RMStore.h>
#import <GameCenterManager/GameCenterManager.h>

#define GamePlugin_IapInfo @"GamePlugin_IapInfo"

#pragma mark - IOSGamePlugin

@interface IOSGamePlugin() <RMStoreReceiptVerificator, GameCenterManagerDelegate>

@end

@implementation IOSGamePlugin
{
    id _advertiseInstance;
    id _analyticInstance;
    id _facebookInstance;
    id _amazonAwsInstance;

    NSString* _iapVerifyUrl;
    NSString* _iapVerifySign;
    NSString* _iapResultEnv;
    void (^_iapResultHandler)(BOOL, NSString*);

    void (^_notifyHandler)(NSDictionary*);
}

SINGLETON_DEFINITION(IOSGamePlugin)

#pragma mark - private

- (instancetype)init {
    if (self = [super init]) {
        _advertiseInstance = [IOSAdvertiseHelper getInstance];
        _analyticInstance  = [IOSAnalyticHelper getInstance];
        _facebookInstance = [NSClassFromString(@"FacebookHelper") getInstance];
        _amazonAwsInstance = [NSClassFromString(@"AmazonAWSHelper") getInstance];
        return self;
    }
    return nil;
}

- (NSString*)localizationString:(NSString*)key {
    static NSBundle *bundle;
    if (bundle == nil) {
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"GamePluginIOS" ofType: @"bundle"];
        bundle = [NSBundle bundleWithPath: bundlePath];
    }
    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

- (void)openAppicationSettings {
    if (&UIApplicationOpenSettingsURLString != nil) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else {
        NSLog(@"UIApplicationOpenSettingsURLString is not available in current iOS version");
    }
}

#pragma mark - public

- (void)crashReportLog:(NSString *)log {
    CLS_LOG(@"%@", log);
}

- (void)crashReportExceptionWithReason:(NSString *)reason andTraceback:(NSArray *)traceback {
    NSMutableArray* frameArray = [NSMutableArray array];
    for (int i=0; i<[traceback count]; i++) {
        NSString* message = [traceback objectAtIndex:i];
        CLSStackFrame* frame = [CLSStackFrame stackFrameWithSymbol:message];
        [frame setLibrary:@"Lua_Library"];
        [frame setFileName:reason];
        [frameArray addObject:frame];
    }
    [[Crashlytics sharedInstance] recordCustomExceptionName:@"Lua_Error"
                                                     reason:reason
                                                 frameArray:frameArray];
}

- (void)setNotificationHandler:(void (^)(NSDictionary *))handler {
    _notifyHandler = handler;
}

- (void)setIapVerifyUrl:(NSString *)url sign:(NSString *)sign {
    _iapVerifyUrl = url;
    _iapVerifySign = sign;
}

- (BOOL)canDoIap {
    // 检测当前网络是否可用
    if ([[[IOSSystemUtil getInstance] getNetworkState] isEqualToString:@"NotReachable"]) {
        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                      message:[self localizationString:@"check_internet"]
                                               cancelBtnTitle:[self localizationString:@"okay"]
                                               otherBtnTitles:nil
                                                     callback:nil];
        return NO;
    }
    // 检测用户是否禁用了IAP
    if (![RMStore canMakePayments]) {
        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                      message:[self localizationString:@"check_lockiap"]
                                               cancelBtnTitle:[self localizationString:@"okay"]
                                               otherBtnTitles:nil
                                                     callback:nil];
        return NO;
    }
    // 检测当前是否有一笔正在进行的订单
    if ([[SKPaymentQueue defaultQueue].transactions count] > 0 || _iapResultHandler != nil || [self getSuspensiveIap] != nil) {
        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                      message:[self localizationString:@"iap_exist"]
                                               cancelBtnTitle:[self localizationString:@"okay"]
                                               otherBtnTitles:nil
                                                     callback:nil];
        return NO;
    }
    return YES;
}

- (void)doIap:(NSString *)iapId userId:(NSString *)userId handler:(void (^)(BOOL, NSString *))handler {
    if (![self canDoIap]) {
        handler(NO, @"can not make payment");
        return;
    }
    _iapResultHandler = handler;
    [[IOSSystemUtil getInstance] showLoadingWithMessage:@"Loading..."];
    [[RMStore defaultStore] requestProducts:[[NSSet alloc] initWithObjects:iapId, nil]
                                    success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                                        if ([products count] > 0) {
                                            [[RMStore defaultStore] addPayment:iapId
                                                                          user:userId
                                                                       success:^(SKPaymentTransaction *transaction) {
                                                                           _iapResultHandler(YES, _iapResultEnv);
                                                                           _iapResultHandler = nil;
                                                                           [[IOSSystemUtil getInstance] hideLoading];
                                                                       }
                                                                       failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                                                           _iapResultHandler(NO, [NSString stringWithFormat:@"%@", error]);
                                                                           _iapResultHandler = nil;
                                                                           [[IOSSystemUtil getInstance] hideLoading];
                                                                       }];
                                        } else {
                                            [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                                                          message:[self localizationString:@"iap_invalid_product"]
                                                                                   cancelBtnTitle:[self localizationString:@"okay"]
                                                                                   otherBtnTitles:nil
                                                                                         callback:^(int buttonIdx) {
                                                                                             _iapResultHandler(NO, @"invalid product id");
                                                                                             _iapResultHandler = nil;
                                                                                             [[IOSSystemUtil getInstance] hideLoading];
                                                                                         }];
                                        }
                                    } failure:^(NSError *error) {
                                        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                                                      message:[self localizationString:@"iap_request_failed"]
                                                                               cancelBtnTitle:[self localizationString:@"okay"]
                                                                               otherBtnTitles:nil
                                                                                     callback:^(int buttonIdx) {
                                                                                         _iapResultHandler(NO, @"request product failed");
                                                                                         _iapResultHandler = nil;
                                                                                         [[IOSSystemUtil getInstance] hideLoading];
                                                                                     }];
                                        
                                        
                                    }];
}

- (NSDictionary *)getSuspensiveIap {
    return (NSDictionary*)[[IOSSystemUtil getInstance] objectForKey:GamePlugin_IapInfo];
}

- (void)setSuspensiveIap:(NSDictionary *)iapInfo {
    [[IOSSystemUtil getInstance] setObject:iapInfo forKey:GamePlugin_IapInfo];
}

- (BOOL)gcIsAvailable {
    return [[GameCenterManager sharedManager] checkGameCenterAvailability];
}

- (NSDictionary *)gcGetPlayerInfo {
    return @{@"playerId" : [[GameCenterManager sharedManager] localPlayerData].playerID,
             @"displayName": [[GameCenterManager sharedManager] localPlayerData].displayName,
             @"alias": [[GameCenterManager sharedManager] localPlayerData].alias};
}

- (void)gcGetPlayerFriends:(void (^)(NSArray *))handler {
    [[[GameCenterManager sharedManager] localPlayerData] loadFriendsWithCompletionHandler:^(NSArray<NSString *> * _Nullable friendIDs, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"gcGetPlayerFriends failed: %@", error);
            handler(nil);
            return;
        }
        NSLog(@"%@", friendIDs);
        handler(friendIDs);
    }];
}

- (void)gcGetPlayerAvatarWithId:(NSString *)playerId handler:(void (^)(NSString *))handler {
    if (playerId == nil) {
        playerId = [[self gcGetPlayerInfo] objectForKey:@"playerId"];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"GameCenter"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", playerId]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        handler(filePath);
        return;
    }
    [GKPlayer loadPlayersForIdentifiers:@[playerId] withCompletionHandler:^(NSArray<GKPlayer *> * _Nullable players, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"gcGetPlayerAvatarWithId failed: %@", error);
            handler(nil);
            return;
        }
        GKPlayer *player = [players objectAtIndex:0];
        [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage * _Nullable photo, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"gcGetPlayerAvatarWithId failed: %@", error);
                handler(nil);
                return;
            }
            [UIImagePNGRepresentation(photo) writeToFile:filePath atomically:YES];
            handler(filePath);
        }];
    }];
}

- (void)gcGetPlayerInfoWithIds:(NSArray *)playerIds handler:(void (^)(NSArray *))handler {
    [GKPlayer loadPlayersForIdentifiers:playerIds withCompletionHandler:^(NSArray<GKPlayer *> * _Nullable players, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"gcGetPlayerInfoWithIds failed: %@", error);
            handler(nil);
            return;
        }
        NSMutableArray *playerInfos = [NSMutableArray array];
        for (GKPlayer* player in players) {
            [playerInfos addObject:@{@"playerID":player.playerID, @"displayName":player.displayName, @"alias":player.alias}];
        }
        handler([NSArray arrayWithArray:playerInfos]);
    }];
}

- (void)gcGetPlayerInfoWithId:(NSString *)playerId handler:(void (^)(NSDictionary *))handler {
    if (playerId == nil) {
        playerId = [[self gcGetPlayerInfo] objectForKey:@"playerId"];
    }
    [self gcGetPlayerInfoWithIds:@[playerId] handler:^(NSArray *playerInfos) {
        handler([playerInfos objectAtIndex:0]);
    }];
}

- (void)gcGetChallengesWithhandler:(void (^)(NSArray *))handler {
    [[GameCenterManager sharedManager] getChallengesWithCompletion:^(NSArray *challenges, NSError *error) {
        if (error != nil) {
            NSLog(@"gcGetChallenges failed: %@", error);
            handler(nil);
            return;
        }
        NSLog(@"%@", challenges);
        handler(challenges);
    }];
}

- (int)gcGetScore:(NSString *)leaderboard {
    return [[GameCenterManager sharedManager] highScoreForLeaderboard:leaderboard];
}

- (void)gcReportScore:(int)score leaderboard:(NSString *)leaderboard sortH2L:(BOOL)h2l {
    [[GameCenterManager sharedManager] saveAndReportScore:score
                                              leaderboard:leaderboard
                                                sortOrder:h2l?GameCenterSortOrderHighToLow:GameCenterSortOrderLowToHigh];
}

- (double)gcGetAchievement:(NSString *)achievement {
    return [[GameCenterManager sharedManager] highScoreForLeaderboard:achievement];
}

- (void)gcReportAchievement:(NSString*)achievement percentComplete:(double)percent {
    double currentPercent = [self gcGetAchievement:achievement];
    if (currentPercent >= 100) {
        return;
    }
    [[GameCenterManager sharedManager] saveAndReportAchievement:achievement
                                                percentComplete:percent
                                      shouldDisplayNotification:YES];
}

- (void)gcShowLeaderBoard {
    UIViewController* controller = [[IOSSystemUtil getInstance] controller];
    [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:controller];
}

- (void)gcShowArchievement {
    UIViewController* controller = [[IOSSystemUtil getInstance] controller];
    [[GameCenterManager sharedManager] presentAchievementsOnViewController:controller];
}

- (void)gcShowChallenge {
    UIViewController* controller = [[IOSSystemUtil getInstance] controller];
    [[GameCenterManager sharedManager] presentChallengesOnViewController:controller];
}

- (void)gcReset {
    [[GameCenterManager sharedManager] resetAchievementsWithCompletion:^(NSError *error) {
        NSLog(@"gcReset: %@", error);
    }];
}

- (void)rateGame {
    NSString* appleId = [[IOSSystemUtil getInstance] getConfigValueWithKey:Apple_ID];
    NSString* templateReviewURL;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        templateReviewURL = @"itms-apps://itunes.apple.com/app/idAPP_ID?action=write-review";
    } else {
        templateReviewURL = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID";
    }
    templateReviewURL = [templateReviewURL stringByReplacingOccurrencesOfString:@"APP_ID" withString:appleId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:templateReviewURL]];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 验证是否设置了 window 和 controller 并赋值
    UIWindow* window                       = [UIApplication sharedApplication].delegate.window;
    UIViewController* controller           = window.rootViewController;
    assert(window && controller);
    [IOSSystemUtil getInstance].window     = window;
    [IOSSystemUtil getInstance].controller = controller;
    
    // 初始化
    [_advertiseInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_analyticInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_facebookInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_amazonAwsInstance application:application didFinishLaunchingWithOptions:launchOptions];
    
    // rmstore 订单验证
    [RMStore defaultStore].receiptVerificator = self;
    
    // GameCenter初始化
    [[GameCenterManager sharedManager] setupManager];
    [[GameCenterManager sharedManager] setDelegate:self];
    
    // Crashlytics
#ifndef DEBUG
    [Fabric with:@[[Crashlytics class]]];
#endif
    
    // 本地通知
    UILocalNotification *localUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localUserInfo) {
        [self application:application didReceiveLocalNotification:localUserInfo];
    }
    
    // 远程通知
    NSDictionary* remoteUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteUserInfo) {
        [self application:application didReceiveRemoteNotification:remoteUserInfo];
    }
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [_advertiseInstance applicationDidBecomeActive:application];
    [_analyticInstance applicationDidBecomeActive:application];
    [_facebookInstance applicationDidBecomeActive:application];
    [_amazonAwsInstance applicationDidBecomeActive:application];
    
    // 清除图标角标
    [[IOSSystemUtil getInstance] setBadgeNum:0];
    
    // 取消已注册的本地通知
    [[IOSSystemUtil getInstance] calcelAllNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [_advertiseInstance applicationWillResignActive:application];
    [_analyticInstance applicationWillResignActive:application];
    [_facebookInstance applicationWillResignActive:application];
    [_amazonAwsInstance applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [_advertiseInstance applicationDidEnterBackground:application];
    [_analyticInstance applicationDidEnterBackground:application];
    [_facebookInstance applicationDidEnterBackground:application];
    [_amazonAwsInstance applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [_advertiseInstance applicationWillEnterForeground:application];
    [_analyticInstance applicationWillEnterForeground:application];
    [_facebookInstance applicationWillEnterForeground:application];
    [_amazonAwsInstance applicationWillEnterForeground:application];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [_advertiseInstance application:application
                            openURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
    [_analyticInstance application:application
                           openURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation];
    [_facebookInstance application:application
                           openURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation];
    [_amazonAwsInstance application:application
                            openURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [_advertiseInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_analyticInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_facebookInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_amazonAwsInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [_advertiseInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_analyticInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_facebookInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_amazonAwsInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if (_notifyHandler) {
        _notifyHandler(notification.userInfo);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (_notifyHandler) {
        _notifyHandler(userInfo);
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [_advertiseInstance application:application
         handleActionWithIdentifier:identifier
              forRemoteNotification:userInfo
                  completionHandler:completionHandler];
    [_analyticInstance application:application
         handleActionWithIdentifier:identifier
              forRemoteNotification:userInfo
                  completionHandler:completionHandler];
    [_facebookInstance application:application
         handleActionWithIdentifier:identifier
              forRemoteNotification:userInfo
                  completionHandler:completionHandler];
    [_amazonAwsInstance application:application
         handleActionWithIdentifier:identifier
              forRemoteNotification:userInfo
                  completionHandler:completionHandler];
}

#pragma mark - RMStoreReceiptVerificator

- (void)localVerifyTransactionUserId:(NSString*)userId
                           productId:(NSString*)productId
                             receipt:(NSString*)receipt
                             success:(void (^)())successBlock
                             failure:(void (^)(NSError *))failureBlock {
    // Create the JSON object that describes the request
    void(^ __block wblock)(NSString*, void(^)(NSError*));
    void(^block)(NSString*, void(^)(NSError*)) = ^(NSString* url, void(^callback)(NSError*)) {
        NSError *error;
        NSDictionary *requestContents = @{@"receipt-data": receipt};
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
        if (error != nil) {
            NSString* msg = [NSString stringWithFormat:@"JSONSerialization1: %@", error];
            callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
            return;
        }
        // Create a POST request with the receipt data.
        NSURL *storeURL = [NSURL URLWithString:url];
        NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
        [storeRequest setHTTPMethod:@"POST"];
        [storeRequest setHTTPBody:requestData];
        // Make a connection to the iTunes Store on a background queue.
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   dispatch_sync(dispatch_get_main_queue(), ^{
                                       if (connectionError) {
                                           NSLog(@"connectError: %@", connectionError);
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                               wblock(url, callback);
                                           });
                                           return;
                                       }
                                       NSError *error;
                                       NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                       if (error != nil) {
                                           NSString* msg = [NSString stringWithFormat:@"JSONSerialization2: %@", error];
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       if (!jsonResponse) {
                                           NSString* msg = @"jsonResponse is nil";
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       NSLog(@"%@", jsonResponse);
                                       // 验证status
                                       int status = [[jsonResponse objectForKey:@"status"] intValue];
                                       if (status != 0) {
                                           NSString* msg = [NSString stringWithFormat:@"status!=0"];
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       NSDictionary* receipt = [jsonResponse objectForKey:@"receipt"];
                                       // 验证程序包名
                                       NSString* bundle_id = [receipt objectForKey:@"bundle_id"];
                                       if (![bundle_id isEqualToString:[[IOSSystemUtil getInstance] getAppBundleId]]) {
                                           NSString* msg = [NSString stringWithFormat:@"bundle_id is wrong"];
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       // get in-app
                                       NSArray *inApp = [receipt objectForKey:@"in_app"];
                                       if ([inApp count] <= 0) {
                                           NSString* msg = [NSString stringWithFormat:@"in_app is empty"];
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       callback(nil);
                                   });
                               }];
    };
    wblock = block;
    // 先验证buy在验证sanbox
    block(@"https://buy.itunes.apple.com/verifyReceipt", ^(NSError* buyError){
        if (buyError != nil) {
            block(@"https://sandbox.itunes.apple.com/verifyReceipt", ^(NSError* sanboxError){
                if (sanboxError != nil) {
                    NSError* error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@,%@", buyError, sanboxError]
                                                         code:0
                                                     userInfo:nil];
                    failureBlock(error);
                } else {
                    _iapResultEnv = @"ProductionSandbox";
                    successBlock();
                }
            });
        } else {
            _iapResultEnv = @"Production";
            successBlock();
        }
    });
}

- (void)serverVerifyTransactionUserId:(NSString*)userId
                            productId:(NSString*)productId
                              receipt:(NSString*)receipt
                              success:(void (^)())successBlock
                              failure:(void (^)(NSError *))failureBlock {
    // 开始验证
    [[IOSAnalyticHelper getInstance] onEvent:@"VerifyStart" eventData:@{@"name":productId}];
    NSMutableDictionary* postData = [NSMutableDictionary dictionary];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@", _iapVerifySign, receipt, userId] MD5Digest];
    [postData setObject:receipt forKey:@"receipt"];
    [postData setObject:userId forKey:@"token"];
    [postData setObject:sign forKey:@"sign"];
    [[IOSSystemUtil getInstance] sendRequest:@"post"
                                         url:_iapVerifyUrl
                                        data:postData
                                     handler:^(BOOL result, NSDictionary *resp) {
                                         if (!result) {
                                             [[IOSAnalyticHelper getInstance] onEvent:@"VerifyFailed" eventData:@{@"name":productId, @"reason":@"connect error"}];
                                             // 接口请求失败，过5秒重试
                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                 [self serverVerifyTransactionUserId:userId
                                                                           productId:productId
                                                                             receipt:receipt
                                                                             success:successBlock
                                                                             failure:failureBlock];
                                             });
                                             return;
                                         }
                                         if ([resp objectForKey:@"errCode"] != nil) {
                                             int errCode = [[resp objectForKey:@"errCode"] intValue];
                                             NSString* reason = [NSString stringWithFormat:@"verify error: %d", errCode];
                                             [[IOSAnalyticHelper getInstance] onEvent:@"VerifyFailed" eventData:@{@"name":productId, @"reason":reason}];
                                             // 未知错误，过5秒重试
                                             if (errCode == 1) {
                                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                                     [self serverVerifyTransactionUserId:userId
                                                                               productId:productId
                                                                                 receipt:receipt
                                                                                 success:successBlock
                                                                                 failure:failureBlock];
                                                 });
                                             } else {
                                                 failureBlock([NSError errorWithDomain:@"IapVerifyDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:reason}]);
                                             }
                                         } else {
                                             NSString* environment = [resp objectForKey:@"environment"];
                                             NSString* sign = [resp objectForKey:@"sign"];
                                             NSString* mySign = [[NSString stringWithFormat:@"%@%@%@", _iapVerifySign, receipt, environment] MD5Digest];
                                             if (![mySign isEqualToString:sign]) {
                                                 NSString* reason = [NSString stringWithFormat:@"sign error"];
                                                 [[IOSAnalyticHelper getInstance] onEvent:@"VerifyFailed" eventData:@{@"name":productId, @"reason":reason}];
                                                 failureBlock([NSError errorWithDomain:@"IapVerifyDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:reason}]);
                                             } else {
                                                 [[IOSAnalyticHelper getInstance] onEvent:@"VerifySuccess" eventData:@{@"name":productId}];
                                                 _iapResultEnv = environment;
                                                 successBlock();
                                             }
                                         }
                                     }];
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *))failureBlock {
    void(^block)(NSString*, NSString*, NSString*) = ^(NSString* productId, NSString* userId, NSString* receipt){
        userId = userId==nil?@"unknow":userId;
        void(^_successBlock)() = ^() {
            if (_iapResultHandler == nil) {
                // 存储未处理订单
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                [dict setObject:_iapResultEnv forKey:@"environment"];
                [dict setObject:productId forKey:@"productId"];
                [self setSuspensiveIap:dict];
            }
            // 统计内购收入
            if ([_iapResultEnv isEqualToString:@"Production"]) {
                [[IOSAnalyticHelper getInstance] charge:transaction];
            }
            successBlock();
        };
        void(^_failureBlock)(NSError*) = ^(NSError* error) {
            failureBlock(error);
        };
        // 如果没有设置内购验证的url和sign，本地调用苹果接口验证
        if (_iapVerifyUrl == nil || _iapVerifySign == nil) {
            [self localVerifyTransactionUserId:userId
                                     productId:productId
                                       receipt:receipt
                                       success:_successBlock
                                       failure:_failureBlock];
        } else {
            [self serverVerifyTransactionUserId:userId
                                      productId:productId
                                        receipt:receipt
                                        success:_successBlock
                                        failure:_failureBlock];
        }
    };
    // 获取产品id
    NSString* productId = transaction.payment.productIdentifier;
    // 获取用户id
    NSString* userId = transaction.payment.applicationUsername;
    // 获取订单回执
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
    // 如果订单回执不为空
    if (receipt != nil) {
        block(productId, userId, receipt);
        return;
    }
    // 刷新回执
    void(^ __block wrefreshReceiptBlock)();
    void(^refreshReceiptBlock)() = ^(){
        [[RMStore defaultStore] refreshReceiptOnSuccess:^{
            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
            if (receipt != nil) {
                NSLog(@"refresh receipt success, but receipt is still nil");
                block(productId, userId, receipt);
                return;
            }
            NSLog(@"refresh receipt failed receipt is nil");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                wrefreshReceiptBlock();
            });
        } failure:^(NSError *error) {
            NSLog(@"refresh receipt failed %@", error);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                wrefreshReceiptBlock();
            });
        }];
    };
    wrefreshReceiptBlock = refreshReceiptBlock;
    refreshReceiptBlock();
}

#pragma mark - GameCenterManagerDelegate

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    UIViewController* controller = [[IOSSystemUtil getInstance] controller];
    [controller presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
    }];
}

- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availabilty: %@", availabilityInformation);
    if ([[availabilityInformation objectForKey:@"status"] isEqualToString:@"GameCenter Available"]) {
        NSLog(@"GameCenter Available, Game Center is online, the current player is logged in, and this app is setup.");
    } else {
        NSLog(@"GameCenter Unavailable, %@", [availabilityInformation objectForKey:@"error"]);
    }
    
    GKLocalPlayer *player = [[GameCenterManager sharedManager] localPlayerData];
    if (player) {
        if ([player isUnderage] == NO) {
            NSLog(@"%@ signed in.", player.displayName);
            NSLog(@"Player is not underage and is signed-in");
            [[GameCenterManager sharedManager] localPlayerPhoto:^(UIImage *playerPhoto) {
                NSLog(@"playerPhoto = %@", playerPhoto);
            }];
        } else {
            NSLog(@"%@", player.displayName);
            NSLog(@"Player is underage");
            NSLog(@"Underage player, %@, signed in.", player.displayName);
        }
    } else {
        NSLog(@"No GameCenter player found.");
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GCM Error: %@", error);
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedAchievement:(GKAchievement *)achievement withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Achievement: %@", achievement);
    } else {
        NSLog(@"GCM Error while reporting achievement: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager reportedScore:(GKScore *)score withError:(NSError *)error {
    if (!error) {
        NSLog(@"GCM Reported Score: %@", score);
    } else {
        NSLog(@"GCM Error while reporting score: %@", error);
    }
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveScore:(GKScore *)score {
    NSLog(@"Saved GCM Score with value: %lld", score.value);
}

- (void)gameCenterManager:(GameCenterManager *)manager didSaveAchievement:(GKAchievement *)achievement {
    NSLog(@"Saved GCM Achievement: %@", achievement);
}

@end

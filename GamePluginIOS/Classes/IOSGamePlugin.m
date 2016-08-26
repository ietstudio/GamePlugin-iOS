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
#import "IOSAmazonAWSHelper.h"
#import "IOSFacebookHelper.h"

#import "iRate.h"
#import "AFNetworking.h"
#import "NSString+MD5.h"
#import "GameCenterManager.h"
#import "RMStore.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#pragma mark - IOSGamePlugin

@interface IOSGamePlugin() <RMStoreReceiptVerificator, GameCenterManagerDelegate>

@end

@implementation IOSGamePlugin
{
    id _advertiseInstance;
    id _analyticInstance;
    id _facebookInstance;
    id _amazonAwsInstance;
    NSString *(^_genVerifyUrlHandler)(NSDictionary *);
    void(^_restoreHandler)(BOOL, NSString*, NSArray *);
    void(^_iapHandler)(BOOL, NSString*, NSArray *);
    NSString* _iapSuccessState;
    NSArray* _iapSuccessIds;
}

SINGLETON_DEFINITION(IOSGamePlugin)

#pragma mark private

- (instancetype)init {
    if (self = [super init]) {
        _advertiseInstance = [IOSAdvertiseHelper getInstance];
        _analyticInstance  = [IOSAnalyticHelper getInstance];
        _facebookInstance  = [IOSFacebookHelper getInstance];
        _amazonAwsInstance = [IOSAmazonAWSHelper getInstance];
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

- (void)openSystemSettings:(NSString*)rootName {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@", rootName]];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openAppicationSettings {
    if (&UIApplicationOpenSettingsURLString != nil) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    } else {
        NSLog(@"UIApplicationOpenSettingsURLString is not available in current iOS version");
    }
}

#pragma mark public

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

- (void)setGenVerifyUrlHandler:(NSString *(^)(NSDictionary *))handler {
    _genVerifyUrlHandler = handler;
}

- (void)setRestoreHandler:(void (^)(BOOL, NSString *, NSArray *))handler {
    _restoreHandler = handler;
}

- (void)doIap:(NSString *)iapId userId:(NSString *)userId handler:(void (^)(BOOL, NSString *, NSArray *))handler {
    // check internet is avaliable
    if ([[[IOSSystemUtil getInstance] getNetworkState] isEqualToString:@"NotReachable"]) {
        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                      message:[self localizationString:@"check_internet"]
                                               cancelBtnTitle:[self localizationString:@"later"]
                                               otherBtnTitles:@[[self localizationString:@"okay"]]
                                                     callback:^(int buttonIdx) {
                                                         if (buttonIdx == 1) {
                                                             [self openSystemSettings:@""];
                                                         }
                                                         handler(NO, @"Can not access internet", nil);
                                                     }];
        return;
    }
    // check user disable in-app purchase
    if (![RMStore canMakePayments]) {
        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                      message:[self localizationString:@"check_lockiap"]
                                               cancelBtnTitle:[self localizationString:@"later"]
                                               otherBtnTitles:@[[self localizationString:@"okay"]]
                                                     callback:^(int buttonIdx) {
                                                         if (buttonIdx == 1) {
                                                             [self openSystemSettings:@"General"];
                                                         }
                                                         handler(NO, @"Can not make payments", nil);
                                                     }];
        return;
    }
    // check in-app purchase is in progress
    if (_iapHandler != nil) {
        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                      message:[self localizationString:@"iap_exist"]
                                               cancelBtnTitle:[self localizationString:@"okay"]
                                               otherBtnTitles:nil
                                                     callback:^(int buttonIdx) {
                                                         handler(NO, @"Already has a payment", nil);
                                                     }];
        return;
    }
    [[IOSSystemUtil getInstance] showLoadingWithMessage:@"Loading..."];
    _iapHandler = handler;
    NSSet* iapIdsSet = [[NSSet alloc] initWithObjects:iapId, nil];
    [[RMStore defaultStore] requestProducts:iapIdsSet
                                    success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
                                        if ([products count] > 0) {
                                            [[RMStore defaultStore] addPayment:iapId
                                                                          user:userId
                                                                       success:^(SKPaymentTransaction *transaction) {
                                                                           _iapHandler(YES, _iapSuccessState, _iapSuccessIds);
                                                                           _iapHandler = nil;
                                                                           [[IOSSystemUtil getInstance] hideLoading];
                                                                       }
                                                                       failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                                                           NSString *message = [NSString stringWithFormat:[self localizationString:@"iap_failed"], error];
                                                                           [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                                                                                         message:message
                                                                                                                  cancelBtnTitle:[self localizationString:@"okay"]
                                                                                                                  otherBtnTitles:nil
                                                                                                                        callback:^(int buttonIdx) {
                                                                                                                            _iapHandler(NO, message, nil);
                                                                                                                            _iapHandler = nil;
                                                                                                                            [[IOSSystemUtil getInstance] hideLoading];
                                                                                                                        }];
                                                                       }];
                                        } else {
                                            NSString *message = [NSString stringWithFormat:[self localizationString:@"iap_invalid_product"], iapId];
                                            [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                                                          message:message
                                                                                   cancelBtnTitle:[self localizationString:@"okay"]
                                                                                   otherBtnTitles:nil
                                                                                         callback:^(int buttonIdx) {
                                                                                             _iapHandler(NO, message, nil);
                                                                                             _iapHandler = nil;
                                                                                             [[IOSSystemUtil getInstance] hideLoading];
                                                                                         }];
                                        }
                                    } failure:^(NSError *error) {
                                        NSString* message = [NSString stringWithFormat:[self localizationString:@"iap_request_failed"], error];
                                        [[IOSSystemUtil getInstance] showAlertDialogWithTitle:[self localizationString:@"failure"]
                                                                                      message:message
                                                                               cancelBtnTitle:[self localizationString:@"okay"]
                                                                               otherBtnTitles:nil
                                                                                     callback:^(int buttonIdx) {
                                                                                         _iapHandler(NO, message, nil);
                                                                                         _iapHandler = nil;
                                                                                         [[IOSSystemUtil getInstance] hideLoading];
                                                                                     }];
                                        
                                        
                                    }];
}

- (void)rate:(int)level {
    if (level == 2) {
        [[iRate sharedInstance] openRatingsPageInAppStore];
    } else if (level == 1) {
        [[iRate sharedInstance] promptForRating];
    } else {
        [[iRate sharedInstance] logEvent:NO];
    }
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

#pragma mark - LifeCycleDelegate

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
    
    // iRate 评价条件
    // 无论使用的程序的那个版本都可以评论
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    // 首次使用开始计算N天以上
    [iRate sharedInstance].daysUntilPrompt   = [[[IOSSystemUtil getInstance] getConfigValueWithKey:@"iRate_daysUntilPrompt"] floatValue];
    // app打开了N次以上
    [iRate sharedInstance].usesUntilPrompt   = [[[IOSSystemUtil getInstance] getConfigValueWithKey:@"iRate_usesUntilPrompt"] intValue];
    // 事件N次以上
    [iRate sharedInstance].eventsUntilPrompt = [[[IOSSystemUtil getInstance] getConfigValueWithKey:@"iRate_eventsUntilPrompt"] intValue];
    // 不显示不再提醒按钮
    [iRate sharedInstance].cancelButtonLabel = [[IOSSystemUtil getInstance] getConfigValueWithKey:@"iRate_cancelButtonLabel"];
    // 用户点击了稍后提醒以后，等待1天
    [iRate sharedInstance].remindPeriod      = [[[IOSSystemUtil getInstance] getConfigValueWithKey:@"iRate_remindPeriod"] floatValue];
    
    // Crashlytics
#if NDEBUG
    [Fabric with:@[[Crashlytics class]]];
#endif
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [_advertiseInstance applicationDidBecomeActive:application];
    [_analyticInstance applicationDidBecomeActive:application];
    [_facebookInstance applicationDidBecomeActive:application];
    [_amazonAwsInstance applicationDidBecomeActive:application];
    
    // 取消已注册的本地通知
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification * notification in notifications) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_advertiseInstance application:application didReceiveRemoteNotification:userInfo];
    [_analyticInstance application:application didReceiveRemoteNotification:userInfo];
    [_facebookInstance application:application didReceiveRemoteNotification:userInfo];
    [_amazonAwsInstance application:application didReceiveRemoteNotification:userInfo];
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

- (void)verifyLocalTransaction:(SKPaymentTransaction *)transaction
                      userInfo:(NSDictionary*)userInfo
                       success:(void (^)())successBlock
                       failure:(void (^)(NSError *))failureBlock {
    // Create the JSON object that describes the request
    NSString* userId    = [userInfo objectForKey:@"userId"];
    NSString* productId = [userInfo objectForKey:@"productId"];
    NSString* receipt   = [userInfo objectForKey:@"receipt"];
    void(^block)(NSString*, void(^)(NSArray*, NSError*));
    void(^ __block __weak wblock)(NSString*, void(^)(NSArray*, NSError*)) = block;
    block = ^(NSString* url, void(^callback)(NSArray*, NSError*)) {
        NSError *error;
        NSDictionary *requestContents = @{@"receipt-data": receipt};
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
        if (error != nil) {
            NSString* msg = [NSString stringWithFormat:@"JSONSerialization1: %@", error];
            callback(nil, [NSError errorWithDomain:msg code:0 userInfo:nil]);
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
                                           wblock(url, callback);
                                           return;
                                       }
                                       NSError *error;
                                       NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                       if (error != nil) {
                                           NSString* msg = [NSString stringWithFormat:@"JSONSerialization2: %@", error];
                                           callback(nil, [NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       if (!jsonResponse) {
                                           NSString* msg = @"jsonResponse is nil";
                                           callback(nil, [NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       NSLog(@"%@", jsonResponse);
                                       // 验证status
                                       int status = [[jsonResponse objectForKey:@"status"] intValue];
                                       if (status != 0) {
                                           NSString* msg = [NSString stringWithFormat:@"status!=0"];
                                           callback(nil, [NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       NSDictionary* receipt = [jsonResponse objectForKey:@"receipt"];
                                       // 验证程序包名
                                       NSString* bundle_id = [receipt objectForKey:@"bundle_id"];
                                       if (![bundle_id isEqualToString:[[IOSSystemUtil getInstance] getBundleId]]) {
                                           NSString* msg = [NSString stringWithFormat:@"bundle_id is wrong"];
                                           callback(nil, [NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       // get in-app
                                       NSMutableArray *iapIds = [NSMutableArray array];
                                       NSArray *inApp = [receipt objectForKey:@"in_app"];
                                       for (NSDictionary *item in inApp) {
                                           [iapIds addObject:[item objectForKey:@"product_id"]];
                                       }
                                       callback([NSArray arrayWithArray:iapIds], nil);
                                       // send analytic event
                                       NSString* label = [NSString stringWithFormat:@"%@,%@", userId, productId];
                                       [[IOSAnalyticHelper getInstance] onEvent:@"Purchase" Label:label];
                                   });
                               }];
    };
    // 先验证buy在验证sanbox
    block(@"https://buy.itunes.apple.com/verifyReceipt", ^(NSArray* iapIds, NSError* buyError){
        if (buyError != nil) {
            block(@"https://sandbox.itunes.apple.com/verifyReceipt", ^(NSArray* iapIds, NSError* sanboxError){
                if (sanboxError != nil) {
                    NSError* error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@,%@", buyError, sanboxError]
                                                         code:0
                                                     userInfo:nil];
                    failureBlock(error);
                } else {
                    _iapSuccessState = @"ProductionSandbox";
                    _iapSuccessIds = iapIds;
                    successBlock();
                }
            });
        } else {
            _iapSuccessState = @"Production";
            _iapSuccessIds = iapIds;
            successBlock();
        }
    });
}

- (void)verifyRemoteTransaction:(SKPaymentTransaction *)transaction
                       userInfo:(NSDictionary*)userInfo
                        success:(void (^)())successBlock
                        failure:(void (^)(NSError *))failureBlock {
    NSString* url = _genVerifyUrlHandler(userInfo);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json", nil];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int state = [[responseObject objectForKey:@"state"] intValue];
        NSString* msg = [responseObject objectForKey:@"msg"];
        if (state == 1) {
            _iapSuccessState = msg;
            successBlock();
        } else {
            NSError* error = [NSError errorWithDomain:msg code:0 userInfo:nil];
            failureBlock(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get url failed : %@", error);
    }];
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction
                  success:(void (^)())successBlock
                  failure:(void (^)(NSError *))failureBlock {
    void(^block)(NSString*, NSString*, NSString*) = ^(NSString* productId, NSString* userId, NSString* receipt){
        userId = userId==nil?@"unknow":userId;
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:userId forKey:@"userId"];
        [userInfo setObject:productId forKey:@"productId"];
        [userInfo setObject:receipt forKey:@"receipt"];
        void(^_successBlock)() = ^() {
            if (_iapHandler != nil) {
                successBlock();
                return;
            }
            if (_restoreHandler != nil) {
                _restoreHandler(YES, _iapSuccessState, _iapSuccessIds);
                successBlock();
            }
        };
        void(^_failureBlock)(NSError*) = ^(NSError* error) {
            if (_iapHandler != nil) {
                failureBlock(error);
                return;
            }
            if (_restoreHandler != nil) {
                _restoreHandler(NO, [NSString stringWithFormat:@"Payment Failed! %@", error], nil);
                failureBlock(error);
            }
        };
        // 如果没有设置生成验证url的回调函数，本地调用苹果接口验证
        if (_genVerifyUrlHandler == nil) {
            [self verifyLocalTransaction:transaction
                                userInfo:userInfo
                                 success:_successBlock
                                 failure:_failureBlock];
        } else {
            [self verifyRemoteTransaction:transaction
                                 userInfo:userInfo
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
    void(^refreshReceiptBlock)();
    void(^ __block __weak wrefreshReceiptBlock)() = refreshReceiptBlock;
    refreshReceiptBlock = ^(){
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
            wrefreshReceiptBlock();
        } failure:^(NSError *error) {
            NSLog(@"refresh receipt failed %@", error);
            wrefreshReceiptBlock();
        }];
    };
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

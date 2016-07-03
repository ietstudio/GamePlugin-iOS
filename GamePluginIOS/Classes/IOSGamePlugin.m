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

#import "iRate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "AFNetworking.h"
#import "NSString+MD5.h"
#import "GameCenterManager.h"

#pragma mark - GameCenterManagerImp

@interface GameCenterManagerImp : NSObject <GameCenterManagerDelegate>
@end

@implementation GameCenterManagerImp

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

#pragma mark - IOSGamePlugin

@implementation IOSGamePlugin
{
    void (^_emailCallFunc)(BOOL, NSString*);
    NSString *(^_genVerifyUrlCallFunc)(NSDictionary *);
    UIView* _loadingView;
    UIView* _imageView;
    id _advertiseInstance;
    id _analyticInstance;
    id _amazonAwsInstance;
    id _facebookInstance;
    NSString* _iapSuccessMsg;
    void(^_restoreBlock)(BOOL, NSString*);
    void(^_iapBlock)(BOOL, NSString*);
}

SINGLETON_DEFINITION(IOSGamePlugin)

#pragma mark public method

- (void)showGameLoading:(NSString *)img :(CGPoint)point :(CGFloat)scale {
    if (_loadingView != nil) {
        return;
    }
    UIViewController* controller = [[IOSSystemUtil getInstance] controller];

    float swidth = [UIScreen mainScreen].applicationFrame.size.width;
    float sheight = [UIScreen mainScreen].applicationFrame.size.height;
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(swidth*point.x, sheight*(1-point.y), 0, 0)];
    [controller.view addSubview:view];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:img]];
    CGSize viewSize = imageView.frame.size;
    viewSize = CGSizeApplyAffineTransform(viewSize, CGAffineTransformMakeScale(scale, scale));
    // 缩放
    imageView.frame = CGRectMake(-viewSize.width/2, -viewSize.height/2, viewSize.width, viewSize.height);
    // 动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI-0.001, 0.0, 0.0, 1.0)];
    animation.duration = 0.5;
    animation.cumulative = YES;
    animation.repeatCount = INT_MAX;
    CGRect imageRrect = CGRectMake(0, 0,viewSize.width, viewSize.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [imageView.image drawInRect:CGRectMake(0,0,viewSize.width,viewSize.height)];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [imageView.layer addAnimation:animation forKey:nil];
    [view addSubview:imageView];
    _loadingView = view;
}

- (void)hideGameLoading {
    if (_loadingView == nil) {
        return;
    }
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

- (void)setGenVerifyUrlCallFunc:(NSString *(^)(NSDictionary *))func {
    _genVerifyUrlCallFunc = func;
}

- (void)doIap:(NSArray *)iapIdsArr :(NSString *)iapId :(NSString *)userId :(void (^)(BOOL, NSString *))callback {
    if ([[[IOSSystemUtil getInstance] getNetworkState] isEqualToString:@"NotReachable"]) {
        callback(NO, @"Can not access internet");
        return;
    }
    if (![RMStore canMakePayments]) {
        callback(NO, @"Can not make payments");
        return;
    }
    if (_iapBlock != nil) {
        callback(NO, @"Already has a payment");
        return;
    }
    NSSet* iapIdsSet = [[NSSet alloc] initWithArray:iapIdsArr];
    [[RMStore defaultStore] requestProducts:iapIdsSet success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if ([products count] > 0) {
            _iapBlock = callback;
            [[RMStore defaultStore] addPayment:iapId
                                          user:userId
                                       success:^(SKPaymentTransaction *transaction) {
                                           _iapBlock(YES, _iapSuccessMsg);
                                           _iapBlock = nil;
                                       }
                                       failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                           NSString* msg = [NSString stringWithFormat:@"Payment Failed! %@", error];
                                           _iapBlock(NO, msg);
                                           _iapBlock = nil;
                                       }];
        } else {
            NSString* msg = [NSString stringWithFormat:@"Invalid ProductId %@", iapId];
            callback(NO, msg);
        }
    } failure:^(NSError *error) {
        NSString* msg = [NSString stringWithFormat:@"Request Products Failed! %@", error];
        callback(NO, msg);
    }];
}

- (void)setRestoreCallback:(void (^)(BOOL, NSString *))block {
    _restoreBlock = block;
}

- (void)rate:(BOOL)force {
    if (force) {
        [[iRate sharedInstance] openRatingsPageInAppStore];
    } else {
        [[iRate sharedInstance] logEvent:NO];
    }
}

- (void)saveImage:(NSString *)imgPath toAlbum:(NSString *)album :(void (^)(BOOL, NSString*))block {
    UIImage* imageToSave = [UIImage imageWithContentsOfFile:imgPath];
    [[[ALAssetsLibrary alloc] init] saveImage:imageToSave
                                      toAlbum:album
                                   completion:^(NSURL *assetURL, NSError *error) {
                                       block(YES, [assetURL absoluteString]);
                                   } failure:^(NSError *error) {
                                       NSLog(@"%@", error);
                                       block(NO, [error localizedDescription]);
                                   }];
}

- (BOOL)sendEmail:(NSString *)subject :(NSArray *)toRecipients :(NSString *)emailBody :(void (^)(BOOL, NSString *))callback {
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    };
    if (_emailCallFunc == nil) {
        _emailCallFunc = callback;
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject: subject];//设置主题
        [controller setToRecipients: toRecipients];//添加收件人
        [controller setMessageBody:emailBody isHTML:YES];//添加正文
        [[[IOSSystemUtil getInstance] controller] presentViewController:controller animated:YES completion:^{
            NSLog(@"email controller present");
        }];
    }
    return YES;
}

- (void)setNotificationState:(BOOL)enable {
    if (enable) {
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
            // Configures the appearance
            [UINavigationBar appearance].barTintColor = [UIColor blackColor];
            [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            
            // Sets up Mobile Push Notification
            UIMutableUserNotificationAction *readAction = [UIMutableUserNotificationAction new];
            readAction.identifier = @"READ_IDENTIFIER";
            readAction.title = @"Read";
            readAction.activationMode = UIUserNotificationActivationModeForeground;
            readAction.destructive = NO;
            readAction.authenticationRequired = YES;
            
            UIMutableUserNotificationAction *deleteAction = [UIMutableUserNotificationAction new];
            deleteAction.identifier = @"DELETE_IDENTIFIER";
            deleteAction.title = @"Delete";
            deleteAction.activationMode = UIUserNotificationActivationModeForeground;
            deleteAction.destructive = YES;
            deleteAction.authenticationRequired = YES;
            
            UIMutableUserNotificationAction *ignoreAction = [UIMutableUserNotificationAction new];
            ignoreAction.identifier = @"IGNORE_IDENTIFIER";
            ignoreAction.title = @"Ignore";
            ignoreAction.activationMode = UIUserNotificationActivationModeForeground;
            ignoreAction.destructive = NO;
            ignoreAction.authenticationRequired = NO;
            
            UIMutableUserNotificationCategory *messageCategory = [UIMutableUserNotificationCategory new];
            messageCategory.identifier = @"MESSAGE_CATEGORY";
            [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
            [messageCategory setActions:@[readAction, deleteAction, ignoreAction] forContext:UIUserNotificationActionContextDefault];
            
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithArray:@[messageCategory]]];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        }
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (void)postNotification:(NSDictionary *)userInfo {
    NSString* message = [userInfo objectForKey:@"message"];
    NSTimeInterval delay = [[userInfo objectForKey:@"delay"] doubleValue];
    NSString* sound = [userInfo objectForKey:@"sound"];
    NSNumber* badgeNumber = [userInfo objectForKey:@"badge"];
    sound = sound==nil?UILocalNotificationDefaultSoundName:sound;
    int badge = badgeNumber==nil?1:[badgeNumber intValue];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    [localNotification setAlertBody:message];
    [localNotification setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
    [localNotification setSoundName:sound];
    [localNotification setApplicationIconBadgeNumber:badge];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)showImageDialog:(NSString *)img :(NSString *)btnImg :(void (^)(BOOL))func {
//    ImgDialogViewController *imgDialogViewController = [[ImgDialogViewController alloc] init];
//    [imgDialogViewController setImgPath:img];
//    [imgDialogViewController setBtnPath:btnImg];
//    [imgDialogViewController setCallFunc:^(BOOL result) {
//        UIViewController* controller = [[IOSSystemUtil getInstance] getCurrentViewController];
//        [controller dismissPopupViewControllerAnimated:NO completion:^{
//            func(result);
//        }];
//    }];
//    UIViewController* controller = [[IOSSystemUtil getInstance] getCurrentViewController];
//    [controller presentPopupViewController:imgDialogViewController animated:NO completion:nil];
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

- (void)gcReset {
    [[GameCenterManager sharedManager] resetAchievementsWithCompletion:^(NSError *error) {
        NSLog(@"gcReset: %@", error);
    }];
}

//- (void)getInputText:(NSString *)title :(NSString *)message :(NSString *)defaultValue :(void (^)(NSString *))block {
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                              cancelButtonTitle:@"Cancel"
//                                               otherButtonTitle:@"Ok"];
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        if (block) {
//            if (buttonIndex == 1) {
//                UITextField* textField = [alertView textFieldAtIndex:0];
//                NSString* inputText = textField.text;
//                if (inputText == nil || inputText.length <= 0) {
//                    inputText = defaultValue;
//                }
//                block(inputText);
//            }
//        }
//    }];
//}


#pragma mark LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _advertiseInstance = [IOSAdvertiseHelper getInstance];
    _analyticInstance = [IOSAnalyticHelper getInstance];
    _facebookInstance = [NSClassFromString(@"FacebookHelper") getInstance];
    _amazonAwsInstance = [NSClassFromString(@"AmazonAWSHelper") getInstance];
    
    [_advertiseInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_analyticInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_facebookInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_amazonAwsInstance application:application didFinishLaunchingWithOptions:launchOptions];
    
    // rmstore 订单验证
    [RMStore defaultStore].receiptVerificator = self;
    
    // irate 评价条件
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;//无论使用的程序的那个版本都可以评论
    [iRate sharedInstance].daysUntilPrompt = 3;//首次使用开始计算N天以上
    [iRate sharedInstance].usesUntilPrompt = 10;//app打开了N次以上
    [iRate sharedInstance].eventsUntilPrompt = 10;//事件N次以上
    [iRate sharedInstance].remindPeriod = 1;//用户点击了稍后提醒以后，等待1天
    [iRate sharedInstance].cancelButtonLabel = @"";//不显示cancel按钮
    
    // GameCenter初始化
    
    [[GameCenterManager sharedManager] setupManager];
    [[GameCenterManager sharedManager] setDelegate:[[GameCenterManagerImp alloc] init]];
    
    // 验证是否设置了[UIApplication sharedApplication].delegate.window
    // 验证是否设置了[UIApplication sharedApplication].delegate.window.rootViewController
    assert([UIApplication sharedApplication].delegate.window);
    assert([UIApplication sharedApplication].delegate.window.rootViewController);
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [_advertiseInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_analyticInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_facebookInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_amazonAwsInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
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

#pragma mark RMStoreReceiptVerificator

- (void)verifyLocalTransaction:(SKPaymentTransaction *)transaction userInfo:(NSDictionary*)userInfo success:(void (^)())successBlock failure:(void (^)(NSError *))failureBlock {
    // Create the JSON object that describes the request
    NSString* userId = [userInfo objectForKey:@"userId"];
    NSString* productId = [userInfo objectForKey:@"productId"];
    NSString* receipt = [userInfo objectForKey:@"receipt"];
    void(^block)(NSString*, void(^)(NSError*)) = ^(NSString* url, void(^callback)(NSError*)) {
        NSError *error;
        NSDictionary *requestContents = @{@"receipt-data": receipt};
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
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
                                           NSString* msg = [NSString stringWithFormat:@"connectionError: %@", error];
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       NSError *error;
                                       NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                       if (!jsonResponse) {
                                           NSString* msg = [NSString stringWithFormat:@"jsonResponse: %@", error];
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
                                       NSString* bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
                                       NSString* bundle_id = [receipt objectForKey:@"bundle_id"];
                                       if (![bundle_id isEqualToString:bundleId]) {
                                           NSString* msg = [NSString stringWithFormat:@"bundle_id is wrong"];
                                           callback([NSError errorWithDomain:msg code:0 userInfo:nil]);
                                           return;
                                       }
                                       callback(nil);
                                       NSString* label = [NSString stringWithFormat:@"%@,%@", userId, productId];
                                       [[IOSAnalyticHelper getInstance] onEvent:@"Purchase" Label:label];
                                   });
                               }];
    };
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
                    _iapSuccessMsg = @"ProductionSandbox";
                    successBlock();
                }
            });
        } else {
            _iapSuccessMsg = @"Production";
            successBlock();
        }
    });
}

- (void)verifyRemoteTransaction:(SKPaymentTransaction *)transaction userInfo:(NSDictionary*)userInfo success:(void (^)())successBlock failure:(void (^)(NSError *))failureBlock {
    NSString* url = _genVerifyUrlCallFunc(userInfo);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json", nil];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        int state = [[responseObject objectForKey:@"state"] intValue];
        NSString* msg = [responseObject objectForKey:@"msg"];
        if (state == 1) {
            _iapSuccessMsg = msg;
            successBlock();
        } else {
            NSError* error = [NSError errorWithDomain:msg code:0 userInfo:nil];
            failureBlock(error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get url failed : %@", error);
    }];
}

- (void)verifyTransaction:(SKPaymentTransaction *)transaction success:(void (^)())successBlock failure:(void (^)(NSError *))failureBlock {
    void(^block)(NSString*, NSString*, NSString*) = ^(NSString* productId, NSString* userId, NSString* receipt){
        userId = userId==nil?@"unknow":userId;
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:userId forKey:@"userId"];
        [userInfo setObject:productId forKey:@"productId"];
        [userInfo setObject:receipt forKey:@"receipt"];
        void(^_successBlock)() = ^() {
            if (_iapBlock == nil) {
                if (_restoreBlock != nil) {
                    _restoreBlock(YES, productId);
                }
            }
            successBlock();
        };
        void(^_failureBlock)(NSError*) = ^(NSError* error) {
            if (_iapBlock == nil) {
                if (_restoreBlock != nil) {
                    NSString* msg = [NSString stringWithFormat:@"Payment Failed! %@", error];
                    _restoreBlock(NO, msg);
                }
            }
            failureBlock(error);
        };
        // 如果没有设置生成验证url的回调函数，本地调用苹果接口验证
        if (_genVerifyUrlCallFunc == nil) {
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
    // 如果订单回执为空刷新回执
    if (receipt == nil) {
        [[RMStore defaultStore] refreshReceiptOnSuccess:^{
            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
            if (receipt == nil) {
                NSLog(@"refresh receipt success, but receipt is still nil");
            } else {
                block(productId, userId, receipt);
            }
        } failure:^(NSError *error) {
            NSLog(@"refresh receipt failed %@", error);
        }];
    } else {
        block(productId, userId, receipt);
    }
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    //关闭邮件发送窗口
    [controller dismissViewControllerAnimated:YES completion:^{
        NSLog(@"email controller dismiss");
    }];
    BOOL success = NO;
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            success = YES;
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
    }
    NSLog(@"%@", msg);
    _emailCallFunc(success, msg);
    _emailCallFunc = nil;
}

@end

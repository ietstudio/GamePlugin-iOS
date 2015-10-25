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

#import "SystemUtil.h"

#import "IOSAdvertiseHelper.h"
#import "IOSAnalyticHelper.h"
#import "IOSFeedbackHelper.h"

#import "UIAlertView+Block.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "RWDemoViewController.h"
#import "iRate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "AFNetworking.h"
#import "NSString+MD5.h"

#if DEBUG
#define IAP_VERIFY_URL  @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define IAP_VERIFY_URL  @"https://buy.itunes.apple.com/verifyReceipt"
#import "NSLogger/NSLogger.h"
#endif

@implementation IOSGamePlugin
{
    UIImageView* _gameLoadingView;
    MBProgressHUD* _hud;
    Reachability* reachability;
    void (^_emailCallFunc)(BOOL, NSString*);
    NSString *(^_genVerifyUrlCallFunc)(NSDictionary *);
    id _advertiseInstance;
    id _analyticInstance;
    id _feedbackInstance;
    id _amazonAwsInstance;
    id _facebookInstance;
}

SINGLETON_DEFINITION(IOSGamePlugin)

#pragma mark - private method

- (void)networkDisconnect {
    NSLog(@"can not access internet");
}

- (void)networkConnect {
    NSLog(@"access internet success");
}

#pragma mark - public method

- (NSString *)getAppVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)getCountryCode {
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

- (NSString *)getLanguageCode {
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

- (NSString *)getDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (NSString *)getSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

- (time_t)getGameClock {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    (void)time(&now);
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0)
    {
        uptime = now - boottime.tv_sec;
    }
    return uptime;
}

- (void)showChooseView:(NSString *)title :(NSString *)content :(NSString *)ok :(NSString *)cancel :(void (^)(BOOL))callback {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:content
                                                       delegate:nil
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:ok, nil];
    [alertView showUsingBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (callback != nil) {
            if (buttonIndex == 0) {
                callback(NO);
            } else if (buttonIndex == 1) {
                callback(YES);
            }
        }
    }];
}

- (NSString *)getNetworkState {
    NetworkStatus state = [reachability currentReachabilityStatus];
    if (state == NotReachable) {
        return @"NotReachable";
    } else if (state == ReachableViaWWAN) {
        return @"ReachableViaWWAN";
    } else if (state == ReachableViaWiFi) {
        return @"ReachableViaWiFi";
    }
    assert(NO);
    return @"";
}

- (void)showGameLoading:(NSString *)img :(CGPoint)point :(CGFloat)scale {
    if (_gameLoadingView != nil) {
        return;
    }
    scale = UA_isRetinaDevice?scale:scale*2;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.width>screenSize.height) {
        point.x = point.x*screenSize.width;
        point.y = point.y*screenSize.height;
    } else {
        point.x = point.x*screenSize.height;
        point.y = point.y*screenSize.width;
    }
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:img]];
    CGSize viewSize = imageView.frame.size;
    viewSize = CGSizeApplyAffineTransform(viewSize, CGAffineTransformMakeScale(scale, scale));
    imageView.frame = CGRectMake(point.x-viewSize.width/2, point.y-viewSize.height/2, viewSize.width, viewSize.height);
    [[[SystemUtil getInstance] getCurrentViewController].view addSubview:imageView];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI-0.001, 0.0, 0.0, 1.0)];
    animation.duration = 0.5;
    animation.cumulative = YES;
    animation.repeatCount = INT_MAX;
    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [imageView.layer addAnimation:animation forKey:nil];
    _gameLoadingView = imageView;
}

- (void)hideGameLoading {
    if (_gameLoadingView == nil) {
        return;
    }
    [_gameLoadingView.layer removeAllAnimations];
    [_gameLoadingView removeFromSuperview];
    _gameLoadingView = nil;
}

- (void)showLoading:(NSString *)msg {
    if (_hud == nil) {
        UIWindow* window = [[SystemUtil getInstance] getCurrentWindow];
        _hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    }
    [_hud show:YES];
    _hud.labelText = msg;
}

- (void)hideLoading {
    if (_hud == nil) {
        return;
    }
    [_hud hide:YES];
    _hud = nil;
}

- (void)setGenVerifyUrlCallFunc:(NSString *(^)(NSDictionary *))func {
    _genVerifyUrlCallFunc = func;
}

- (void)doIap:(NSArray *)iapIdsArr :(NSString *)iapId :(NSString *)userId :(void (^)(BOOL, NSString *))callback {
    if ([[self getNetworkState] isEqualToString:@"NotReachable"]) {
        callback(NO, @"can not access internet");
        return;
    }
    if (![RMStore canMakePayments]) {
        callback(NO, @"can not make payments");
    }
    NSSet* iapIdsSet = [[NSSet alloc] initWithArray:iapIdsArr];
    [[RMStore defaultStore] requestProducts:iapIdsSet success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"Products loaded");
        [[RMStore defaultStore] addPayment:iapId
                                      user:userId
                                   success:^(SKPaymentTransaction *transaction) {
                                       NSLog(@"Payment Success!");
                                       callback(YES, @"Payment Success!");
                                   }
                                   failure:^(SKPaymentTransaction *transaction, NSError *error) {
                                       NSLog(@"%@", error);
                                       NSLog(@"Payment Failed!");
                                       callback(NO, @"Payment Failed!");
                                   }];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        NSLog(@"Request Products Failed!");
        callback(NO, @"Request Products Failed!");
    }];
}

- (void)showChartViewWithArr:(NSArray *)arr multiply:(float)multiply {
    UIViewController* controller = [[SystemUtil getInstance] getCurrentViewController];
    RWDemoViewController *vc = [[RWDemoViewController alloc] initWithArr:arr multiply:multiply];
    [controller presentViewController:vc
                              animated:YES
                            completion:nil];
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
        [[[SystemUtil getInstance] getCurrentViewController] presentViewController:controller animated:YES completion:^{
            NSLog(@"email controller present");
        }];
    }
    return YES;
}

#pragma mark - LifeCycleDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _advertiseInstance = [IOSAdvertiseHelper getInstance];
    _analyticInstance = [IOSAnalyticHelper getInstance];
    _feedbackInstance = [IOSFeedbackHelper getInstance];
    _facebookInstance = [NSClassFromString(@"IOSFacebookHelper") getInstance];
    _amazonAwsInstance = [NSClassFromString(@"IOSAmazonAWSHelper") getInstance];
    
    [_advertiseInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_analyticInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_feedbackInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_facebookInstance application:application didFinishLaunchingWithOptions:launchOptions];
    [_amazonAwsInstance application:application didFinishLaunchingWithOptions:launchOptions];
    
    // 注册网络状态变化通知
    __block IOSGamePlugin *gamePlugin = self;
    NSString* hostName;
    if ([[[SystemUtil getInstance] getCountryCode] isEqualToString:@"CN"]) {
        hostName = @"www.baidu.com";
    } else {
        hostName = @"www.google.com";
    }
    reachability = [Reachability reachabilityWithHostName:hostName];
    reachability.reachableBlock = ^(Reachability*reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [gamePlugin networkConnect];
        });
    };
    reachability.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [gamePlugin networkDisconnect];
        });
    };
    [reachability startNotifier];
    
    // rmstore 订单验证
    [RMStore defaultStore].receiptVerificator = self;
    
    // irate 评价条件
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;//无论使用的程序的那个版本都可以评论
    [iRate sharedInstance].daysUntilPrompt = 3;//首次使用开始计算N天以上
    [iRate sharedInstance].usesUntilPrompt = 10;//app打开了N次以上
    [iRate sharedInstance].eventsUntilPrompt = 10;//事件N次以上
    [iRate sharedInstance].remindPeriod = 1;//用户点击了稍后提醒以后，等待1天
    [iRate sharedInstance].cancelButtonLabel = @"";//不显示cancel按钮

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [_advertiseInstance applicationDidBecomeActive:application];
    [_analyticInstance applicationDidBecomeActive:application];
    [_feedbackInstance applicationDidBecomeActive:application];
    [_facebookInstance applicationDidBecomeActive:application];
    [_amazonAwsInstance applicationDidBecomeActive:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [_advertiseInstance applicationWillResignActive:application];
    [_analyticInstance applicationWillResignActive:application];
    [_feedbackInstance applicationWillResignActive:application];
    [_facebookInstance applicationWillResignActive:application];
    [_amazonAwsInstance applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [_advertiseInstance applicationDidEnterBackground:application];
    [_analyticInstance applicationDidEnterBackground:application];
    [_feedbackInstance applicationDidEnterBackground:application];
    [_facebookInstance applicationDidEnterBackground:application];
    [_amazonAwsInstance applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [_advertiseInstance applicationWillEnterForeground:application];
    [_analyticInstance applicationWillEnterForeground:application];
    [_feedbackInstance applicationWillEnterForeground:application];
    [_facebookInstance applicationWillEnterForeground:application];
    [_amazonAwsInstance applicationWillEnterForeground:application];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [_advertiseInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_analyticInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_feedbackInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_facebookInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    [_amazonAwsInstance application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [_advertiseInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_analyticInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_feedbackInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_facebookInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    [_amazonAwsInstance application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [_advertiseInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_analyticInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_feedbackInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_facebookInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
    [_amazonAwsInstance application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_advertiseInstance application:application didReceiveRemoteNotification:userInfo];
    [_analyticInstance application:application didReceiveRemoteNotification:userInfo];
    [_feedbackInstance application:application didReceiveRemoteNotification:userInfo];
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
    [_feedbackInstance application:application
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

- (void)verifyTransaction:(SKPaymentTransaction *)transaction success:(void (^)())successBlock failure:(void (^)(NSError *))failureBlock {
    void(^block)(NSString*, NSString*, NSString*) = ^(NSString* productId, NSString* userId, NSString* receipt){
        NSLog(@"%@,%@,%@", productId, userId, receipt);
        if (productId == nil || userId == nil || receipt == nil) {
            return;
        }
        // 如果没有设置生成验证url的回调函数，本地调用苹果接口验证
        if (_genVerifyUrlCallFunc == nil) {
            // Create the JSON object that describes the request
            NSError *error;
            NSDictionary *requestContents = @{@"receipt-data": receipt};
            NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
            if (!requestData) {
                NSLog(@"Error: %@", error);
            } else {
                // Create a POST request with the receipt data.
                NSURL *storeURL = [NSURL URLWithString:IAP_VERIFY_URL];
                NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
                [storeRequest setHTTPMethod:@"POST"];
                [storeRequest setHTTPBody:requestData];
                // Make a connection to the iTunes Store on a background queue.
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                           dispatch_sync(dispatch_get_main_queue(), ^{
                                               if (connectionError) {
                                                   NSLog(@"Error: %@", error);
                                               } else {
                                                   NSError *error;
                                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                                   if (!jsonResponse) {
                                                       NSLog(@"Error: %@", error);
                                                   } else {
                                                       NSLog(@"%@", jsonResponse);
                                                       // 验证status
                                                       int status = [[jsonResponse objectForKey:@"status"] intValue];
                                                       if (status != 0) {
                                                           failureBlock(nil);
                                                           return;
                                                       }
                                                       NSDictionary* receipt = [jsonResponse objectForKey:@"receipt"];
                                                       // 验证程序包名
                                                       NSString* bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
                                                       NSString* bundle_id = [receipt objectForKey:@"bundle_id"];
                                                       if (![bundle_id isEqualToString:bundleId]) {
                                                           failureBlock(nil);
                                                           return;
                                                       }
                                                       successBlock();
                                                       NSString* label = [NSString stringWithFormat:@"%@,%@", userId, productId];
                                                       [[IOSAnalyticHelper getInstance] onEvent:@"purchase" Label:label];
                                                   }
                                               }
                                           });
                                       }];
            }
        } else {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            [dict setObject:userId forKey:@"userId"];
            [dict setObject:productId forKey:@"productId"];
            [dict setObject:receipt forKey:@"receipt"];
            NSString* url = _genVerifyUrlCallFunc(dict);
            // 后台验证
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/json", nil];
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"JSON: %@", responseObject);
                int state = [[responseObject objectForKey:@"state"] intValue];
                NSString* msg = [responseObject objectForKey:@"msg"];
                if (state == 1) {
                    successBlock();
                } else {
                    failureBlock([NSError errorWithDomain:msg code:0 userInfo:nil]);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
        }
    };
    // 获取产品id
    NSString* productId = transaction.payment.productIdentifier;
    //获取用户id
    NSString* userId = transaction.payment.applicationUsername;
    //获取订单回执
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
    //如果订单回执为空刷新
    if (receipt == nil) {
        [[RMStore defaultStore] refreshReceiptOnSuccess:^{
            NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
            NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
            NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
            block(productId, userId, receipt);
        } failure:^(NSError *error) {
            NSLog(@"refresh receipt failed %@", error);
        }];
    } else {
        block(productId, userId, receipt);
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

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

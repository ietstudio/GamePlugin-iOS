//
//  SystemUtil.h
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"

#define APPLE_ID                            @"Apple_ID"

@interface SystemUtil : NSObject

SINGLETON_DECLARE(SystemUtil)

/**
 *  获取国家代码，获取不到返回US
 *
 *  @return 国家代码 eg.US
 */
- (NSString*)getCountryCode;

/**
 *  获取当前的window
 *
 *  @return window
 */
- (UIWindow*)getCurrentWindow;

/**
 *  获取当前的ViewController
 *
 *  @return UIViewController
 */
- (UIViewController*)getCurrentViewController;

/**
 *  获取info.plist中的配置信息
 *
 *  @param key
 *
 *  @return
 */
- (NSString*)getConfigValueWithKey:(NSString*)key;

@end

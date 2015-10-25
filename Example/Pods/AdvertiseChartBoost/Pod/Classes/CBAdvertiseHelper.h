//
//  CBAdvertiseHelper.h
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import <Foundation/Foundation.h>
#import "AdvertiseDelegate.h"
#import "Macros.h"

#define ChartBoost_AppId @"ChartBoost_AppId"
#define ChartBoost_AppSignature @"ChartBoost_AppSignature"
#define ChartBoost_Name @"ChartBoost"

@interface CBAdvertiseHelper : NSObject <AdvertiseDelegate>

SINGLETON_DECLARE(CBAdvertiseHelper)

@end

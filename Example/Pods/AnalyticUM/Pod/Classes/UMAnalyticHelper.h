//
//  UMAnalyticHelper.h
//  Pods
//
//  Created by geekgy on 15-4-17.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "AnalyticDelegate.h"

#define UMENG_KEY                           @"UmengKey"
#define UMENG_CHANNAL                       @"UmengChannal"

@interface UMAnalyticHelper : NSObject <AnalyticDelegate>

SINGLETON_DECLARE(UMAnalyticHelper)

@end

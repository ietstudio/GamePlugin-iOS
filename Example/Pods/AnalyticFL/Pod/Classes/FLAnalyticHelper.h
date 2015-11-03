//
//  FLAnalyticHelper.h
//  Pods
//
//  Created by geekgy on 15/11/3.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "AnalyticDelegate.h"

#define FLURRY_KEY                     @"FlurryKey"

@interface FLAnalyticHelper : NSObject <AnalyticDelegate>

SINGLETON_DECLARE(FLAnalyticHelper)

@end

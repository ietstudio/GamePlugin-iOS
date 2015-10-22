//
//  TDAnalyticHelper.h
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "AnalyticDelegate.h"

#define TALKINGDATA_KEY                     @"TalkingDataKey"
#define TALKINGDATA_CHANNAL                 @"TalkingDataChannal"

@interface TDAnalyticHelper : NSObject <AnalyticDelegate>

SINGLETON_DECLARE(TDAnalyticHelper)

@end

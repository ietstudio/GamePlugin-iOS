//
//  IOSAnalyticHelper.h
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "AnalyticDelegate.h"

@interface IOSAnalyticHelper : NSObject <AnalyticDelegate>

SINGLETON_DECLARE(IOSAnalyticHelper)

@end

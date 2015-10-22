//
//  IOSFeedbackHelper.h
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "FeedbackDelegate.h"

//#define COCOAPODS_POD_AVAILABLE_FeedbackUM
#define COCOAPODS_POD_AVAILABLE_FeedbackFD

@interface IOSFeedbackHelper : NSObject <FeedbackDelegate>

SINGLETON_DECLARE(IOSFeedbackHelper)

@end

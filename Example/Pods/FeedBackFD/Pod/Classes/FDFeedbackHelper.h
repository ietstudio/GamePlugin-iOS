//
//  FDFeedbackHelper.h
//  Pods
//
//  Created by geekgy on 15/9/15.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "FeedbackDelegate.h"

#define FRESHDESK_DOMAIN                            @"FreshDesk_domain"
#define FRESHDESK_KEY                               @"FreshDesk_key"
#define FRESHDESK_SECRET                            @"FreshDesk_secret"

@interface FDFeedbackHelper : NSObject <FeedbackDelegate>

SINGLETON_DECLARE(FDFeedbackHelper)

@end

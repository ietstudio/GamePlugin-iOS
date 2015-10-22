//
//  FeedbackDelegate.h
//  Pods
//
//  Created by geekgy on 15-4-17.
//
//

#import <Foundation/Foundation.h>
#import "LifeCycleDelegate.h"

@protocol FeedbackDelegate <LifeCycleDelegate>

@optional

/**
 *  反馈
 *
 *  @param userInfo 参数
 *
 *  @return 是否发送成功
 */
- (BOOL)showFeedBack:(NSDictionary*)userInfo;

/**
 *  检测是否收到回馈
 *
 *  @return
 */
- (int)checkFeedBack;

@end

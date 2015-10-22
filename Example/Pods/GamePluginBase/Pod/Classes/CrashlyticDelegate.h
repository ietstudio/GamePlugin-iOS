//
//  CrashlyticDelegate.h
//  Pods
//
//  Created by geekgy on 15-5-2.
//
//

#import <Foundation/Foundation.h>
#import "LifeCycleDelegate.h"

@protocol CrashlyticDelegate <LifeCycleDelegate>

@optional

/**
 *  Lua 异常
 *
 *  @param reason    异常原因
 *  @param traceback 堆栈信息
 */
- (void)onLuaException:(NSString*)reason :(NSString*)traceback;

/**
 *  Js 异常
 *
 *  @param reason    异常原因
 *  @param traceback 堆栈信息
 */
- (void)onJsException:(NSString*)reason :(NSString*)traceback;

@end

//
//  AdvertiseDelegate.h
//  Pods
//
//  Created by geekgy on 15-4-17.
//
//

#import <Foundation/Foundation.h>
#import "LifeCycleDelegate.h"

@protocol AdvertiseDelegate <LifeCycleDelegate>

@optional

/**
 *  显示插屏广告
 *
 *  @param func 插屏广告是否被点击的回调
 *
 *  @return 插屏广告是否成功显示
 */
- (BOOL)showSpotAd:(void(^)(BOOL))func;

/**
 *  视频广告准备就绪
 *
 *  @return 是否就绪
 */
- (BOOL)isVedioAdReady;

/**
 *  显示视频广告
 *
 *  @param func 视频广告是否播放完毕的回调
 *
 *  @return 视频广告是否成功显示
 */
- (BOOL)showVedioAd:(void(^)(BOOL))viewFunc :(void(^)(BOOL))clickFunc;

/**
 *  返回名称
 *
 *  @return 
 */
- (NSString*)getName;

@end

//
//  IOSAdvertiseHelper.h
//  Pods
//
//  Created by geekgy on 15-4-15.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "AdvertiseDelegate.h"

@interface IOSAdvertiseHelper : NSObject <AdvertiseDelegate>

SINGLETON_DECLARE(IOSAdvertiseHelper)

- (void)setBannerAdName:(NSString *)name;

- (void)setSpotAdNames:(NSArray *)names;

- (void)setVideoAdNames:(NSArray *)names;

@end

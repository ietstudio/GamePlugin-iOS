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

#if DEBUG
#define FILE_SERVER @"FileServerDev"
#else
#define FILE_SERVER @"FileServer"
#endif

@interface IOSAdvertiseHelper : NSObject <AdvertiseDelegate>

SINGLETON_DECLARE(IOSAdvertiseHelper)

- (void)setBannerAdName:(NSString *)name;

- (void)setSpotAdNames:(NSArray *)names;

- (void)setVideoAdNames:(NSArray *)names;

@end

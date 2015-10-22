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

//#define COCOAPODS_POD_AVAILABLE_AdvertiseAdMob
//#define COCOAPODS_POD_AVAILABLE_AdvertiseCB
//#define COCOAPODS_POD_AVAILABLE_AdvertiseAdcolony
//#define COCOAPODS_POD_AVAILABLE_AdvertiseVungle

@interface IOSAdvertiseHelper : NSObject <AdvertiseDelegate>

SINGLETON_DECLARE(IOSAdvertiseHelper)

@end

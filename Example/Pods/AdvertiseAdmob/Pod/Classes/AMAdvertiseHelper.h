//
//  AMAdvertiseHelper.h
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import <Foundation/Foundation.h>
#import "AdvertiseDelegate.h"
#import "Macros.h"

#define Admob_UnitId @"Admob_UnitId"
#define Admob_Name @"Admob"

@interface AMAdvertiseHelper : NSObject <AdvertiseDelegate>

SINGLETON_DECLARE(AMAdvertiseHelper)

- (void)createAndLoadInterstitial;

@end

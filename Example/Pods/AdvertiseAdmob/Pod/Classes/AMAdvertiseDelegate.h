//
//  AMAdvertiseDelegate.h
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import <Foundation/Foundation.h>
#import "Macros.h"
@import GoogleMobileAds;

@interface AMAdvertiseDelegate : NSObject <GADInterstitialDelegate>
{
@public
    void(^_spotFunc)(BOOL);
@private
    BOOL _clicked;
}

SINGLETON_DECLARE(AMAdvertiseDelegate)

@end

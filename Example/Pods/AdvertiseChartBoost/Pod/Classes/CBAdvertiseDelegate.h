//
//  CBAdvertiseDelegate.h
//  Pods
//
//  Created by geekgy on 15/10/23.
//
//

#import <Foundation/Foundation.h>
#import <Chartboost/Chartboost.h>
#import "Macros.h"

@interface CBAdvertiseDelegate : NSObject <ChartboostDelegate>
{
@public
    void(^_spotFunc)(BOOL);
    void(^_vedioViewFunc)(BOOL);
    void(^_vedioClickFunc)(BOOL);
}

SINGLETON_DECLARE(CBAdvertiseDelegate)

@end

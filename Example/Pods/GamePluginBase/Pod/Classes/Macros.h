//
//  Macros.h
//  Pods
//
//  Created by geekgy on 15-4-14.
//
//

/**
 *  常用宏定义
 *
 */

//获取设备屏幕尺寸
#define UA_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define UA_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//应用尺寸
#define UA_APP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width
#define UA_APP_HEIGHT [[UIScreen mainScreen]applicationFrame].size.height

//是否Retina屏
#define UA_isRetinaDevice ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] >= 2)

//是否iphone
#define UA_isIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

// 是否iPad
#define UA_isIPad   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// break if
#define GGBREAK_IF(cond) \
if (cond) {break;}

// 单例声明
#define SINGLETON_DECLARE(__CLASS_NAME__) \
+ (__CLASS_NAME__*)getInstance;

// 单例实现
#define SINGLETON_DEFINITION(__CLASS_NAME__) \
static __CLASS_NAME__* _instance = nil;\
+ (id)getInstance {\
    if (_instance == nil) {\
        _instance = [[__CLASS_NAME__ alloc] init];\
    }\
    return _instance;\
}


//
//  ImgDialogViewController.h
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgDialogViewController : UIViewController

@property (nonatomic, retain) NSString* imgPath;
@property (nonatomic, retain) NSString* btnPath;

- (void)setCallFunc:(void(^)(BOOL))func;

@end

//
//  ProgressDialogViewController.h
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressDialogViewController : UIViewController

@property (nonatomic, retain) UIProgressView* progressView;
@property (nonatomic, retain) UILabel* label;

- (void)setPercent:(NSString*)msg :(float)percent;

@end

//
//  ProgressDialogViewController.m
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "ProgressDialogViewController.h"

@implementation ProgressDialogViewController

- (id)init
{
    self = [super init];
    if (self) {
        // custom init
    }
    return self;
}

- (void)loadView {
    [super loadView];
    // 屏幕宽高
    float swidth = [UIScreen mainScreen].applicationFrame.size.width;
    float sheight = [UIScreen mainScreen].applicationFrame.size.height;
    // 最终宽高
    float dialogwidth = 0;
    float dialogheight = 0;
    if (swidth > sheight) {//横屏
        dialogwidth = swidth*0.5;
        dialogheight = dialogwidth/4;
    } else {//竖屏
        dialogwidth = swidth*0.8;
        dialogheight = dialogwidth/4;
    }
    
    CGRect frame = CGRectMake(0, 0, dialogwidth, dialogheight);
    self.view = [[UIView alloc] initWithFrame:frame];
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:frame];
    [self.view addSubview:toolbarBackground];
    
    CGRect progressFrame = CGRectMake(dialogwidth*0.1, dialogheight*0.4, dialogwidth*0.8, 5);
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:progressFrame];
    [progressView setProgress:0.0f];
    [toolbarBackground addSubview:progressView];
    self.progressView = progressView;
    
    CGRect labelFrame = CGRectMake(0, dialogheight*0.6, dialogwidth, 20);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.textAlignment = NSTextAlignmentCenter;
    [toolbarBackground addSubview:label];
    self.label = label;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPercent:(NSString *)msg :(float)percent {
    [self.progressView setProgress:percent];
    [self.label setText:[NSString stringWithFormat:@"%@...%d%%", msg, (int)(percent*100)]];
}

@end

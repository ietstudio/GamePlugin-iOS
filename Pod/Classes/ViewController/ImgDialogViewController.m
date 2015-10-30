//
//  ImgDialogViewController.m
//  CWPopupDemo
//
//  Created by Cezary Wojcik on 8/21/13.
//  Copyright (c) 2013 Cezary Wojcik. All rights reserved.
//

#import "ImgDialogViewController.h"

@implementation ImgDialogViewController
{
    void (^_func)(BOOL);
}

- (id)init
{
    self = [super init];
    if (self) {
        // custom init
        UIScreen *currentScreen = [UIScreen mainScreen];
        
        NSLog(@"applicationFrame.size.height = %f",currentScreen.applicationFrame.size.height);
        
        NSLog(@"applicationFrame.size.width = %f",currentScreen.applicationFrame.size.width);
        
        NSLog(@"applicationFrame.origin.x = %f",currentScreen.applicationFrame.origin.x);
        
        NSLog(@"applicationFrame.origin.y = %f",currentScreen.applicationFrame.origin.y);
        
        NSLog(@"bounds.x = %f",currentScreen.bounds.origin.x);
        
        NSLog(@"bounds.y = %f",currentScreen.bounds.origin.y);
        
        NSLog(@"bounds.height = %f",currentScreen.bounds.size.height);
        
        NSLog(@"bounds.width = %f",currentScreen.bounds.size.width);
        
        NSLog(@"brightness = %f",currentScreen.brightness);
    }
    return self;
}

- (void)loadView {
    [super loadView];
    // 图片制作标准及缩放比例
    float dimgwidth = 1024.0f;
    float dimgheight = 768.0f;
    float dbtnwidth = 80.0f;
    float dbtnheight = 80.0f;
    float dscale = 0.85f;
    // 屏幕宽高
    float swidth = [UIScreen mainScreen].applicationFrame.size.width;
    float sheight = [UIScreen mainScreen].applicationFrame.size.height;
    // 最终宽高
    float imgwidth = 0;
    float imgheight = 0;
    float btnwidth = 0;
    float btnheight = 0;
    if (swidth > sheight) {//横屏
        float scale = sheight/dimgheight;
        imgwidth = dimgwidth*dscale*scale;
        imgheight = dimgheight*dscale*scale;
        btnwidth = dbtnwidth*dscale*scale;
        btnheight = dbtnheight*dscale*scale;
    } else {//竖屏
        float scale = swidth/dimgheight;
        imgwidth = dimgheight*dscale*scale;
        imgheight = dimgwidth*dscale*scale;
        btnwidth = dbtnwidth*dscale*scale;
        btnheight = dbtnheight*dscale*scale;
    }
    
    CGRect frame = CGRectMake(0, 0, imgwidth, imgheight);
    self.view = [[UIView alloc] initWithFrame:frame];
    
    UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:frame];
    [self.view addSubview:toolbarBackground];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    [imageView setImage:[UIImage imageNamed:self.imgPath]];
    [toolbarBackground addSubview:imageView];
    
    UIButton* okBtn = [[UIButton alloc] initWithFrame:frame];
    [okBtn addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarBackground addSubview:okBtn];
    
    UIButton* closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(imgwidth-btnwidth, 0, btnwidth, btnheight)];
    [closeBtn setImage:[UIImage imageNamed:self.btnPath] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarBackground addSubview:closeBtn];
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

- (void)setCallFunc:(void (^)(BOOL))func {
    _func = func;
}

-(void)okClicked:(id)sender {
    if (_func != nil) {
        _func(YES);
    }
}

-(void)closeClicked:(id)sender {
    if (_func != nil) {
        _func(NO);
    }
}

@end

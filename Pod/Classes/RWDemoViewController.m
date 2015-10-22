//
//  RWDemoViewController.m
//  RWBarChartViewDemo
//
//  Created by Zhang Bin on 14-03-08.
//  Copyright (c) 2014年 Zhang Bin. All rights reserved.
//

#import "RWDemoViewController.h"
#import "RWBarChartView.h"

@interface RWDemoViewController () <RWBarChartViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) NSDictionary *singleItems; // indexPath -> RWBarChartItem

@property (nonatomic, strong) NSArray *itemCounts;

@property (nonatomic, strong) RWBarChartView *singleChartView;

@property (nonatomic, strong) NSIndexPath *indexPathToScroll;

@end

@implementation RWDemoViewController

- (id)initWithArr:(NSArray *)arr multiply:(float)multiply
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        NSMutableArray *itemCounts = [NSMutableArray array];
        NSMutableDictionary *singleItems = [NSMutableDictionary dictionary];
        
        // make sample values
        NSInteger count = [arr count];
        [itemCounts addObject:@(count)];
        for (NSInteger irow = 0; irow < count; ++irow)
        {
            NSNumber* number = [arr objectAtIndex:irow];
            float payout = [number floatValue];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:irow inSection:0];
            UIColor *color = nil;
            if (payout<1.0) {
                color = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
            } else if (payout >= 1.0) {
                color = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            }
            RWBarChartItem *singleItem = [RWBarChartItem itemWithSingleSegmentOfRatio:payout*multiply color:color];
            singleItem.text = [NSString stringWithFormat:@"%f", payout];
            singleItems[indexPath] = singleItem;
        }
        
        self.itemCounts = itemCounts;
        self.singleItems = singleItems;
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.singleChartView = [RWBarChartView new];
    self.singleChartView.dataSource = self;
    self.singleChartView.barWidth = 15;
    self.singleChartView.alwaysBounceHorizontal = YES;
    self.singleChartView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
    self.singleChartView.scrollViewDelegate = self;
    [self.view addSubview:self.singleChartView];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeBtn.frame = CGRectMake(20, 30, 90, 35);
    [closeBtn setTintColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
    [closeBtn setTitle:@"Back" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
}

-(void)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateScrollButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat padding = 20;
    CGFloat height = (self.view.bounds.size.height - [self.topLayoutGuide length] - padding);
    CGRect rect = CGRectMake(0, [self.topLayoutGuide length], self.view.bounds.size.width, height);
    self.singleChartView.frame = rect;
    
    rect.origin.y = CGRectGetMaxY(rect) + padding;
    
    [self.singleChartView reloadData];
    
}

- (NSInteger)numberOfSectionsInBarChartView:(RWBarChartView *)barChartView
{
    return self.itemCounts.count;
}

- (NSInteger)barChartView:(RWBarChartView *)barChartView numberOfBarsInSection:(NSInteger)section
{
    return [self.itemCounts[section] integerValue];
}

- (id<RWBarChartItemProtocol>)barChartView:(RWBarChartView *)barChartView barChartItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.singleItems[indexPath];
}

- (NSString *)barChartView:(RWBarChartView *)barChartView titleForSection:(NSInteger)section
{
    return @"";
}

- (BOOL)shouldShowItemTextForBarChartView:(RWBarChartView *)barChartView
{
    return YES;
}

- (BOOL)barChartView:(RWBarChartView *)barChartView shouldShowAxisAtRatios:(out NSArray *__autoreleasing *)axisRatios withLabels:(out NSArray *__autoreleasing *)axisLabels
{
    return YES;
}

- (NSIndexPath *)indexPathToScroll
{
    if (!_indexPathToScroll)
    {
        NSInteger section = arc4random() % self.itemCounts.count;
        NSInteger item = arc4random() % [self.itemCounts[section] integerValue];
        _indexPathToScroll = [NSIndexPath indexPathForItem:item inSection:section];
    }
    return _indexPathToScroll;
}

- (void)updateScrollButton
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Scroll To %ld-%ld", (long)self.indexPathToScroll.section, (long)self.indexPathToScroll.item] style:UIBarButtonItemStylePlain target:self action:@selector(scrollToBar)];
}

- (void)scrollToBar
{
    [self.singleChartView scrollToBarAtIndexPath:self.indexPathToScroll animated:YES];
    self.indexPathToScroll = nil;
    [self updateScrollButton];
}

@end

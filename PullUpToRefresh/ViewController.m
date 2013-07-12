//
//  ViewController.m
//  PullUpToRefresh
//
//  Created by hisamatsu on 2013/07/11.
//  Copyright (c) 2013年 hisamatsu. All rights reserved.
//

#import "ViewController.h"
#import "PullUpToRefresh.h"

@interface ViewController () {
    PullUpToRefresh *_pull;
}

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)scroll1500:(id)sender;
- (IBAction)scroll2000:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = NO;                    // スワイプでページング
    self.scrollView.showsHorizontalScrollIndicator = NO;    // 横スクロールバー非表示
    self.scrollView.showsVerticalScrollIndicator = YES;      // 縦スクロールバー表示
    self.scrollView.scrollsToTop = YES;                     // ステータスバーのタップによるトップ移動有効
    self.scrollView.canCancelContentTouches = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    [self.view bringSubviewToFront:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.scrollView setContentSize:CGSizeMake(320, 1500)];

//    NSLog(@"%f - %f", self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);

    _pull = [[PullUpToRefresh alloc] initWithScrollView:self.scrollView];
    [_pull setDelegate:self];
    [self.scrollView addSubview:_pull];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // これしないとメモリリーク
    [_pull removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PullUpToRefreshView

- (void)pullUpToRefreshViewShouldRefresh:(PullUpToRefresh *)view {
    NSLog(@"---------------------------------------pullToRefreshViewShouldRefresh");
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(endRefresh) userInfo:nil repeats:NO];
}

- (void)endRefresh {
    [_pull finishedLoading];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scroll --- %f - %f", (scrollView.contentOffset.y + scrollView.frame.size.height), scrollView.contentSize.height);
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
        // ここで処理してもよい
        // Instagramなど
    }
}

- (IBAction)scroll1500:(id)sender {
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.scrollView setContentSize:CGSizeMake(320, 1500)];

    // PullToRefreshビューを再配置
    [_pull updatePosition];
}

- (IBAction)scroll2000:(id)sender {
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.scrollView setContentSize:CGSizeMake(320, 2000)];

    // PullToRefreshビューを再配置
    [_pull updatePosition];
}

@end

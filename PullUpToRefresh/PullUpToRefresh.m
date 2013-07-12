//
//  PullUpToRefresh.m
//  PullUpToRefresh
//
//  Created by hisamatsu on 2013/07/11.
//  Copyright (c) 2013年 hisamatsu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PullUpToRefresh.h"

#define TEXT_COLOR     [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:1.0]

#ifdef NSTextAlignmentCenter // iOS6 and later
#   define kLabelAlignmentCenter    NSTextAlignmentCenter
#else // older versions
#   define kLabelAlignmentCenter    UITextAlignmentCenter
#endif

@interface PullUpToRefresh () {
    PullUpToRefreshViewState _state;

    UILabel *_statusLabel;
    UIActivityIndicatorView *_activityView;
}

@property (nonatomic, strong) CALayer *arrowImage;

@end

@implementation PullUpToRefresh
@synthesize delegate, scrollView;

- (id)initWithScrollView:(UIScrollView *)scroll {
    CGRect frame = CGRectMake(0.0f, scroll.contentSize.height, scroll.bounds.size.width, scroll.bounds.size.height);

    if ((self = [super initWithFrame:frame])) {
        scrollView = scroll;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:(136 / 255.f) green:(136 / 255.f) blue:(136 / 255.f) alpha:1.0f];

        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
        _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        _statusLabel.textColor = TEXT_COLOR;
        _statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
        _statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = kLabelAlignmentCenter;
        [self addSubview:_statusLabel];

        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(25.0f, 10.0f, 30.0f, 55.0f);
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = (id) [UIImage imageNamed:@"arrow@2x.png"].CGImage;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif

        [[self layer] addSublayer:layer];
        _arrowImage = layer;

        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake(25.0f, 20.0f, 20.0f, 20.0f);
        [self addSubview:_activityView];

        [self setState:PullUpToRefreshViewStateNormal];
    }

    return self;
}

- (void)setState:(PullUpToRefreshViewState)state {
    _state = state;

    switch (_state) {
        case PullUpToRefreshViewStateReady:
            _statusLabel.text = @"指を離して更新...";
            [self showActivity:NO animated:NO];
            [self setImageFlipped:YES];
            scrollView.contentInset = UIEdgeInsetsZero;
            break;

        case PullUpToRefreshViewStateNormal:
            _statusLabel.text = @"下へスライドして更新...";
            [self showActivity:NO animated:NO];
            [self setImageFlipped:NO];
            scrollView.contentInset = UIEdgeInsetsZero;
            break;

        case PullUpToRefreshViewStateLoading:
            _statusLabel.text = @"読込中...";
            [self showActivity:YES animated:YES];
            [self setImageFlipped:NO];
            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
            break;

        default:
            break;
    }
}

- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
    if (shouldShow) {
        [_activityView startAnimating];
    } else {
        [_activityView stopAnimating];
    }

    __weak PullUpToRefresh *__self = self;
    [UIView animateWithDuration:(animated ? 0.1f : 0.0) animations:^{
        __self.arrowImage.opacity = (shouldShow ? 0.0 : 1.0);
    }];
}

- (void)setImageFlipped:(BOOL)flipped {
    __weak PullUpToRefresh *__self = self;
    [UIView animateWithDuration:0.1f animations:^{
        __self.arrowImage.transform = (flipped ? CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f));
    }];
}

- (void)finishedLoading {
    if (_state == PullUpToRefreshViewStateLoading) {
        __weak PullUpToRefresh *__self = self;
        [UIView animateWithDuration:0.3f animations:^{
            [__self setState:PullUpToRefreshViewStateNormal];
        }];
    }
}

- (void)updatePosition {
    CGRect frame = CGRectMake(0.0f, scrollView.contentSize.height, scrollView.bounds.size.width, scrollView.bounds.size.height);
    self.frame = frame;
}

#pragma mark UIScrollView

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = scrollView.contentOffset;
        CGRect frame = scrollView.frame;
        CGSize size = scrollView.contentSize;

        if (scrollView.isDragging) {
            if (_state == PullUpToRefreshViewStateReady) {
                if (offset.y + frame.size.height < size.height + 65.0f && offset.y + frame.size.height > size.height) {
                    [self setState:PullUpToRefreshViewStateNormal];
                }
            } else if (_state == PullUpToRefreshViewStateNormal) {
                if (offset.y + frame.size.height > size.height + 65.0f) {
                    [self setState:PullUpToRefreshViewStateReady];
                }
            } else if (_state == PullUpToRefreshViewStateLoading) {
                if (offset.y + frame.size.height <= size.height) {
                    scrollView.contentInset = UIEdgeInsetsZero;
                } else {
                    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 60.0f, 0);
                }
            }
        } else {
            if (_state == PullUpToRefreshViewStateReady) {
                __weak PullUpToRefresh *__self = self;
                [UIView animateWithDuration:0.2f animations:^{
                    [__self setState:PullUpToRefreshViewStateLoading];
                }];

                if ([delegate respondsToSelector:@selector(pullUpToRefreshViewShouldRefresh:)]) {
                    [delegate pullUpToRefreshViewShouldRefresh:self];
                }
            }
        }
        self.frame = CGRectMake(offset.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
}

#pragma mark Dealloc

- (void)dealloc {
    [scrollView removeObserver:self forKeyPath:@"contentOffset"];
    scrollView = nil;
}

@end

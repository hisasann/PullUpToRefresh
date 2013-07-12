//
//  PullUpToRefresh.h
//  PullUpToRefresh
//
//  Created by hisamatsu on 2013/07/11.
//  Copyright (c) 2013年 hisamatsu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PullUpToRefreshViewDelegate;

typedef enum {
    PullUpToRefreshViewStateNormal = 0,
    PullUpToRefreshViewStateReady,
    PullUpToRefreshViewStateLoading
} PullUpToRefreshViewState;

@interface PullUpToRefresh : UIView {
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) id<PullUpToRefreshViewDelegate> delegate;

- (void)finishedLoading;
- (void)updatePosition;

- (id)initWithScrollView:(UIScrollView *)scroll;
@end

@protocol PullUpToRefreshViewDelegate <NSObject>

@optional
- (void)pullUpToRefreshViewShouldRefresh:(PullUpToRefresh *)view;
@end

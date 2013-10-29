//
//  RefreshTableFooterView.h
//  haha
//
//  Created by xiaobai on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	PullRefreshPulling = 0,
	PullRefreshNormal,
	PullRefreshLoading,	
} PullRefreshState;

@protocol RefreshTableFooterDelegate;
@interface RefreshTableFooterView : UIView {
	
	id _delegate;
	PullRefreshState _state;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	
    
}

@property(nonatomic,assign) id <RefreshTableFooterDelegate> delegate;

- (void)refreshLastUpdatedDate; // watch out
- (void)RefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)RefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)RefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol RefreshTableFooterDelegate  // watch out
- (void)RefreshTableFooterDidTriggerRefresh:(RefreshTableFooterView*)view;
- (BOOL)RefreshTableFooterDataSourceIsLoading:(RefreshTableFooterView*)view;
@optional
- (NSDate*)RefreshTableFooterDataSourceLastUpdated:(RefreshTableFooterView*)view;
@end
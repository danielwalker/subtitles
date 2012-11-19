//
//  LoadingView.m
//  subtitles
//
//  Created by Dan Walker on 7/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView {
	BOOL modalMode;
	CGRect modalRect;
}

+ (id)loadingViewInView:(UIView *)aSuperview WithMessage:(NSString*) message;
+ (id)loadingModalInView:(UIView *)aSuperview WithMessage:(NSString*) message;
- (void)removeView;

@property (assign) BOOL modalMode;
@property (assign) CGRect modalRect;
@end

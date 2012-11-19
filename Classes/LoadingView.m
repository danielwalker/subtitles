//
//  LoadingView.h
//  subtitles
//
//  Created by Dan Walker on 7/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

@synthesize modalMode, modalRect;

+ (id)loadingModalInView:(UIView *)aSuperview WithMessage:(NSString*) message {
	
	CGRect rect = [aSuperview bounds];
	LoadingView *loadingView = [[[LoadingView alloc] initWithFrame:rect] autorelease];
	loadingView.modalMode = YES;
	
	if (!loadingView){
		return nil;
	}
	
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	loadingView.opaque = NO;
	[aSuperview addSubview:loadingView];
	UIFont* font = [UIFont boldSystemFontOfSize:14.0];
	
	CGSize messageSize = [message sizeWithFont:font];			
	
	UILabel *loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake((rect.size.width / 2.0) - (messageSize.width / 2.0),
																	   (rect.size.height / 2.0) - (messageSize.height / 2.0) - 20,
																	   messageSize.width, 
																	   messageSize.height
																	   )] autorelease];
	loadingLabel.text = message;
	loadingLabel.textColor = [UIColor whiteColor];
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.font = font;
	loadingLabel.autoresizingMask =
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin;	
	[loadingView addSubview:loadingLabel];
	
	
	UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];	
	[loadingView addSubview:activityIndicatorView];	
	activityIndicatorView.autoresizingMask =
	UIViewAutoresizingFlexibleLeftMargin |
	UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin |
	UIViewAutoresizingFlexibleBottomMargin;	
	
	
	CGRect labelRect = loadingLabel.frame;	
	activityIndicatorView.frame = CGRectMake((rect.size.width / 2.0) - 10, labelRect.origin.y + labelRect.size.height + 10, 20, 20);
	[activityIndicatorView startAnimating];
	
	
	int MODAL_PAD = 15;
	CGRect bgRect = CGRectUnion(labelRect, activityIndicatorView.frame);
	
	bgRect.origin.x -= MODAL_PAD;
	bgRect.origin.y -= MODAL_PAD;
	bgRect.size.width += MODAL_PAD * 2;
	bgRect.size.height += MODAL_PAD * 2;
	loadingView.modalRect = bgRect;
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];	
	return loadingView;
}

+ (id)loadingViewInView:(UIView *)aSuperview WithMessage:(NSString*) message {
	
	CGRect rect = [aSuperview bounds];
	LoadingView *loadingView = [[[LoadingView alloc] initWithFrame:rect] autorelease];
	loadingView.modalMode = NO;
	
	if (!loadingView){
		return nil;
	}
	
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	loadingView.opaque = YES;
	[aSuperview addSubview:loadingView];
	UIFont* font = [UIFont systemFontOfSize:14.0];
	
	CGSize messageSize = [message sizeWithFont:font];			
	UILabel *loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake((rect.size.width / 2.0) - (messageSize.width / 2.0),
																	(rect.size.height / 2.0) - (messageSize.height / 2.0) - 20,
																	messageSize.width, 
																	messageSize.height
																	)] autorelease];
	loadingLabel.text = message;
	loadingLabel.textColor = [UIColor grayColor];
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.textAlignment = UITextAlignmentCenter;
	loadingLabel.font = font;
	loadingLabel.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;	
	[loadingView addSubview:loadingLabel];
	

	UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];	
	[loadingView addSubview:activityIndicatorView];	
	activityIndicatorView.autoresizingMask =
		UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin |
		UIViewAutoresizingFlexibleBottomMargin;	
	
	
	CGRect labelRect = loadingLabel.frame;	
	activityIndicatorView.frame = CGRectMake((rect.size.width / 2.0) - 10, labelRect.origin.y + labelRect.size.height + 10, 20, 20);
	[activityIndicatorView startAnimating];
	
	// Set up the fade-in animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];	
	return loadingView;
}

- (void)removeView {
	UIView *aSuperview = [self superview];
	[super removeFromSuperview];

	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];	
	[[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

-(void) createRoundedRect: (CGRect) rect WithRadius: (float) radius UsingContext: (CGContextRef) context {	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
	CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
	CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
	CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
	CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);	
	CGContextClosePath(context);
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if(modalMode) {
		CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.0 alpha:0.8] CGColor]);
		CGContextFillRect(context, rect);
		
		[self createRoundedRect:self.modalRect WithRadius:5.0 UsingContext:context];
		CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0.0 alpha:1.0] CGColor]);		
		CGContextFillPath(context);
		
		CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:1.0 alpha:0.5] CGColor]);
		[self createRoundedRect:self.modalRect WithRadius:5.0 UsingContext:context];
		CGContextStrokePath(context);
		
	} else {
		CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);		
		CGContextFillRect(context, rect);
	}	
}

- (void)dealloc {
    [super dealloc];
}

@end

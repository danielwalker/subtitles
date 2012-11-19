//
//  HUDView.m
//  subtitles
//
//  Created by Dan Walker on 27/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "HUDView.h"

@interface HUDView(private)

- (void) setViewToLandscape:(UIView*)viewObject;	
- (void) createRoundedRect: (CGRect) rect WithRadius: (float) radius UsingContext: (CGContextRef) context;

@end

@implementation HUDView

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {		
		[self setViewToLandscape:self];
		
		toolbarState = HUDToolbarStatePause;
		seconds = 0;
		[self focusHud:NO];
 		
		toolbarBounds = CGRectMake(387.0,295.0,88.0,20.0);
		timeBounds = CGRectMake(toolbarBounds.origin.x + 5.0,toolbarBounds.origin.y + 1.0,toolbarBounds.size.width - 5.0,toolbarBounds.size.height - 1.0);		
		toolbarImageBounds = CGRectMake(toolbarBounds.origin.x + 63,toolbarBounds.origin.y, 20, 20);
		timeFont = [UIFont boldSystemFontOfSize:14];
		toolbarPlayImage = [UIImage imageNamed:@"toolbar-play.png"];
		toolbarPauseImage = [UIImage imageNamed:@"toolbar-pause.png"];				
    }
    return self;
}

- (void)dealloc {
	[timeFont release];
	[toolbarPlayImage release];
	[toolbarPauseImage release];
    [super dealloc];	
}

- (void)drawRect:(CGRect)rect {	

    CGContextRef context = UIGraphicsGetCurrentContext();
	
	//Paint the Time/Action Toolbar.
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor);	
	[self createRoundedRect:toolbarBounds WithRadius:5.0 UsingContext:context];
	CGContextFillPath(context);
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);	
	[self createRoundedRect:toolbarBounds WithRadius:5.0 UsingContext:context];
	CGContextStrokePath(context);

	//Draw the time.
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);	
	int h = seconds / 3600, remainder = seconds % 3600, m = remainder / 60, s = remainder % 60;	
	[[NSString stringWithFormat:@"%02d:%02d:%02d", h,m,s] drawInRect:timeBounds withFont:timeFont];
	
	//Show the status image.
	CGImageRef stateImage = nil;
	if(toolbarState == HUDToolbarStatePlay) {
		stateImage = toolbarPlayImage.CGImage;
	} else if(toolbarState == HUDToolbarStatePause) {
		stateImage = toolbarPauseImage.CGImage;
	} 
	if(stateImage != nil) {
		CGContextDrawImage(context, toolbarImageBounds, stateImage);
	}
}

- (void) focusHud: (BOOL) autoblur {
	lastActivity = CFAbsoluteTimeGetCurrent();	
	if(!hasFocus) {
		hasFocus = YES;		
		[UIView beginAnimations: @"hudFocus" context: nil];	
		[UIView setAnimationDuration: 1.0];
		self.layer.opacity = 1.0;	
		[UIView commitAnimations];		
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkInactivityThenBlur) userInfo:NO repeats:NO];
	}
}

- (void)checkInactivityThenBlur {

	NSLog(@"No activity for %d", (CFAbsoluteTimeGetCurrent(), lastActivity));
	
	if(CFAbsoluteTimeGetCurrent() - lastActivity > 3) {
		[self blurHud];
	} else {
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkInactivityThenBlur) userInfo:NO repeats:NO];
	}
}
	 
- (void) blurHud {
	if(hasFocus) {
		hasFocus = NO;	
		[UIView beginAnimations: @"hudBlur" context: nil];	
		[UIView setAnimationDuration: 3.0];
		self.layer.opacity = 0.2;	
		[UIView commitAnimations];	
	}
}

- (void) setSeconds: (int) l_seconds {
	seconds = l_seconds;
	[self setNeedsDisplay];	
}

- (void) setToolbarState: (HUDToolbarState) l_toolbarState {
	toolbarState = l_toolbarState; 
	[self setNeedsDisplay];	
}

#pragma mark private

-(void)setViewToLandscape:(UIView*)viewObject {
	[viewObject setCenter:CGPointMake(160, 240)];
	CGAffineTransform cgCTM = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
	viewObject.transform = cgCTM;
	viewObject.bounds = CGRectMake(0, 0, 480, 320);
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

@end

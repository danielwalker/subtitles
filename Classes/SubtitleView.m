//
//  SubtitleView.m
//  subtitles
//
//  Created by Dan Walker on 6/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "SubtitleView.h"
#import <QuartzCore/QuartzCore.h>

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define INACTIVE_OPACITY 0.20
#define ACTIVE_OPACITY 1.0

@interface SubtitleView(private)
- (void)setViewToLandscape:(UIView*)viewObject;	
- (void) shake;
@end

@implementation SubtitleView

@synthesize subtitle, delegate;

- (id) initWithSubtitle: (Subtitle*) m_subtitle Height:(int) l_height FontHint: (int) l_fontHint {
	self = [super init];
	if (self != nil) {						
		[self setViewToLandscape:self];
		[self setSubtitle:m_subtitle];	
		
		active = NO;
		height = l_height;
		fontHint = l_fontHint;
	}
	return self;
}

- (void)dealloc {
	[label release];
	[subtitle release];
	[delegate release];
    [super dealloc];
}

- (void)layoutSubviews {
	if(label == nil){			
		[self setBackgroundColor:[UIColor blackColor]];
		self.autoresizesSubviews = YES;
		label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 460, height)];
		label.lineBreakMode = UILineBreakModeWordWrap;
		label.numberOfLines = 4;
		label.textAlignment = UITextAlignmentCenter;					
		label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;		
		label.autoresizesSubviews = YES;			
		[label setBackgroundColor:[UIColor blackColor]];
		[label setTextColor:[UIColor whiteColor]];  
		[self addSubview:label];		
		self.multipleTouchEnabled = YES;
	}
	
	label.layer.opacity = active ? ACTIVE_OPACITY : INACTIVE_OPACITY;	
	
	NSString* text = subtitle.text;			
	UIFont* font = [UIFont systemFontOfSize:fontHint];
	
	for(int i = fontHint; i > 8; i=i-2){	
		font = [font fontWithSize:i];
		const CGSize constraintSize = CGSizeMake(460.0f, MAXFLOAT);
		CGSize labelSize = [text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		if(labelSize.height <= height && labelSize.width <= 480) {
			break;
		}
	}
	label.font = font;
	label.text = text;		
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	switch ([touches count]) 
	{
		case 1:
			[delegate subtitleWasSelected:subtitle UsingTaps:1];
			break;
		case 2:
			[delegate subtitleWasSelected:subtitle UsingTaps:2];
			break;
		default:
			break;
	}
}

- (void) setActive: (BOOL) l_active animated:(BOOL)isAnimated {
	if(l_active != active) {
		active = l_active;
		if(isAnimated) {		
			[UIView beginAnimations: @"activateSubtitle" context: nil];		
			[UIView setAnimationDuration: 0.3];	
			CALayer* layer = label.layer;
			layer.opacity = l_active ? ACTIVE_OPACITY : INACTIVE_OPACITY;	
			[UIView commitAnimations];				
		} else {
			label.layer.opacity = l_active ? ACTIVE_OPACITY : INACTIVE_OPACITY;
		}
	}
}

- (BOOL) active {
	return active;	
}

#pragma mark private

#define SHAKE_DURATION 0.05
#define SHAKE_REPEAT 3.0
#define SHAKE_MOVE 5.0

-(void) shake {	
	self.transform = CGAffineTransformTranslate(self.transform, SHAKE_MOVE, 0.0);
	[UIView beginAnimations: @"shake" context: nil];	
	[UIView setAnimationDuration: SHAKE_DURATION];
	[UIView setAnimationRepeatCount: SHAKE_REPEAT];
	[UIView setAnimationRepeatAutoreverses: YES];	
	self.transform = CGAffineTransformTranslate(self.transform, -SHAKE_MOVE, 0.0);
	[UIView commitAnimations];	
}

-(void)setViewToLandscape:(UIView*)viewObject {
	[viewObject setCenter:CGPointMake(160, 240)];
	CGAffineTransform cgCTM = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-90));
	viewObject.transform = cgCTM;
	viewObject.bounds = CGRectMake(0, 0, 480, 320);
}

@end

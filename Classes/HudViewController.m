//
//  HudViewController.m
//  subtitles
//
//  Created by Dan Walker on 7/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "HudViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation HudViewController

@synthesize delegate;

#define degreesToRadian(x) (M_PI * (x) / 180.0)

- (void)handleOrientation {		
	[[self view] setTransform:CGAffineTransformIdentity];
	[[self view] setTransform:CGAffineTransformMakeRotation(degreesToRadian(-90))];
}

- (void)viewDidLoad {	
	playImg = [UIImage imageNamed:@"hud-play.png"];
	[playImg retain];
	pauseImg = [UIImage imageNamed:@"hud-pause.png"];
	[pauseImg retain];
	isPlaying = NO;		
	isVisible = YES;

	[self handleOrientation];
	[super viewDidLoad];	
}

- (void)dealloc {
	[delegate release];
	[playImg release];
	[pauseImg release];
	[playPause release];
	[time release];
    [super dealloc];
}

- (void) setSeconds: (int) seconds {
	int h = seconds / 3600, remainder = seconds % 3600, m = remainder / 60, s = remainder % 60;		
	time.text = [NSString stringWithFormat:@"%02d:%02d:%02d", h,m,s];
}

- (BOOL) isVisible {
	return isVisible;
}

- (void) hide {
	isVisible = NO;
	[UIView beginAnimations: @"hudBlur" context: nil];	
	[UIView setAnimationDuration: 2.5];
	CALayer* layer = self.view.layer;
	layer.opacity = 0.0;	
	[UIView commitAnimations];		
}

- (void) show {	
	isVisible = YES;
	[UIView beginAnimations: @"hudFocus" context: nil];	
	[UIView setAnimationDuration: 0.5];	
	CALayer* layer = self.view.layer;
	layer.opacity = 1.0;	
	[UIView commitAnimations];		
}

- (void) toggle {
	if(isVisible) {
		isVisible = NO;
		[UIView beginAnimations: @"hudBlurFast" context: nil];	
		[UIView setAnimationDuration: 0.5];
		CALayer* layer = self.view.layer;
		layer.opacity = 0.0;	
		[UIView commitAnimations];
	} else {
		[self show];
	}
}

- (IBAction) onPlayPause {
	isPlaying = !isPlaying;
	if(isPlaying){
		[playPause setImage:pauseImg forState:UIControlStateNormal];	
		[delegate onHudPlay];
	} else {
		[playPause setImage:playImg forState:UIControlStateNormal];
		[delegate onHudPause];
	}
}

- (IBAction) onStop {
	[delegate onHudStop];
}

- (IBAction) onBackward {
	[delegate onHudBackward];
}

- (IBAction) onForward {
	[delegate onHudForward];
}

- (IBAction) onBrighter {
	[delegate onHudBrighter];
}

- (IBAction) onDimmer {
	[delegate onHudDimmer];
}

- (void) notifyStopped {
	isPlaying = NO;
	[playPause setImage:playImg forState:UIControlStateNormal];	
}

@end

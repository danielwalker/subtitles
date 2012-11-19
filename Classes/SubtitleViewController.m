//
//  SubtitleViewController.m
//  subtitles
//
//  Created by Dan Walker on 6/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "SubtitleViewController.h"
#import "SubtitleService.h"
#import "SubtitleView.h"
#import "Settings.h"

#define TILE_HEIGHT 160
#define FONT_HINT 34

@interface SubtitleViewController(private)
- (void) initUI;
- (void) centerSubtitleAtIndex:(int) index animated: (BOOL) isAnimated;	
@end

@implementation SubtitleViewController

- (id) initWithSubtitleTrack: (SubtitleTrack*) l_subtitleTrack {
	self = [super init];
	if (self != nil) {										
		
		//Retain the subtitle track and initialise the UI.
		subtitleTrack = l_subtitleTrack;
		[subtitleTrack retain];	
		subtitleTrack.delegate = self;	
		
		offset = 160.0 - (TILE_HEIGHT/2);
		[self initUI];
	}
	return self;
}

- (void)dealloc {
	[hudViewController release];
	[subtitleTrack release];
	[scrollView release];
	[fadeLayer release];
    [super dealloc];
}

- (SubtitleTrack*) subtitleTrack {
	return subtitleTrack;
}

#pragma mark TiledScrollViewDataSource

- (UIView *)tiledScrollView:(TiledScrollView *)m_scrollView tileForRow:(int)row column:(int)column resolution:(int)resolution {	
	
	// Look up the subtitle.
	int index = column;
	Subtitle* subtitle = [subtitleTrack getSubtitleAt:index];
	
	// re-use a tile rather than creating a new one, if possible
    SubtitleView *tile = (SubtitleView *)[scrollView dequeueReusableTile];	
    if (!tile) {
		
        // the scroll view will handle setting the tile's frame, so we don't have to worry about it
        tile = [[[SubtitleView alloc] initWithSubtitle:subtitle Height:TILE_HEIGHT FontHint:FONT_HINT] autorelease]; 
		tile.delegate = self;
	} else {
		tile.subtitle = subtitle;
		[tile setNeedsLayout];
	}

	if([subtitleTrack currentIndex] == index){
		[tile setActive:YES animated:YES];
	} else {
		[tile setActive:NO animated:NO];	
	}
	
	return tile;
}

- (void) tiledViewDidEndScrollingAnimation {	
	if(didRequestScroll) {
		[scrollView reloadData];	
		didRequestScroll = NO;
	}
}

- (void) tiledViewDidScroll {		
	if(!didRequestScroll) {
		
		// If we (the code) didn't request a scroll, then the user did we want to remember the scroll offset of the current element.
		NSArray* views = [scrollView.containerView subviews];	
		for (UIView* view in views) {		
			if([view isKindOfClass:[SubtitleView class]]) {
				SubtitleView* subtitleView = (SubtitleView*)view;
				if(subtitleView.active) {
					
					// Here we creating a 10px margin around our 'remember scroll' logic.					 
					offset = subtitleView.frame.origin.x - [scrollView contentOffset].x;
					if(offset < 10){
						offset = 10;	
					} else if(offset > 310.0 - TILE_HEIGHT) {
						offset = 310.0 - TILE_HEIGHT;
					}
					break;
				}
			}	
		}
	}
}

#pragma mark SubtitleViewDeletgate

- (void) subtitleWasSelected: (Subtitle*) theSubtitle UsingTaps: (int) numberOfTaps {
	int index = [subtitleTrack indexOf:theSubtitle];		
	if(numberOfTaps >= 2){		
		if(index != [subtitleTrack currentIndex]) {
			[subtitleTrack setIndex:index];		
		}
	} else {		
		if(![hudViewController isVisible] || [subtitleTrack isPlaying]) {
			[hudViewController toggle];
		}
	}
}

#pragma mark SubtitleTrackDelegate

- (void) onSubtitleActive: (Subtitle*) subtitle AtIndex:(int) index {
	
	// Before making anything active, make everything unactive; prevent "flicker"
	NSArray* subviews = [scrollView.containerView subviews];
	for (UIView* view in subviews) {
		if([view isKindOfClass:[SubtitleView class]]) {
			SubtitleView* subtitleView = (SubtitleView*) view;
			if([subtitleView active]) {
				[subtitleView setActive:NO animated:NO];
				break;
			}
		}
	}
	
	// Center the sub, the scroll delate will reload.
	[self centerSubtitleAtIndex:index animated: YES];		
	didRequestScroll = YES;
}

-(void) onSubtitleTrackTimeUpdate: (int)seconds {
	[hudViewController setSeconds:seconds];	
}

-(void) onSubtitleTrackStart {	
}

-(void) onSubtitleTrackStop {
	[hudViewController notifyStopped];
	[hudViewController show];
}

#pragma mark HudDelegate 

-(void) onHudPlay {
	[subtitleTrack start];
	[hudViewController hide];
}

-(void) onHudPause {
	[subtitleTrack stop];
	[hudViewController show];
}

-(void) onHudStop {
	[subtitleTrack stop];
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(void) onHudForward {
	if([subtitleTrack currentIndex] < [subtitleTrack count] - 1) {
		[subtitleTrack setIndex:[subtitleTrack currentIndex] + 1];
	}
}

-(void) onHudBackward {
	if([subtitleTrack currentIndex] > 0) { 	
		[subtitleTrack setIndex:[subtitleTrack currentIndex] - 1];
	}
}

-(void) onHudBrighter {
	Settings* settings = [Settings instance];
	float fade = fadeLayer.opacity;
	fade -= 0.1f;
	if(fade < 0.0f) {
		fade = 0.0f;
	}
	fadeLayer.opacity = fade;
	settings.brightness = 1.0f - fade;
	[settings save];	
}

-(void) onHudDimmer {
	Settings* settings = [Settings instance];
	float fade = fadeLayer.opacity;
	fade += 0.1f;
	if(fade > 0.8f) {
		fade = 0.8f;
	}
	fadeLayer.opacity = fade;
	settings.brightness = 1.0f - fade;
	[settings save];
}

#pragma mark private

- (void) centerSubtitleAtIndex:(int) index animated:(BOOL) isAnimated{
	
	// The distance from the top of the content area to the top of the desired visible bounds.
	//float visTop = (TILE_HEIGHT * (index)) - ((scrollView.bounds.size.width-TILE_HEIGHT)/2.0); 
	
	float visTop = (TILE_HEIGHT * index) - offset; 
	
	[scrollView setContentOffset:CGPointMake(visTop, 0.0) animated:isAnimated];
}

- (void) initUI {
	Settings* settings = [Settings instance];
	self.view.autoresizingMask = UIViewAutoresizingNone;
	self.view.autoresizesSubviews = NO;
	
	//Create the tiled scroll view.
	scrollView = [[TiledScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	scrollView.dataSource = self;
	[scrollView setTileSize:CGSizeMake(TILE_HEIGHT, 480)];
	[scrollView reloadDataWithNewContentSize:CGSizeMake([subtitleTrack count] * TILE_HEIGHT, 479.9)];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0, 320.0 - TILE_HEIGHT, 0.0, 320.0 - TILE_HEIGHT)];	
	scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.bounces = NO;
	self.view.backgroundColor= [UIColor blackColor];
	[self.view addSubview:scrollView];		
	[self centerSubtitleAtIndex:0 animated:NO];
	
	fadeLayer = [CALayer layer];
	[[[self view] layer] addSublayer:fadeLayer];
	fadeLayer.backgroundColor = [[UIColor blackColor] CGColor];
	fadeLayer.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
	fadeLayer.opacity = 1.0f - settings.brightness;
	
	//Add a gradient layer.
	CALayer *gradientLayer = [CALayer layer];
	[[[self view] layer] addSublayer:gradientLayer];
	gradientLayer.contents = (id)[[UIImage imageNamed:@"background-gradient.png"] CGImage];
	gradientLayer.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
	gradientLayer.opacity = 1.0f;
		
	//Add the hud.
	hudViewController = [[HudViewController alloc] initWithNibName:@"Hud" bundle:nil];	
	hudViewController.delegate = self;
	hudViewController.view.frame = CGRectMake(250.0, 15.0, 320, 450);	
	[self.view addSubview:hudViewController.view];
}
 
@end

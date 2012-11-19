//
//  SubtitleTrack.m
//  subtitles
//
//  Created by Dan Walker on 5/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "SubtitleTrack.h"

@interface SubtitleTrack(private)
- (void) tick;
- (int) skip;
- (long) nextStartTime;
@end


@implementation SubtitleTrack

@synthesize delegate;

- (id) initWithSubtitles: (NSMutableArray*) l_subtitles {
	self = [super init];
	if (self != nil) {
		
		//Initialise defaults
		index = 0;
		startTime = 0;
		startTimeOffset = 0;
			
		subtitles = l_subtitles;
		[subtitles retain];
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) {
		
		//Initialise defaults
		index = 0;
		startTime = 0;
		startTimeOffset = 0;
		
		subtitles = [[NSMutableArray alloc] init];
		[subtitles retain];
	}
	return self;
}

- (void) dealloc
{
	[delegate release];
	[timer release];
	[subtitles release];
	[super dealloc];
}

- (Subtitle*) getSubtitleAt: (int)m_index {
	if([subtitles count] > m_index) {
		return [subtitles objectAtIndex:m_index];
	} else {
		return nil;
	}
}

- (int) indexOf: (Subtitle*) subtitle {
	return [subtitles indexOfObject:subtitle];
}

- (int) count {
	return [subtitles count];
}

- (BOOL) isPlaying {
	return timer != nil;
}

- (int) currentIndex {
	return index;
}

- (int) skip {
	if(index + 1 < [subtitles count]) {
		return ++index;
	} else {
		return -1;
	}
}

- (long) nextStartTime{
	if(index < ([subtitles count] - 1)) {	
		return ((Subtitle*)[subtitles objectAtIndex:index+1]).startTime;
	} else {
		return -1;
	}
}

- (NSArray*) subtitles {
	return subtitles;
}

- (void) start {
	Subtitle* subtitle = ((Subtitle*)[subtitles objectAtIndex:index]);	
	
	//Initialise the start time & offset.
	startTime = CFAbsoluteTimeGetCurrent();
	startTimeOffset = subtitle.startTime;	
	
	//Notify the delegate of the change in time.
	[delegate onSubtitleTrackTimeUpdate:startTimeOffset/1000];
	[delegate onSubtitleTrackStart];
	
	//Kick off the timer.
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tick) userInfo:nil repeats:YES];	
}

- (void) setIndex: (int) m_index {	
	if(timer != nil) {
		//[self stop];
	}	
	index = m_index;		
	
	//Initialise the start time & offset.
	Subtitle* subtitle = ((Subtitle*)[subtitles objectAtIndex:index]);
	startTime = CFAbsoluteTimeGetCurrent();
	startTimeOffset = subtitle.startTime;
	
	[delegate onSubtitleActive:subtitle AtIndex:index];
	[delegate onSubtitleTrackTimeUpdate:subtitle.startTime/1000];	
}

- (void) stop {
	[timer invalidate];
    timer = nil;
	[delegate onSubtitleTrackStop];
}

- (void) append: (SubtitleTrack*) track {
	[subtitles addObjectsFromArray:[track subtitles]];
}


-(void) tick {
	long elapsedTime = ((CFAbsoluteTimeGetCurrent() - startTime) * 1000) + startTimeOffset;			
	while(elapsedTime >= [self nextStartTime] && index < [self count] - 1) {		
		[self skip];			
		[delegate onSubtitleActive:[self getSubtitleAt:index] AtIndex:index];
	}				
	[delegate onSubtitleTrackTimeUpdate:elapsedTime/1000];	
	if(index == [self count] - 1) {
		[self stop];
	} 
}

@end

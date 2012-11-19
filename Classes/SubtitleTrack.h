//
//  SubtitleTrack.h
//  subtitles
//
//  Created by Dan Walker on 5/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Subtitle.h"

@protocol SubtitleTrackDelegate<NSObject>

@optional

-(void) onSubtitleActive: (Subtitle*) subtitle AtIndex:(int) index;
-(void) onSubtitleTrackTimeUpdate: (int)seconds;
-(void) onSubtitleTrackStart;
-(void) onSubtitleTrackStop;

@end


@interface SubtitleTrack : NSObject {
	NSMutableArray* subtitles;
	int index;	
	NSTimer* timer;
	long startTime;
	long startTimeOffset;
	id<SubtitleTrackDelegate> delegate;
}

@property (nonatomic, retain) id<SubtitleTrackDelegate> delegate;

// Initialisation
- (id) initWithSubtitles: (NSArray*) m_subtitles;
- (id) init;

// Querying
- (Subtitle*) getSubtitleAt: (int)index; 
- (int) indexOf: (Subtitle*) subtitle;
- (int) count;
- (BOOL) isPlaying;
- (int) currentIndex;
- (NSArray*) subtitles;

// Actions
- (void) setIndex: (int) index;
- (void) start;
- (void) stop;
- (void) append: (SubtitleTrack*) track;

@end

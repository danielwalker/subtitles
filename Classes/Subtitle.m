//
//  Subtitle.m
//  subtitles
//
//  Created by Dan Walker on 5/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "Subtitle.h"

@implementation Subtitle

@synthesize startTime, endTime, text;

- (id) initWithStartTime: (long) m_startTime endTime: (long) m_endTime text: (NSString*) m_text {
	self = [super init];
	if (self != nil) {
		startTime = m_startTime;
		endTime = m_endTime;
		[self setText:m_text];
	} 
	return self;
}

- (void) dealloc
{
	[text release];
	[super dealloc];
}

@end

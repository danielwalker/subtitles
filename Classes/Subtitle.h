//
//  Subtitle.h
//  subtitles
//
//  Created by Dan Walker on 5/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Subtitle : NSObject {
	long startTime;
	long endTime;
	NSString* text;
}

- (id) initWithStartTime: (long) m_startTime endTime: (long) m_endTime text: (NSString*) m_text;


@property (assign) long startTime;
@property (assign) long endTime;
@property (nonatomic, retain) NSString* text;
@end

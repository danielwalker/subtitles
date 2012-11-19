//
//  SubtitleSearchService.h
//  subtitles
//
//  Created by Dan Walker on 31/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubtitleSearchService : NSObject {
	NSURL* url;
	NSString* loginToken;	
}

- (NSArray*) search:(NSString*) searchString;
- (BOOL) login;

@end

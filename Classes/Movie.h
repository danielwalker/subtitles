//
//  Movie.h
//  Subtitles
//
//  Created by Dan Walker on 3/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Movie : NSObject {
	NSString* imdbId;
	NSString* name;
	NSString* year;				
	NSString* link;
	NSString* zipLink;
	NSString* lang;
	float rating;
	int uploaderRank;
	int numberOfFiles;
	BOOL hearingImpaired;
}

@property(nonatomic, retain) NSString* imdbId;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* year;				
@property(nonatomic, retain) NSString* link;
@property(nonatomic, retain) NSString* zipLink;
@property(nonatomic, retain) NSString* lang;
@property(nonatomic, assign) float rating;
@property(nonatomic, assign) int uploaderRank;
@property(nonatomic, assign) int numberOfFiles;
@property(nonatomic, assign) BOOL hearingImpaired;

-(BOOL) isSameAs:(Movie*) b;
-(BOOL) isRatedHigherThan: (Movie*) b;

@end

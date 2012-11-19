//
//  Movie.m
//  Subtitles
//
//  Created by Dan Walker on 3/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize imdbId;
@synthesize name;
@synthesize year;				
@synthesize link;
@synthesize zipLink;
@synthesize lang;
@synthesize rating;
@synthesize uploaderRank;
@synthesize numberOfFiles;
@synthesize hearingImpaired;

- (void)encodeWithCoder:(NSCoder *)coder {	
    [coder encodeObject:imdbId forKey:@"imdbId"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:year forKey:@"year"];
	[coder encodeObject:link forKey:@"link"];
	[coder encodeObject:zipLink forKey:@"zipLink"];
	[coder encodeObject:lang forKey:@"lang"];
	[coder encodeFloat:rating forKey:@"rating"];
	[coder encodeInt:uploaderRank forKey:@"uploaderRank"];
	[coder encodeInt:numberOfFiles forKey:@"numberOfFiles"];
	[coder encodeBool:hearingImpaired forKey:@"hearingImpaired"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [[Movie alloc] init];
    if (self != nil){
		self.imdbId = [coder decodeObjectForKey:@"imdbId"];
		self.name = [coder decodeObjectForKey:@"name"];
		self.year = [coder decodeObjectForKey:@"year"];
		self.link = [coder decodeObjectForKey:@"link"];
		self.zipLink = [coder decodeObjectForKey:@"zipLink"];
		self.lang = [coder decodeObjectForKey:@"lang"];
		self.rating = [coder decodeFloatForKey:@"rating"];
		self.uploaderRank = [coder decodeIntForKey:@"uploaderRank"];
		self.numberOfFiles = [coder decodeIntForKey:@"numberOfFiles"];
		self.hearingImpaired = [coder decodeBoolForKey:@"hearingImpaired"];		
	}   
    return self;
}


-(BOOL) isSameAs:(Movie*) b {
	BOOL same = [self.imdbId isEqualToString:b.imdbId] && [self.lang isEqualToString:b.lang] && self.hearingImpaired == b.hearingImpaired;		
	return same;
}

-(BOOL) isRatedHigherThan: (Movie*) b {	
	if(self.uploaderRank > b.uploaderRank){
		return true;	
	}	
	if(self.rating > b.rating) {
		return true;
	}
	return false;	
}

- (void)dealloc {
	[imdbId release];
	[name release];
	[year release];				
	[link release];
	[zipLink release];
	[lang release];
    [super dealloc];
}


@end

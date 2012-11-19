//
//  SubtitleSearchService.m
//  subtitles
//
//  Created by Dan Walker on 31/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "SubtitleSearchService.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnection.h"
#import "XMLRPCResponse.h"
#import "Movie.h"
#import "Settings.h"

@interface SubtitleSearchService(Private)	
	- (NSError *)errorWithResponse:(XMLRPCResponse *)res;
	- (id)executeXMLRPCRequest:(XMLRPCRequest *)req;
@end

@implementation SubtitleSearchService

#define URL @"http://api.opensubtitles.org/xml-rpc"
#define AGENT @"Subtitles DW"

- (id) init {
	self = [super init];
	if (self != nil) {
		url = [NSURL URLWithString:URL];
		[url retain];		
		loginToken = nil;
	}
	return self;
}

-(NSArray*)search:(NSString*) searchString {
	
	NSMutableArray* movies = [[NSMutableArray alloc] init];
	
	if(loginToken != nil || [self login]){ 					
		XMLRPCRequest* request =[[XMLRPCRequest alloc] initWithHost:url];				
	
		//Build the language string.
		Settings* settings = [Settings instance];
		NSMutableString* langString = [[NSMutableString alloc] init];
		if(settings.languages != nil && [settings.languages count] > 0){
			for (NSString* lang in settings.languages) {
				if([langString length] > 0){
					[langString appendString: @","];
				}
				[langString appendString: lang];
			}				
		} else {
			[langString appendString:@"eng,fre,ger,jpn,dut,ita,spa,pob,por,dan,fin,nor,swe,chi,pol,rus,alb,ara,bul,cze"];

		}
		
		NSDictionary *query = [NSDictionary dictionaryWithObjects:
								[NSArray arrayWithObjects:searchString, langString, nil] 
								forKeys:
								[NSArray arrayWithObjects:@"query", @"sublanguageid", nil]];
		
		[langString release];
		
		NSArray *qargs = [NSArray arrayWithObjects:query, nil];
		
		NSArray *args = [NSArray arrayWithObjects:
						 loginToken,
						 qargs,						
						 nil];
		
		[request setMethod:@"SearchSubtitles" withObjects:args];			
		id response = [self executeXMLRPCRequest:request];				
		[request release];
		
		if ([response isKindOfClass:[NSError class]]) {
			NSLog(@"An error occurred during search: %@", [((NSError*)response) description]);
		} else {													
			NSArray* results = [response valueForKey:@"data"];						
			if ([results isKindOfClass:[NSArray class]]) {								
				for (NSDictionary* movieAttr in results) {																
					
					//Ignore non SRT.
					if([(NSString*)[movieAttr valueForKey:@"SubFormat"] isEqualToString:@"srt"]) {
					
						Movie* movie = [[Movie alloc] init];
						movie.imdbId = [movieAttr valueForKey:@"IDMovieImdb"];
						movie.name = [movieAttr valueForKey:@"MovieName"];
						movie.year = [movieAttr valueForKey:@"MovieYear"];				
						movie.link = [movieAttr valueForKey:@"SubDownloadLink"];
						movie.zipLink = [movieAttr valueForKey:@"ZipDownloadLink"];
						movie.lang = [movieAttr valueForKey:@"SubLanguageID"];
						movie.hearingImpaired = [[movieAttr valueForKey:@"SubHearingImpaired"] boolValue]; 
						NSString* rating = [movieAttr valueForKey:@"SubRating"];										
						movie.rating = [rating floatValue];												
						movie.numberOfFiles = [[movieAttr valueForKey:@"SubSumCD"] integerValue];
												
						NSString* rank = [movieAttr valueForKey:@"UserRank"];
						movie.uploaderRank = 0;
						if([rank isEqualToString:@"vip member"]) {							
							movie.uploaderRank = 5;
						} else if([rank isEqualToString:@"platinum member"]) {
							movie.uploaderRank = 4;
						} else if([rank isEqualToString:@"gold member"]) {	
							movie.uploaderRank = 3;
						} else if([rank isEqualToString:@"bronse member"]) {
							movie.uploaderRank = 2;
						} else if([rank isEqualToString:@"trusted"]) {	
							movie.uploaderRank = 1;	
						}
												
						Movie* existingMovie = nil;
						int existingMovieIndex;
						for (int j = 0; j < [movies count]; j++) {
							Movie* checkMovie = [movies objectAtIndex:j];
							if([movie isSameAs:checkMovie]) {
								existingMovie = checkMovie;
								existingMovieIndex = j;
								break;
							}
						}
						
						//Clean up the movie name.
						if([movie.name length] > 2){
							if([movie.name characterAtIndex:0] == '"' && [movie.name characterAtIndex:[movie.name length] - 1] == '"'){										
								movie.name = [movie.name substringWithRange:NSMakeRange(1, [movie.name length] - 2)]; 		
							}
						}																										
																													
						if(existingMovie != nil) {									
							if([movie isRatedHigherThan:existingMovie]) {															
								NSLog(@"replacing with a higher raited file %@ : rating=%f uploaderRank=%i",movie.name, movie.rating, movie.uploaderRank);
								[movies replaceObjectAtIndex:existingMovieIndex withObject:movie];							
							} else {
								NSLog(@"ignoring because of raiting %@ : rating=%f uploaderRank=%i",movie.name, movie.rating, movie.uploaderRank);					
							}							
						} else {
							[movies addObject:movie];
							NSLog(@"ignoring because exisits %@ (%@) : imdb=%@ lang=%@", movie.name, movie.year, movie.imdbId, movie.lang);					
						}								
						[movie release];
					}
					else {
						NSLog(@"ignoring because subtitle is of format: %@", (NSString*)[movieAttr valueForKey:@"SubFormat"]);					
					}
				}		
			}	
		}							
		return [movies autorelease];
	} 	
	return nil;
}

- (void)dealloc {
	[loginToken release];
	[url release];
    [super dealloc];
}

#pragma mark private

-(BOOL) login {
	XMLRPCRequest* request =[[XMLRPCRequest alloc] initWithHost:url];		
	NSArray *args = [NSArray arrayWithObjects:
					 @"dan1e1w",
					 @"bod1zaffa",
					 @"en",
					 AGENT,					 
					 nil];
	
	[request setMethod:@"LogIn" withObjects:args];	
	id response = [self executeXMLRPCRequest:request];
	[request release];
	
    if ([response isKindOfClass:[NSError class]]) {
		NSLog(@"An error occurred during login: %@", [((NSError*)response) description]);
		return NO;
    } else {
        loginToken = [response valueForKey:@"token"];
		[loginToken retain];
		NSLog(@"Logged in as %@", loginToken);
		return YES;
    }
}

- (id)executeXMLRPCRequest:(XMLRPCRequest *)req  {	
	XMLRPCResponse *userInfoResponse = userInfoResponse = [XMLRPCConnection sendSynchronousXMLRPCRequest:req];	
	NSError *err = [self errorWithResponse:userInfoResponse];	
	if (err) {
		
		// Alert.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Connection Error", nil)
												  message:NSLocalizedString(@"Unable to contact www.opensubtitles.org. If the problem persists please notify support@structure6.com.", nil)
												  delegate:self
												  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
												  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return err;	
	}	
	return [userInfoResponse object];
}
									
- (NSError *)errorWithResponse:(XMLRPCResponse *)res {
    NSError *err = nil;	
    if (!res) {
		NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Failed to request the server.", NSLocalizedDescriptionKey, nil];
		return [NSError errorWithDomain:@"com.structure6.subtitles" code:-1 userInfo:usrInfo];
	}	
    if ([res isKindOfClass:[NSError class]]) {
        err = (NSError *)res;
    } else {
        if ([res isFault]) {
            NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[res fault], NSLocalizedDescriptionKey, nil];
            err = [NSError errorWithDomain:@"com.structure6.subtitles" code:[[res code] intValue] userInfo:usrInfo];
        }		
        if ([res isParseError]) {
            err = [res object];
        }
    }		
    return err;
}

@end

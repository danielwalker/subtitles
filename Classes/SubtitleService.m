//
//  SubtitleService.m
//  subtitles
//
//  Created by Dan Walker on 4/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "SubtitleService.h"
#import "zlib.h"  
#import "ZipArchive.h"
#import "UniversalDetector.h"
#import "Settings.h"

@interface SubtitleService(private)

- (long) parseMillis: (NSString*)marker;
- (SubtitleTrack*) parseSRT: (NSString*)contents WithTimeOffset: (long) offset;
- (NSString*) flattenHTML:(NSString *)html;
- (NSString*) gunzip:(NSString*) fromUrl: (NSString*) toDir;
- (void) registerDownload:(Movie*) movie;
- (NSString*) downloadAndSave:(NSString*)fromUrl toDir: (NSString*)toDir DidRequireDownload:(BOOL*) didRequire ForceDownload: (BOOL) force;
- (NSString*) findHomeDir;
- (NSArray*) findSRTPaths: (Movie*) movie InDirectory: (NSString*) documentsDirectory;
- (NSString*) readFileToString: (NSString*) path language:(NSString*)language;
- (NSData*) cleanBig5: (NSData *)inData;
@end

@implementation SubtitleService

- (void) dealloc {
	[super dealloc];
}

#ifdef TEST_SUBTITLE_VIEW

- (SubtitleTrack*) load:(Movie*)movie ForceDownload:(BOOL) forceDownload;
	NSMutableArray* subtitles = [[NSMutableArray alloc]init];		
	[subtitles addObject:[[[Subtitle alloc] initWithStartTime:1000 endTime:5000 text:@"Zero\nsubtitle to display\nwith multiple lines"] autorelease]];
	[subtitles addObject:[[[Subtitle alloc] initWithStartTime:5000 endTime:10000 text:@"Ten"] autorelease]];
	[subtitles addObject:[[[Subtitle alloc] initWithStartTime:10000 endTime:15000 text:@"One really really really really really long line"] autorelease]];
	SubtitleTrack* subtitleTrack = [[SubtitleTrack alloc]initWithSubtitles:subtitles];				
	return [subtitleTrack autorelease];
}

#else

- (SubtitleTrack*) load:(Movie*)movie ForceDownload:(BOOL) forceDownload {
	NSFileManager* fileManager =[NSFileManager defaultManager];
	NSString* documentsDirectory = [self findHomeDir];				
	NSString* tmpDir = [documentsDirectory stringByAppendingString:@"/temp"];
		
	//clean the temp document directory.	
	[fileManager removeItemAtPath:tmpDir error:nil];
	[fileManager createDirectoryAtPath:tmpDir attributes:nil];
	
	//Unzip the file we downloaded.
	BOOL didDownload = NO;
	NSString* path = [self downloadAndSave:movie.zipLink toDir:documentsDirectory DidRequireDownload:&didDownload ForceDownload: forceDownload];
	ZipArchive *za = [[ZipArchive alloc] init];
	if ([za UnzipOpenFile: path]) {
		BOOL ret = [za UnzipFileTo: tmpDir overWrite: YES];
		if (NO == ret){} [za UnzipCloseFile];
	}
	[za release];
	
	// Get a list of all srt files in the document directory.
	NSArray* srtPaths = [self findSRTPaths:movie InDirectory:tmpDir];			
	SubtitleTrack* returned = [[SubtitleTrack alloc] init];
	long offset = 0;
	for (NSString* srtPath in srtPaths) {			
		NSString* toReadPath = [NSString stringWithFormat:@"%@/%@", tmpDir, srtPath];		
		NSLog(@"Parsing %@", toReadPath);
		NSString* content = [self readFileToString:toReadPath language:movie.lang];								
		if(content != nil){
			SubtitleTrack* track =[self parseSRT:content WithTimeOffset:offset];		
			if(track != nil){
				[returned append:track];
				offset = [track getSubtitleAt:[track count] -1].endTime;
			} else {
				
				// Don't serve half a track.
				[returned release];
				return nil;
			}
		} 
	}
	
	if(didDownload){
		[self registerDownload: movie];
	}
	
	return [returned autorelease];		
}

#endif

#pragma mark private methods:

-(void) registerDownload:(Movie*) movie {	
	Settings* settings = [Settings instance];		
	
	// If adding the same movie as one already saved...
	int downloadCount = [settings.downloads count];
	for(int i=0;i<downloadCount;i++){		
		Movie* downloadedMovie = [settings.downloads objectAtIndex:i];							
		if([downloadedMovie isSameAs:movie]){
			
			// If the old and new movies point to different files, remove the old one.
			if(![downloadedMovie.zipLink isEqualToString:movie.zipLink]) {									
				[self deleteDownloadedFile:movie];
			}
			
			//Remove the old movie from the download list.
			[settings.downloads removeObjectAtIndex:i];			
			break;
		}
	}				
	[settings.downloads addObject:movie];
	
	// Cap the movie downloads at 50.
	if([settings.downloads count] > 50){
		Movie* toDelete = [settings.downloads objectAtIndex:0];
		[self deleteDownloadedFile:toDelete];
		[settings.downloads removeObject:toDelete];
	}
	
	[settings save];
}

-(void) deleteDownloadedFile:(Movie*) movie {	
	NSString* fileName = [[movie.zipLink componentsSeparatedByString:@"/"] lastObject];	
	NSString* oldFilePath = [[self findHomeDir] stringByAppendingString:@"/"];
	oldFilePath = [oldFilePath stringByAppendingString:fileName];
	[[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:nil];
}

- (NSArray*) findSRTPaths: (Movie*) movie InDirectory: (NSString*) documentsDirectory {
	NSFileManager* fileManager =[NSFileManager defaultManager];
	NSArray* directoryContents = [fileManager subpathsAtPath:documentsDirectory];
	NSMutableArray* srtPaths = [[NSMutableArray alloc] init] ;			
	for (NSString* path in directoryContents) {
		if([path hasSuffix:@".srt"] || [path hasSuffix:@".SRT"] || [path hasSuffix:@".sub"] || [path hasSuffix:@".SUB"]) {			
			if(![path hasSuffix:@"-Standard.srt"]) {
				[srtPaths addObject: path];	
			}			
		}
	}	
	
	// Ignore any bullshit files (grab the n biggest srt files.
	if([srtPaths count] > movie.numberOfFiles) {
		
		//Sort the files by size;
		for(int i=0;i<[srtPaths count];i++){
			for(int j=0;j<[srtPaths count];j++){												
				NSString* pathI = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [srtPaths objectAtIndex:i]];
				NSString* pathJ = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [srtPaths objectAtIndex:j]];				
				long iSize = [[fileManager attributesOfItemAtPath: pathI error:nil] fileSize];
				long jSize = [[fileManager attributesOfItemAtPath: pathJ error:nil] fileSize];
				if(jSize < iSize){
					[srtPaths exchangeObjectAtIndex:i withObjectAtIndex:j];
				}				
			}				
		}
		
		// Remove everything after move.numberOfFiles
		while([srtPaths count] > movie.numberOfFiles) {	
			NSLog(@"Ignoring %@ becuase it's probably junk.", [srtPaths lastObject]);
			[srtPaths removeLastObject];	
		}
			
		//Re-order in alphabetical.
		NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES selector:@selector(localizedCompare:)]; 
		[srtPaths sortUsingDescriptors:[NSArray arrayWithObject:desc]];						
	}			
	return [srtPaths autorelease];
}

- (NSString *)flattenHTML:(NSString *)html {	
	html = [html stringByReplacingOccurrencesOfString:@"<i>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
	html = [html stringByReplacingOccurrencesOfString:@"</i>" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
	return html;
}

- (NSString*) readFileToString: (NSString*) path language:(NSString*)language {	
	
	NSString* dataString = nil;
	NSData* data = [NSData dataWithContentsOfFile:path];	
	
	//Special cases that I know auto-detection doesn't seem to handle.
	if([language isEqualToString:@"ara"]){
		dataString = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingISOLatinCyrillic)];		
	} else if([language isEqualToString:@"cze"]){
		NSLog(@"Attempting to use special-case cze encoding...");
		dataString = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingWindowsLatin2)];		
	}
			
	//If it's null, try and autodetect.
	if(dataString == nil){
		
		//Read the data to determine encoding.		
		UniversalDetector *detector=[UniversalDetector detector];
		[detector analyzeData:data];
		
		// Attempt a straight encode using the detected encoding type.
		NSString* encodingType = [detector MIMECharset];		
		NSLog(@"Attempting to %@ encode file: %@", [detector MIMECharset], path);	
		dataString = [[NSString alloc] initWithData:data encoding:[detector encoding]];
		
		//Do we have a cleanse operation for this encoding type?
		if(dataString == nil){				
			if([@"Big5" isEqualToString:encodingType]) {
				NSLog(@"Cleansing Big5 encoded file and retrying to encode...");
				data = [self cleanBig5: data];			
			}
			dataString = [[NSString alloc] initWithData:data encoding:[detector encoding]];
		}
	}
		
	//Okay, give up if dataString is still empty.
	if(dataString == nil){
		NSLog(@"Failed to encode subtitle file.");
	}
	
	return dataString;	
}

- (SubtitleTrack*) parseSRT: (NSString*)contents WithTimeOffset: (long) offset {
	contents = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if([contents length] > 0){
		
		NSArray* lines = [contents componentsSeparatedByString:@"\n"];
		NSMutableArray* subtitles = [[NSMutableArray alloc]init];		
		
		BOOL subAdded = YES;
		int lineCount = 0;
		NSMutableString* text = [[NSMutableString alloc] init];
		long startTime, endTime;
		for (NSString *line in lines) {						
			line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];					
												
			if(lineCount == 1) {
				
				NSArray* array = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
												
				if([array count] != 3){
					NSLog(@"Forcing parsing break on subtitle file due to a bad time marker [%@]", line);
					break;
				} else { 
					
					//Time marker
					startTime = [self parseMillis: [array objectAtIndex:0]] + offset;			
					endTime = [self parseMillis:[array objectAtIndex:2]] + offset;		
					if(startTime == -1 || endTime == -1){
						NSLog(@"Forcing parsing break on subtitle file due to a bad time marker [%@]", line);
						break;	
					}					
					subAdded = NO;
				}
			} else if(lineCount > 1) {
						
				//Text
				if ([text length] > 0 && [line length] > 0) {
					[text appendString:@"\n"];
				}
				[text appendString:line];					
				
			}

			lineCount++;
			
			if([line length] == 0) {						
				if(!subAdded) {
					NSString* currentText = [[self flattenHTML:text] copy];
					Subtitle* subtite = [[Subtitle alloc] initWithStartTime:startTime endTime:endTime text:currentText];
					[currentText release];
					[subtitles addObject:subtite];
					[subtite release];
					[text deleteCharactersInRange:NSMakeRange(0, [text length])];				
					subAdded = YES;
				}
				lineCount = 0;
			}

		}
		
		//Just in case the file didn't end with a return character:
		if(!subAdded) {
			NSString* currentText = [[self flattenHTML:text] copy];
			Subtitle* subtite = [[Subtitle alloc] initWithStartTime:startTime endTime:endTime text:currentText];
			[currentText release];
			[subtitles addObject:subtite];
			[subtite release];			
		}
		
		SubtitleTrack* track = [[SubtitleTrack alloc] initWithSubtitles:subtitles];	
		[text release];
		[subtitles release];	
		return [track autorelease];
	}
	return nil;	
}

- (long) parseMillis: (NSString*)marker {	
	NSArray* array = [marker componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",:"]];	
	if([array count] == 4) {
		double millisec = 0;
		millisec += [[array objectAtIndex:0] intValue] * 3600000;
		millisec += [[array objectAtIndex:1] intValue] * 60000;
		millisec += [[array objectAtIndex:2] intValue] * 1000;
		millisec += [[array objectAtIndex:3] intValue];
		return millisec;
	} else {
		return -1;
	}	
}	

- (NSString*) downloadAndSave:(NSString*)fromUrl toDir: (NSString*)toDir DidRequireDownload:(BOOL*) didRequire ForceDownload: (BOOL)forceDownload {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* fileName = [[fromUrl componentsSeparatedByString:@"/"] lastObject];	
	NSString* zipPath = [toDir stringByAppendingPathComponent: fileName];	
	
	if(forceDownload && [fileManager fileExistsAtPath:zipPath]) {
		[fileManager removeItemAtPath:zipPath error:nil];
	}
	
	NSData* zipFile = nil;
	if([fileManager fileExistsAtPath:zipPath]) {
		zipFile = [NSData dataWithContentsOfFile:zipPath];		
		*didRequire = NO;
	} else {		
		NSURL *url = [NSURL URLWithString:fromUrl];	
		zipFile = [NSData dataWithContentsOfURL:url];		
		[zipFile writeToFile:zipPath atomically:YES];
		*didRequire = YES;
	}
	
	return zipPath;
}

- (NSString*) findHomeDir {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

#define BUFFER 16384

- (NSString*) gunzip:(NSString*) fromUrl: (NSString*) toDir {
	NSString *unzipeddest = [toDir stringByAppendingPathComponent:@"subtitle.srt"];	
	
	FILE *dest = fopen([unzipeddest UTF8String], "w");		
	gzFile file = gzopen([fromUrl UTF8String], "rb");	
	
	unsigned char buffer[BUFFER];	
	int readBytes;
	while((readBytes = gzread(file, buffer, BUFFER)) > 0){
		if(fwrite(buffer, 1, readBytes, dest) != readBytes || ferror(dest)) { 
			NSLog(@"Error decompressing downloaded file."); 	
		} 		
	}
	
	fclose (dest);
	return unzipeddest;
}

#pragma mark cleanse functions for various encodings

- (NSData *) cleanBig5: (NSData *)inData {
	const uint8_t   *inBytes;
	NSUInteger		inLength;
	NSUInteger      inIndex;	
	NSMutableData   *outData;
	uint8_t         *outBytes;
	NSUInteger      outIndex;	
	NSUInteger      current;
	
	if(inData==nil) return inData;
	
	inBytes  = [inData bytes];
	inLength = [inData length];
	
	outData = [NSMutableData dataWithLength:inLength];
	if(outData==nil) return inData;
	
	outBytes = [outData mutableBytes];
	outIndex = 0;
	
	BOOL firstByte = YES;	
	for (inIndex = 0; inIndex < inLength; inIndex++) {
		current = inBytes[inIndex];
		if (firstByte) {			
			if(current >= 0x81 && current <= 0xfE) {
				firstByte = NO;
				
				// Good First byte
				outBytes[outIndex] = current;						
			} else if(current <= 0X7F){
				
				//ASCII First byte.
				outBytes[outIndex++] = current;
				
			} else {
				//Bad First Byte
			}
		} else {			
			if(((current >= 0x40 && current <= 0x7E) || (current >= 0xA1 && current <= 0xFE)) ) {
				
				//Good Second Byte
				outIndex++;
				outBytes[outIndex++] = current;
			} else {
				
				//Bad Second Byte.					
			}
			firstByte = YES;
		}	
	}	
	
	[outData setLength:outIndex];
	return outData;
}

@end

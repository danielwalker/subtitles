//
//  SubtitlesAppDelegate.m
//  Subtitles
//
//  Created by Dan Walker on 28/12/09.
//  Copyright Structure6 2009. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "SubtitlesAppDelegate.h"

@implementation SubtitlesAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	application.statusBarStyle = UIStatusBarStyleBlackOpaque;
	[window addSubview:tabBarController.view];
	[window makeKeyAndVisible];
	
	// Encoding test code.
	/*	 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* path = [documentsDirectory stringByAppendingString:@"/Avatar.DVDScr.xvid-IMAGiNE-CZ.srt"];
	NSString* data = [NSString stringWithContentsOfFile:path encoding:CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingWindowsLatin2) error:nil];
	NSLog(@"reading %@", data);
	*/
}

- (void)dealloc {
    [window release];
	[tabBarController release];
    [super dealloc];
}

@end

//
//  SubtitleService.h
//  subtitles
//
//  Created by Dan Walker on 4/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Subtitle.h"
#import "SubtitleTrack.h"
#import "Movie.h"

@interface SubtitleService : NSObject {

}

- (SubtitleTrack*) load:(Movie*)movie ForceDownload:(BOOL) forceDownload;
- (void) deleteDownloadedFile:(Movie*) movie;

@end

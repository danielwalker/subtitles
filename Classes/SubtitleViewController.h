//
//  SubtitleViewController.h
//  subtitles
//
//  Created by Dan Walker on 6/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TiledScrollView.h"
#import "SubtitleTrack.h"
#import "SubtitleView.h"
#import "HudViewController.h"

@interface SubtitleViewController : UIViewController <TiledScrollViewDataSource, SubtitleViewDeletgate, SubtitleTrackDelegate, HudDelegate>{
	HudViewController* hudViewController;
	SubtitleTrack* subtitleTrack;	
	TiledScrollView* scrollView;
	CALayer *fadeLayer;
	BOOL didRequestScroll;
	
	float offset;
}

- (id) initWithSubtitleTrack: (SubtitleTrack*) l_subtitleTrack;
- (SubtitleTrack*) subtitleTrack;

@end

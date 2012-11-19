//
//  SubtitleView.h
//  subtitles
//
//  Created by Dan Walker on 6/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Subtitle.h"

@protocol SubtitleViewDeletgate <NSObject>

@required
- (void) subtitleWasSelected: (Subtitle*) theSubtitle UsingTaps: (int) numberOfTaps;
@end

@interface SubtitleView : UIView {	
	Subtitle* subtitle;
	UILabel* label;
	id<SubtitleViewDeletgate> delegate;		
	BOOL active;
	
	int height;
	int fontHint;
}

- (id) initWithSubtitle: (Subtitle*) m_subtitle Height:(int) l_height FontHint: (int) l_fontHint;
- (void) setActive: (BOOL) active animated:(BOOL)isAnimated;
- (BOOL) active;

@property (nonatomic, retain) Subtitle* subtitle;
@property (nonatomic, retain) id<SubtitleViewDeletgate> delegate;

@end
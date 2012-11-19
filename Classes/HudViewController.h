//
//  HudViewController.h
//  subtitles
//
//  Created by Dan Walker on 7/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HudDelegate<NSObject>
@optional
-(void) onHudPlay;
-(void) onHudPause;
-(void) onHudStop;
-(void) onHudForward;
-(void) onHudBackward;
-(void) onHudBrighter;
-(void) onHudDimmer;
@end

@interface HudViewController : UIViewController {
	UIImage* playImg;
	UIImage* pauseImg;	
	IBOutlet UILabel* time;
	IBOutlet UIButton* playPause;
	bool isPlaying;
	bool isVisible;
	id<HudDelegate> delegate;
}

@property (nonatomic, retain) id<HudDelegate> delegate;

- (void) setSeconds: (int) seconds;
- (IBAction) onPlayPause;
- (IBAction) onStop;
- (IBAction) onBackward;
- (IBAction) onForward;
- (IBAction) onBrighter;
- (IBAction) onDimmer;
- (void) notifyStopped;

- (BOOL) isVisible;
- (void) hide;
- (void) show;
- (void) toggle;

@end

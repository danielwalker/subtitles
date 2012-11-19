//
//  SubtitlesAppDelegate.h
//  Subtitles
//
//  Created by Dan Walker on 28/12/09.
//  Copyright Structure6 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MovieSearchViewController.h"
#import "SubtitleViewController.h"
#import "Movie.h"

@interface SubtitlesAppDelegate : NSObject <UIApplicationDelegate> {	
    UIWindow *window;	
	UITabBarController *tabBarController;
	
	MovieSearchViewController* movieSearchViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end


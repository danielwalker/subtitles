//
//  MovieSearchViewController.h
//  subtitles
//
//  Created by Dan Walker on 31/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubtitleSearchService.h"
#import "SubtitleService.h"
#import "LoadingView.h"
#import "Movie.h"
#import "SubtitleTrack.h"
#import "SubtitleViewController.h"

@interface MovieSearchViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {	
	
	SubtitleViewController* subtitleViewController;
	SubtitleSearchService* subtitleSearchService;	
	SubtitleService* subtitleService;
	
	NSMutableArray* currentResults;
	LoadingView* loadingView;
	
	IBOutlet UISearchBar* searchBar;
	IBOutlet UITableView* table;
	
	UITableViewCell *movieCell;	
}

@property (nonatomic,retain) SubtitleSearchService* subtitleSearchService;
@property (nonatomic,retain) SubtitleService* subtitleService;
@property (nonatomic,retain) LoadingView* loadingView;
@property (nonatomic, assign) IBOutlet UITableViewCell *movieCell;

@end

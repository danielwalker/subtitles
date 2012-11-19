//
//  SavedMoviesViewController.h
//  Subtitles
//
//  Created by Dan Walker on 22/03/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubtitleViewController.h";
#import "SubtitleService.h"
#import "LoadingView.h"

@interface SavedMoviesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	SubtitleService* subtitleService;
	SubtitleViewController* subtitleViewController;
	LoadingView* loadingView;
	IBOutlet UITableView* tableView;	
	IBOutlet UIBarButtonItem* editButton;
	
	UITableViewCell *movieCell;
}

@property (nonatomic,retain) SubtitleService* subtitleService;
@property (nonatomic,retain) LoadingView* loadingView;
@property (nonatomic, assign) IBOutlet UITableViewCell *movieCell;

-(IBAction) onEdit;
	
@end

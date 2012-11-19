//
//  SavedMoviesViewController.m
//  Subtitles
//
//  Created by Dan Walker on 22/03/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "SavedMoviesViewController.h"
#import "Settings.h"
#import "Movie.h"

@interface SavedMoviesViewController(private)
- (void) loadSubtitlesASync: (Movie*)movie;
@end

@implementation SavedMoviesViewController

@synthesize subtitleService; 
@synthesize loadingView; 
@synthesize movieCell;

-(IBAction) onEdit {
	if([tableView isEditing]) {
		editButton.title = NSLocalizedString(@"Edit", nil);
		editButton.style = UIBarButtonItemStylePlain;		
		[tableView setEditing:NO animated: YES];
	} else {		
		editButton.title = NSLocalizedString(@"Done", nil);	
		editButton.style = UIBarButtonItemStyleDone;
		[tableView setEditing:YES animated: YES];		
	}	
}

- (void)tableView:(UITableView *)l_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {	
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		[tableView beginUpdates];
		
		Settings* settings = [Settings instance];
		
		//Delete the download, and the downloaded file.
		int i = ([settings.downloads count] - 1) - indexPath.row;				
		Movie* toDelete = [settings.downloads objectAtIndex:i];		
		[subtitleService deleteDownloadedFile:toDelete];
		[settings.downloads removeObjectAtIndex:i];
		[settings save];
		
		//Remove the subtitle from the table.				
		[l_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		[tableView endUpdates];
	}
}

- (void)viewDidLoad {	
	self.subtitleService = [[SubtitleService alloc]init];	
	editButton.title = @"Edit";
}

- (void)dealloc {
	[subtitleViewController release];
	[subtitleService release];
	[LoadingView release];
	[tableView release];
	[editButton release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
	[tableView reloadData];	
	[tableView scrollsToTop];
}

- (void) loadSubtitlesASync: (Movie*)movie {	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	SubtitleTrack* subtitleTrack = [subtitleService load:movie ForceDownload:NO];			
	[loadingView removeView];
	self.loadingView = nil;		
	if(!subtitleTrack){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Error", nil)
													message:NSLocalizedString(@"Unable load the selected Subtitle file please notify support@structure6.com.", nil)
													delegate:self
													cancelButtonTitle:NSLocalizedString(@"Ok", nil)
													otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {		
		if([subtitleViewController subtitleTrack] != subtitleTrack) {
			if(subtitleViewController) {
				[subtitleViewController release];
				subtitleViewController = nil;		
			} 
			subtitleViewController = [[SubtitleViewController alloc] initWithSubtitleTrack:subtitleTrack];					
		}		
		subtitleViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
		[self presentModalViewController:subtitleViewController animated:YES];			
	}		
	[pool release];
}

#pragma mark UITableViewDatasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	Settings* settings = [Settings instance];	
	if(settings.downloads == nil){
		return 0;
	} else {
		return [settings.downloads count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)l_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MovieTableCell" owner:self options:nil];
        cell = movieCell;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;	
        self.movieCell = nil;
    }
	
	Settings* settings = [Settings instance];
	
	// Assumes we always want the last added to appear at the top.
	Movie* movie = [settings.downloads objectAtIndex:([settings.downloads count] - 1) - indexPath.row];
	
	((UIImageView*)[cell viewWithTag:1]).image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", movie.lang]];
	
	if(movie.hearingImpaired){
		((UIImageView*)[cell viewWithTag:2]).hidden = NO;
		((UILabel*)[cell viewWithTag:3]).hidden = NO;
		((UILabel*)[cell viewWithTag:3]).text = [NSString stringWithFormat:@"%@ (%@)", movie.name, movie.year];
		((UILabel*)[cell viewWithTag:4]).hidden = YES;		
	} else {
		((UIImageView*)[cell viewWithTag:2]).hidden = YES;
		((UILabel*)[cell viewWithTag:3]).hidden = YES;
		((UILabel*)[cell viewWithTag:4]).text = [NSString stringWithFormat:@"%@ (%@)", movie.name, movie.year];
		((UILabel*)[cell viewWithTag:4]).hidden = NO;
	}

	return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	NSString* message = NSLocalizedString(@"Loading Subtitles", nil);	
	self.loadingView = [LoadingView loadingModalInView:self.view WithMessage:message];	
	Settings* settings = [Settings instance];
	Movie* movie = [settings.downloads objectAtIndex:([settings.downloads count] - 1) - indexPath.row];
	[NSThread detachNewThreadSelector:@selector(loadSubtitlesASync:) toTarget:self withObject:movie];	
}

@end

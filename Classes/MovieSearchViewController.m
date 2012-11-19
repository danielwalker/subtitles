//
//  MovieSearchViewController.m
//  subtitles
//
//  Created by Dan Walker on 31/01/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "MovieSearchViewController.h"

@interface MovieSearchViewController(private)
-(void) search: (NSString*) searchString;
-(void) searchASync: (NSString*) searchString;
- (void) loadSubtitlesASync: (Movie*)movie;
@end

@implementation MovieSearchViewController

@synthesize subtitleSearchService; 
@synthesize subtitleService; 
@synthesize loadingView; 
@synthesize movieCell;

- (void)viewDidLoad {	
	
	self.subtitleSearchService = [[SubtitleSearchService alloc]init];
	self.subtitleService = [[SubtitleService alloc]init];
	currentResults = [[NSMutableArray alloc]init];	
	searchBar.placeholder = NSLocalizedString(@"Search for a Movie", nil);		
	
	#ifdef TEST_SUBTITLE_VIEW
		Movie* m = [[Movie alloc] init];
		[NSThread detachNewThreadSelector:@selector(loadSubtitlesASync:) toTarget:self withObject:m];			
	#endif	
}

- (void)dealloc {
	[subtitleViewController release];
	[searchBar release];
	[table release];
	
	[currentResults release];
	[subtitleSearchService release];
	[subtitleService release];
	[LoadingView release];
    [super dealloc];
}

#pragma mark private

-(void) search: (NSString*) searchString {
	NSString* message = NSLocalizedString(@"Searching for Movies", nil);
	self.loadingView = [LoadingView loadingViewInView:table WithMessage:message];		
	self.view.userInteractionEnabled = NO;
	[NSThread detachNewThreadSelector:@selector(searchASync:) toTarget:self withObject:searchString];
}

-(void) searchASync: (NSString*) searchString {			
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray* movieResults = [subtitleSearchService search:searchString];
	if(movieResults != nil) {	
		[currentResults removeAllObjects];
		[currentResults addObjectsFromArray:movieResults];	

		//Sort by year.
		NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"year" ascending:NO] autorelease];	
		[currentResults sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];	
										
		if([currentResults count] == 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"No Results Found", nil)
													  message:NSLocalizedString(@"We didn't find any movies that match your search. You can request subtitles at www.opensubtitles.org.", nil)
													  delegate:self
													  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
													  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	
	//Redisplay.
	[table reloadData];		
	self.view.userInteractionEnabled = YES;
	[self.loadingView removeView];
	self.loadingView = nil;
	
	
	[pool release];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)l_searchBar {			
	[l_searchBar resignFirstResponder];
	[self search: [l_searchBar text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)l_searchBar {
	[l_searchBar resignFirstResponder];
}

#pragma mark UITableViewDatasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [currentResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MovieTableCell" owner:self options:nil];
        cell = movieCell;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;	
        self.movieCell = nil;
    }
	
	Movie* movie = [currentResults objectAtIndex:[indexPath row]];	
	((UIImageView*)[cell viewWithTag:1]).image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", movie.lang]];
	
	if(movie.hearingImpaired){
		((UIImageView*)[cell viewWithTag:2]).hidden = NO;
		((UILabel*)[cell viewWithTag:3]).hidden = NO;
		((UILabel*)[cell viewWithTag:3]).text = [NSString stringWithFormat:@"%@ (%@)", movie.name, movie.year, movie.imdbId];
		((UILabel*)[cell viewWithTag:4]).hidden = YES;		
	} else {
		((UIImageView*)[cell viewWithTag:2]).hidden = YES;
		((UILabel*)[cell viewWithTag:3]).hidden = YES;
		((UILabel*)[cell viewWithTag:4]).text = [NSString stringWithFormat:@"%@ (%@)", movie.name, movie.year, movie.imdbId];
		((UILabel*)[cell viewWithTag:4]).hidden = NO;
	}
	
	return cell;
}

#pragma mark SubtitleControlDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {		
	NSString* message = NSLocalizedString(@"Downloading Subtitles", nil);	
	self.loadingView = [LoadingView loadingModalInView:self.view WithMessage:message];				
	Movie* movie = [currentResults objectAtIndex:[indexPath row]];
	[NSThread detachNewThreadSelector:@selector(loadSubtitlesASync:) toTarget:self withObject:movie];	
}

- (void) loadSubtitlesASync: (Movie*)movie {	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	SubtitleTrack* subtitleTrack = [subtitleService load:movie ForceDownload:YES];		

	[loadingView removeView];
	self.loadingView = nil;	
	
	if(!subtitleTrack){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Server Error", nil)
												  message:NSLocalizedString(@"Unable to download the selected movie's subtitle file from OpenSubtitles.org, the file may be corrupt. If the problem persists please notify support@structure6.com.", nil)
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

@end

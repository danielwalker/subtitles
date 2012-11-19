//
//  LangSelectViewController.m
//  Subtitles
//
//  Created by Dan Walker on 15/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "LangSelectViewController.h"
#import "Settings.h"

@interface LangSelectViewController(private)
- (void) loadLanguageSettings;
@end


@implementation LangSelectViewController

-(void) initLanguages {
	
	keys = [[NSArray alloc] initWithObjects:					 
							@"eng",
							@"fre",
							@"ger",
							@"jpn",
							@"dut",
							@"ita",
							@"spa",
							@"pob",
							@"por",
							@"dan",
							@"fin",
							@"nor",
							@"swe",
							//@"kor",
							@"chi",
							@"pol",
							@"rus",			
							@"alb",	
							@"ara",
							@"bul",	
							//@"cat",	
							@"cze",	
							 nil];
	
	NSArray* values = [[NSArray alloc] initWithObjects:
									   NSLocalizedString(@"English",nil),
									   NSLocalizedString(@"Français",nil),
									   NSLocalizedString(@"Deutsch",nil),
									   NSLocalizedString(@"日本語",nil),					// Japanese
									   NSLocalizedString(@"Nederlands",nil),			// Dutch
									   NSLocalizedString(@"Italiano",nil),
									   NSLocalizedString(@"Español",nil),
									   NSLocalizedString(@"Português",nil),				// Brazilian
									   NSLocalizedString(@"Português (Portugal)",nil),	// Portuguese
									   NSLocalizedString(@"Dansk",nil),					// Danish				   
									   NSLocalizedString(@"Suomi",nil),					// Finland
									   NSLocalizedString(@"Norsk",nil),					// Norwegian
									   NSLocalizedString(@"Svenska",nil),				// Swedish
									   //NSLocalizedString(@"한국어",nil),					// Korean
									   NSLocalizedString(@"中文",nil),					// Chinese
									   NSLocalizedString(@"Polski",nil),				// Polish					   
									   NSLocalizedString(@"Русский",nil),				// Russian					   
									   
									   NSLocalizedString(@"Albanian",nil),					   
									   NSLocalizedString(@"العربية",nil),					//Arabic
									   NSLocalizedString(@"Български",nil),				//Bulgarian
									   //NSLocalizedString(@"Català",nil),				//Catalan
									   NSLocalizedString(@"Čeština",nil),				//Czech	   
					  
									   /*NSLocalizedString(@"Русский",nil),					   
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),					   
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),					   
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),					   
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),
									   NSLocalizedString(@"Русский",nil),*/					   
									   
									   nil];
	
	languages = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
	[values release];
}

- (void) dealloc {
	[selectedLanguages release];
	[languages release];
	[table release];
	[keys release];
	[super dealloc];
}

- (void)viewDidLoad {	
	selectedLanguages = [[NSMutableArray alloc] init];	
	[self loadLanguageSettings];
	table.delegate = self;
	table.dataSource = self;
	[self initLanguages];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	NSString* key = [keys objectAtIndex:indexPath.row];	
	if([selectedLanguages containsObject:key]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = [languages valueForKey:key];
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", key]];	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString* key = [keys objectAtIndex:indexPath.row];	
	if(cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		[selectedLanguages removeObject:key];
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		[selectedLanguages addObject:key];
	}	
	
	//Save.
	Settings *settings = [Settings instance];
	settings.languages = selectedLanguages;
	[settings save];
}

#pragma mark private

- (void) loadLanguageSettings {
	[selectedLanguages removeAllObjects];
	Settings *settings = [Settings instance];	
	for (NSString* lang in settings.languages) {
		[selectedLanguages addObject: lang];
	}	
	[table reloadData];
}

@end


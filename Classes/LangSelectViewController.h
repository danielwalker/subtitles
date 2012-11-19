//
//  LangSelectViewController.h
//  Subtitles
//
//  Created by Dan Walker on 15/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LangSelectViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	NSDictionary* languages;
	NSMutableArray* selectedLanguages;
	NSArray* keys;	
	IBOutlet UITableView* table;
}
 
@end

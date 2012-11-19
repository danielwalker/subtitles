//
//  HelpViewController.m
//  Subtitles
//
//  Created by Dan Walker on 25/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController

- (void)loadView {
	UIView* view = [[UIView alloc] initWithFrame:CGRectZero];	
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 18, 320, 393)];		
	[scrollView setPagingEnabled:YES];	
	[scrollView setContentSize:CGSizeMake(1600.0, 393.0)];
	[scrollView setShowsHorizontalScrollIndicator:NO];
	scrollView.delegate = self;
	[view addSubview:scrollView];
	
	UIImageView* helpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"manual.png"]];
	[scrollView addSubview:helpImage];	
		
	pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, /*394*/0, 0, 18)];
	pageControl.numberOfPages=5;
	[view addSubview:pageControl];
	
	self.view = view;
	
	[helpImage release];
	[scrollView release];	
	[view release];
	
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = sender.frame.size.width;
    int page = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)dealloc {
	[pageControl release];
    [super dealloc];
}

@end

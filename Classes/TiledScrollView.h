//
//  TiledScrollView.h
//  subtitles
//
//  Created by Dan Walker on 7/02/10.
//  Copyright 2010 Structure6. All rights reserved.
//

@protocol TiledScrollViewDataSource;

@interface TiledScrollView : UIScrollView <UIScrollViewDelegate> {
    id <TiledScrollViewDataSource> dataSource;
    CGSize tileSize;
    UIView *containerView;
    NSMutableSet *reusableTiles;    	
    int resolution;
    int maximumResolution;
    int minimumResolution;
    int firstVisibleRow, firstVisibleColumn, lastVisibleRow, lastVisibleColumn;
}

@property (nonatomic, assign) id <TiledScrollViewDataSource> dataSource;
@property (nonatomic, assign) CGSize tileSize;
@property (nonatomic, readonly) UIView *containerView;
@property (nonatomic, assign) int minimumResolution;
@property (nonatomic, assign) int maximumResolution;

- (UIView *)dequeueReusableTile;  // Used by the delegate to acquire an already allocated tile, in lieu of allocating a new one.
- (void)reloadData;
- (void)reloadDataWithNewContentSize:(CGSize)size;

@end

@protocol TiledScrollViewDataSource <NSObject>

- (UIView *)tiledScrollView:(TiledScrollView *)scrollView tileForRow:(int)row column:(int)column resolution:(int)resolution;
- (void) tiledViewDidScroll;
- (void) tiledViewDidEndScrollingAnimation;

@end
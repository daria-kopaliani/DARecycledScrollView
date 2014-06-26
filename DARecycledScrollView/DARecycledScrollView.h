//
//  DARecycledScrollView.h
//  DARecycledScrollViewDemo
//
//  Created by Daria Kopaliani on 6/21/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DARecycledScrollDirection) {
    DARecycledScrollDirectionHorizontal,
    DARecycledScrollDirectionVertical
};

@class DARecycledScrollView, DARecycledTileView;

@protocol DARecycledScrollViewDataSource <NSObject>

- (NSInteger)numberOfTilesInScrollView:(DARecycledScrollView *)scrollView;
- (void)recycledScrollView:(DARecycledScrollView *)scrollView configureTileView:(DARecycledTileView *)tileView forIndex:(NSUInteger)index;
- (DARecycledTileView *)tileViewForRecycledScrollView:(DARecycledScrollView *)scrollView;
- (CGSize)sizeForTileAtIndex:(NSInteger)index scrollView:(DARecycledScrollView *)scrollView;

@end

@protocol DARecycledScrollViewDelegate <UIScrollViewDelegate>
@optional
- (void)recycledScrollView:(DARecycledScrollView *)scrollView didSelectTileAtIndex:(NSUInteger)index;

@end


@interface DARecycledScrollView : UIScrollView

@property (assign, nonatomic) BOOL infinite;
@property (assign, nonatomic) DARecycledScrollDirection scrollDirection;
@property (weak, nonatomic) IBOutlet id<DARecycledScrollViewDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id<DARecycledScrollViewDelegate> delegate;


- (DARecycledTileView *)dequeueRecycledTileView;
- (void)reloadData;

@end
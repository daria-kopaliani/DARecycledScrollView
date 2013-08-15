//
//  DARecycledScrollView.m
//  DARecycledScrollViewDemo
//
//  Created by Daria Kopaliani on 6/21/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DARecycledScrollView.h"

#import "DARecycledTileView.h"


@interface DARecycledScrollView ()

@property (strong, nonatomic) NSMutableSet *visibleTileViews;
@property (strong, nonatomic) NSMutableSet *recycledTileViews;

- (DARecycledTileView *)visibleTileViewForIndex:(NSUInteger)index;

@end


@implementation DARecycledScrollView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.visibleTileViews = [NSMutableSet set];
	self.recycledTileViews = [NSMutableSet set];
}

#pragma mark - Public

- (DARecycledTileView *)dequeueRecycledTileView
{
    DARecycledTileView *tileView = [self.recycledTileViews anyObject];
    if (tileView) {
        [self.recycledTileViews removeObject:tileView];
    }
    return tileView;
}

- (void)reloadData
{
	self.contentSize = [self contentSize];
	[self tileViews];
	if ([self tilesCount]) {
        for (DARecycledTileView *tileView in self.visibleTileViews) {
            NSUInteger index = tileView.index;
            NSInteger actualIndex = index - floorf((float)index / [self tilesCount]) * [self tilesCount];
            [self.dataSource recycledScrollView:self configureTileView:tileView forIndex:actualIndex];
        }
	} else {
		[self clear];
	}
}

#pragma mark * Overwritten setters

- (void)setInfinite:(BOOL)infinite
{
    if (_infinite != infinite) {
        _infinite = infinite;
        [self clear];
    }
    if (infinite) {
        self.showsHorizontalScrollIndicator = NO;
    }
    [self reloadData];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator
{
    if (!(showsHorizontalScrollIndicator && self.infinite)) {
        [super setShowsHorizontalScrollIndicator:showsHorizontalScrollIndicator];
    }
}

#pragma mark - Private

- (void)clear
{
    [self.recycledTileViews unionSet:self.visibleTileViews];
	for (DARecycledTileView *tileView in self.visibleTileViews) {
		[tileView removeFromSuperview];
	}
	[self.visibleTileViews removeAllObjects];
	self.contentOffset = CGPointZero;
	self.contentSize = self.frame.size;
}

-(void)touchUpInsideTile:(id)sender{
    if(self.delegate){
        DARecycledTileView *tile = sender;
        [self.delegate recycledScrollView:self didSelectRowAtIndex:tile.index];
    }
}

- (void)configureTileView:(DARecycledTileView *)tileView forIndex:(NSUInteger)index
{
    CGFloat width = [self widthForTileAtIndex:index];
	CGRect tileViewFrame = CGRectMake(0., 0., width, self.frame.size.height);
    tileViewFrame.origin.x = [self combinedWidthForTilesUntilIndex:index];
    tileViewFrame.size.width = width;
    tileView.frame = tileViewFrame;
    [tileView addTarget:self action:@selector(touchUpInsideTile:) forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)isDisplayingTileForIndex:(NSUInteger)index
{
    for (DARecycledTileView *tileView in self.visibleTileViews) {
        if (tileView.index == index) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)tilesCount
{
    return [self.dataSource numberOfTilesInScrollView:self];
}

- (void)tileViews
{
    CGRect visibleBounds = self.bounds;
    NSInteger firstNeededTileIndex = 0;
    CGFloat width = [self widthForTileAtIndex:firstNeededTileIndex];
    
    while (width < CGRectGetMinX(visibleBounds)) {
        firstNeededTileIndex++;
        width += [self widthForTileAtIndex:firstNeededTileIndex];
    }
    
    NSInteger lastNeededTileIndex = firstNeededTileIndex;
    while (width <= CGRectGetMaxX(visibleBounds)) {
        lastNeededTileIndex++;
        width += [self widthForTileAtIndex:lastNeededTileIndex];
    }
    if (!self.clipsToBounds) {
        firstNeededTileIndex--;
        lastNeededTileIndex++;
    }
    firstNeededTileIndex = MAX(firstNeededTileIndex, 0);
    if (!self.infinite) {
        lastNeededTileIndex = MIN(lastNeededTileIndex, [self tilesCount] - 1);
    } else {
        CGFloat actualWidth = [self combinedWidthForTilesUntilIndex:lastNeededTileIndex + 1];
        while (actualWidth < CGRectGetMaxX(visibleBounds)) {
            lastNeededTileIndex += [self tilesCount];
            actualWidth = [self combinedWidthForTilesUntilIndex:lastNeededTileIndex + 1];
        }
    }
    for (DARecycledTileView *tileView in self.visibleTileViews) {
        if (tileView.index < firstNeededTileIndex || tileView.index > lastNeededTileIndex) {
            [self.recycledTileViews addObject:tileView];
            [tileView removeFromSuperview];
        }
    }
    [self.visibleTileViews minusSet:self.recycledTileViews];
	if ([self tilesCount] == 0) {
		return;
	}

    for (NSUInteger index = firstNeededTileIndex; index <= lastNeededTileIndex; index++) {
        NSInteger page = floorf((float)index / (float)[self tilesCount]);
        NSInteger actualIndex = (index < [self tilesCount]) ? index : index - page * [self tilesCount];
        if (![self isDisplayingTileForIndex:index]) {
            DARecycledTileView *tileView = [self.dataSource tileViewForRecycledScrollView:self];
            tileView.index = index;
            [self configureTileView:tileView forIndex:index];
            [self insertSubview:tileView atIndex:0];            
            [self.visibleTileViews addObject:tileView];
            [self.dataSource recycledScrollView:self configureTileView:tileView forIndex:actualIndex];
        } else {
            DARecycledTileView *tileView = [self visibleTileViewForIndex:index];
            [self configureTileView:tileView forIndex:index];
        }
    }
}

- (CGFloat)combinedWidthForTilesUntilIndex:(NSInteger)index
{
    CGFloat width = 0.;
    for (NSInteger i = 0; i < index; i++) {
        width += [self widthForTileAtIndex:i];
    }
    return width;
}

- (CGFloat)widthForTileAtIndex:(NSInteger)index
{
    NSInteger page = floorf((float)index / (float)[self tilesCount]);
    NSInteger actualIndex = (index < [self tilesCount]) ? index : index - page * [self tilesCount];
    return [self.dataSource widthForTileAtIndex:actualIndex scrollView:self];
}

- (DARecycledTileView *)visibleTileViewForIndex:(NSUInteger)index
{
    for (DARecycledTileView *tileView in self.visibleTileViews) {
        if (tileView.index == index) {
            return tileView;
        }
    }
    return nil;
}

#pragma mark - Overwritten methods

- (CGSize)contentSize
{
    if (self.infinite) {
        return CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame));
    }
    return CGSizeMake([self combinedWidthForTilesUntilIndex:[self tilesCount]], self.frame.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat contentWidth = self.contentSize.width;
    if (self.infinite && self.contentOffset.x > contentWidth && !self.decelerating && !self.dragging) {
        CGFloat x = floorf(self.contentOffset.x / contentWidth) * contentWidth;
        [self setContentOffset:CGPointMake(self.contentOffset.x - x, self.contentOffset.y) animated:NO];
    }
    [self tileViews];
}

@end
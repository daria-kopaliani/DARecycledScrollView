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

- (void)setInfinte:(BOOL)infinte
{
    if (_infinte != infinte) {
        [self clear];
    }
    _infinte = infinte;
    if (infinte) {
        self.showsHorizontalScrollIndicator = NO;
    }
    [self reloadData];
}

- (void)setShowsHorizontalScrollIndicator:(BOOL)showsHorizontalScrollIndicator
{
    if (!(showsHorizontalScrollIndicator && self.infinte)) {
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

- (void)configureTileView:(DARecycledTileView *)tileView forIndex:(NSUInteger)index
{
	CGRect tileViewFrame = CGRectMake(0., 0., [self tileWidth], self.frame.size.height);
    CGFloat width = [self tileWidth];
	CGFloat offset = 0;
    tileViewFrame.origin.x = offset + index * width;
    tileViewFrame.size.width = width;
    tileView.frame = tileViewFrame;
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
    CGFloat tileWidth = [self tileWidth];
	CGFloat offset = 0.;
    int firstNeededTileIndex = floorf((CGRectGetMinX(visibleBounds) - offset) / tileWidth);
    NSInteger lastNeededTileIndex = floorf((CGRectGetMaxX(visibleBounds)) / tileWidth);
    if (!self.clipsToBounds) {
        firstNeededTileIndex--;
        lastNeededTileIndex++;
    }
    firstNeededTileIndex = MAX(firstNeededTileIndex, 0);
    if (!self.infinte) {
        lastNeededTileIndex = MIN(lastNeededTileIndex, [self tilesCount] - 1);
    } else {
        if (lastNeededTileIndex * self.tileWidth < CGRectGetWidth(self.frame)) {
            lastNeededTileIndex = ceilf(CGRectGetWidth(self.frame) / self.tileWidth);
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
        NSInteger actualIndex = index - floorf((float)index / [self tilesCount]) * [self tilesCount];
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

- (CGFloat)tileWidth
{
    return [self.dataSource widthForTileInScrollView:self];
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
    if (self.infinte) {
        return CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame));
    }
    return CGSizeMake([self tilesCount] * [self tileWidth], self.frame.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.infinte && self.contentOffset.x > [self tilesCount] * [self tileWidth] && !self.decelerating && !self.dragging) {
        CGFloat x = floorf(self.contentOffset.x / (self.tilesCount * self.tileWidth)) * self.tilesCount * self.tileWidth;
        [self setContentOffset:CGPointMake(self.contentOffset.x - x, self.contentOffset.y) animated:NO];
    }
    [self tileViews];
}

@end
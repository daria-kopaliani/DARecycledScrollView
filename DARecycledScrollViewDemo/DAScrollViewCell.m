//
//  DAScrollViewCell.m
//  DARecycledScrollViewDemo
//
//  Created by Daria Kopaliani on 6/21/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAScrollViewCell.h"

#import "DAImageTileView.h"
#import "DARecycledScrollView.h"


@interface DAScrollViewCell () <DARecycledScrollViewDataSource>

@property (strong, nonatomic) IBOutlet DARecycledScrollView *scrollView;

@end


@implementation DAScrollViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.scrollView.dataSource = self;
}

- (void)setImages:(NSArray *)images
{
    if (_images != images) {
        _images = images;
        [self.scrollView reloadData];
    }
}

#pragma mark - DARecycledScrollView dataSource

- (NSInteger)numberOfTilesInScrollView:(DARecycledScrollView *)scrollView
{
    return self.images.count;
}

- (void)recycledScrollView:(DARecycledScrollView *)scrollView configureTileView:(DARecycledTileView *)tileView forIndex:(NSUInteger)index
{
    [(DAImageTileView *)tileView setImage:self.images[index]];
}

- (DARecycledTileView *)tileViewForRecycledScrollView:(DARecycledScrollView *)scrollView
{
    DAImageTileView *tileView = (DAImageTileView *)[scrollView dequeueRecycledTileView];
    if (!tileView) {
        tileView = [[DAImageTileView alloc] initWithFrame:CGRectMake(0., 0., 100., CGRectGetHeight(scrollView.frame))];
        tileView.displayRecycledIndex = YES;
    }
    return tileView;
}

- (CGFloat)widthForTileAtIndex:(NSInteger)index scrollView:(DARecycledScrollView *)scrollView
{
    UIImage *image = self.images[index];
    return image.size.width;
}

@end
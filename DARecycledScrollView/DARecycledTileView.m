//
//  DARecycledTileView.m
//  DARecycledScrollViewDemo
//
//  Created by Daria Kopaliani on 6/21/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DARecycledTileView.h"


@interface DARecycledTileView ()

@property (strong, nonatomic) UILabel *countLabel;

@end


@implementation DARecycledTileView

static NSUInteger DARecycledTileViewCount = 0;

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.displayRecycledIndex) {
        if (!_countLabel) {
            DARecycledTileViewCount++;
            self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 30., 30.)];
            self.countLabel.textAlignment = NSTextAlignmentCenter;
            self.countLabel.backgroundColor = [UIColor clearColor];
            self.countLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.6];
            self.countLabel.shadowColor = [UIColor whiteColor];
            self.countLabel.shadowOffset = CGSizeMake(1., 1.);
            self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)DARecycledTileViewCount];
            [self addSubview:self.countLabel];
        }
        [self bringSubviewToFront:self.countLabel];
    }
}

#pragma mark - Public

- (void)setIndex:(NSUInteger)index
{
    _index = index;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Recycled index: %lu, %@", (unsigned long)self.index, [super description]];
}

@end
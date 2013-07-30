//
//  DAViewController.m
//  DARecycledScrollViewDemo
//
//  Created by Daria Kopaliani on 6/21/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAViewController.h"

#import "DARecycledScrollView.h"
#import "DAScrollViewCell.h"


@interface DAViewController ()

@property (strong, nonatomic) DARecycledScrollView *scrollView;

@end


@implementation DAViewController

static NSString *ScrollViewCellIdentifier = @"scrollViewCell";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.tableView reloadData];    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAScrollViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ScrollViewCellIdentifier];
    switch (indexPath.section) {
        case 0: {
            cell.images = @[[UIImage imageNamed:@"dog0.jpg"], [UIImage imageNamed:@"dog1.jpg"], [UIImage imageNamed:@"dog2.jpg"],
                            [UIImage imageNamed:@"dog3.jpg"], [UIImage imageNamed:@"dog4.jpg"], [UIImage imageNamed:@"dog5.jpg"],
                            [UIImage imageNamed:@"dog6.jpg"], [UIImage imageNamed:@"dog7.jpg"]];
        } break;
        case 1: {
            cell.images = @[[UIImage imageNamed:@"cat5.jpg"], [UIImage imageNamed:@"cat6.jpg"], [UIImage imageNamed:@"cat0.jpg"],
                            [UIImage imageNamed:@"cat4.jpg"], [UIImage imageNamed:@"cat7.jpg"], [UIImage imageNamed:@"cat2.jpg"],
                            [UIImage imageNamed:@"cat1.jpg"]];
            cell.scrollView.pagingEnabled = YES;
            cell.scrollView.showsHorizontalScrollIndicator = NO;
        } break;
        case 2: {
            cell.images = @[[UIImage imageNamed:@"beaver.jpg"]];
            cell.scrollView.infinite = YES;
        }
        default: break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 2) ? 230. : 160.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [self headerViewWithText:@"Dogs"];
        case 1: return [self headerViewWithText:@"Cats, paging enabled"];
        case 2: return [self headerViewWithText:@"Beavers, infinite scrolling"];
    }
    return nil;
}

- (UIView *)headerViewWithText:(NSString *)text
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 320., 40.)];
    view.backgroundColor = [UIColor darkGrayColor];
    view.alpha = 0.7;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10., 0., 300., 40.)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.font = [UIFont fontWithName:@"Helvetica-Light" size:20.];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 38.;
}

@end
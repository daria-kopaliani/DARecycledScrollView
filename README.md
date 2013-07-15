DARecycledScrollView
====================

A UIScrollView subclass that reuses its tile views very much like UITableView does: there is a dataSource object which is used to configure scroll view subviews.


![Alt text](DARecycledScrollView.gif)

Features
==============

- All your tile views are reused behind the scenes,
- Infinite scrolling has never been easier - there is a boolean flag 'infinite',
- Subviews layout is updated nicely after user interface rotations.


Installation
==============

Just drag&drop DARecycledScrollView and DARecycledTileView classes in your project
(Cocoa pod is coming)


Usage
==============

DARecycledScrollView is a direct subclass of UIScrollView, the only difference is that it also has a datasource object. Here is an example:

    - (NSInteger)numberOfTilesInScrollView:(DARecycledScrollView *)scrollView
    {
        return 10;
    }

    - (void)recycledScrollView:(DARecycledScrollView *)scrollView configureTileView:(DARecycledTileView *)tileView forIndex:(NSUInteger)index
    {
        // configure your tile view
    }

    - (DARecycledTileView *)tileViewForRecycledScrollView:(DARecycledScrollView *)scrollView
    {
        DARecycledTileView *tileView = [scrollView dequeueRecycledTileView];
        if (!tileView) {
            tileView = [[DARecycledTileView alloc] initWithFrame:CGRectMake(0., 0., 100., 100.)];
        }
        return tileView;
    }

    - (CGFloat)widthForTileInScrollView:(DARecycledScrollView *)scrollView
    {
        return 100.;
    }



TODO
==============

- Support tile views of different height and width,
- Add editing animations for removing, inserting, reordering tile views.

(If someone really needs this, let me know)

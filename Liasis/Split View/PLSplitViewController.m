/**
 * \file PLSplitViewController.m
 * \brief Liasis Python IDE split view controller.
 *
 * \details Controls the split view of the main application window. Currently,
 *          this includes a file browser (sidebar) on the left side and the tab
 *          view on right with extended control over the sidebar width.
 *
 * \copyright Copyright (C) 2012-2014 Jason Lomnitz and Danny Nicklas.
 *
 * This file is part of the Python Liasis IDE.
 *
 * The Python Liasis IDE is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Python Liasis IDE is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Python Liasis IDE. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import "PLSplitViewController.h"

@implementation PLSplitViewController

#pragma mark - Object Lifecycle

-(id)initWithSidebarView:(NSView *)sidebarView
{
        self = [super init];
        if (self) {
                sidebarSplitView = [[NSSplitView alloc] init];
                [self setView:sidebarSplitView];
                [sidebarSplitView setDelegate:self];
                [sidebarSplitView setVertical:YES];
                [sidebarSplitView setDividerStyle:NSSplitViewDividerStyleThin];
                
                _minimumSidebarRelativeWidth = 0.0;
                _minimumSidebarAbsoluteWidth = CGFLOAT_MIN;
                _maximumSidebarRelativeWidth = 1.0;
                _maximumSidebarAbsoluteWidth = CGFLOAT_MAX;
                
                _sidebarView = [sidebarView retain];
                [sidebarSplitView setFrame:[_sidebarView frame]];
                [sidebarSplitView addSubview:_sidebarView];
        }
        return self;
}

/**
 * \brief Remove the sidebar from the superview and release instance variables.
 */
-(void)dealloc
{
        [_sidebarView removeFromSuperview];
        [_sidebarView release];
        [sidebarSplitView release];
        [super dealloc];
}

#pragma mark - Delegate Methods

/**
 * \brief Prevent resizing sidebar view unless breaking its min or max width.
 *
 * \details This method checks `minimumSidebarWidthInSplitView:` and
 *          `maximumSidebarWidthInSplitView:` before allowing the sidebar to
 *          resize. Only returns YES if breaking one of these values.
 *
 * \param splitView The split view adjusting its size.
 *
 * \param view The view whose size will be adjusted.
 *
 * \return YES if `view` should be resized.
 */
-(BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
        BOOL shouldAdjust = YES;
        
        if (view == [[splitView subviews] objectAtIndex:0]) {
                if ([view frame].size.width < [self minimumSidebarWidthInSplitView:splitView] ||
                    [view frame].size.width > [self maximumSidebarWidthInSplitView:splitView]) {
                        shouldAdjust = YES;
                } else {
                        shouldAdjust = NO;
                }
        }
        
        return shouldAdjust;
}

/**
 * \brief A delegate method called to determine the split view divider position.
 *
 * \details Return the maximum position of the split view divider as determined
 *          by maximumSidebarWidthInSplitView.
 *
 * \param splitView The split view.
 *
 * \param proposedMaximumPosition The proposed maximum divider position.
 *
 * \param dividerIndex The index of the divider with the changing position.
 *
 * \return The maximum divider position.
 *
 * \see maximumSidebarWidthInSplitView.
 */
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
        CGFloat maximumPosition = 0.0;
        if (dividerIndex == 0) {
                maximumPosition = [self maximumSidebarWidthInSplitView:splitView];
        } else {
                maximumPosition = proposedMaximumPosition;
        }
        return maximumPosition;
}

/**
 * \brief A delegate method called to determine the split view divider position.
 *
 * \details Return the minimum position of the split view divider as determined
 *          by minimumSidebarWidthInSplitView.
 *
 * \param splitView The split view.
 *
 * \param proposedMinimumPosition The proposed maximum divider position.
 *
 * \param dividerIndex The index of the divider with the changing position.
 *
 * \return The minimum divider position.
 *
 * \see minimumSidebarWidthInSplitView.
 */
-(CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
        CGFloat minimumPosition = 0.0;
        if (dividerIndex == 0) {
                minimumPosition = [self minimumSidebarWidthInSplitView:splitView];
        } else {
                minimumPosition = proposedMinimumPosition;
        }
        return minimumPosition;
}

/**
 * \brief Return the minimum sidebar width for a split view.
 *
 * \details The minimum sidebar width is the maximum of the absolute minimum
 *          (\see minimumSidebarAbsoluteWidth) and the relative minimum
 *          (\see minimumSidebarRelativeWidth) times the split view's frame
 *          width.
 *
 * \param splitView The split view.
 *
 * \return The minimum sidebar width.
 */
-(CGFloat)minimumSidebarWidthInSplitView:(NSSplitView *)splitView
{
        return MAX([self minimumSidebarAbsoluteWidth], [splitView frame].size.width * [self minimumSidebarRelativeWidth]);
}

/**
 * \brief Return the maximum sidebar width for a split view.
 *
 * \details The maximum sidebar width is the maximum of the absolute maximum
 *          (\see minimumSidebarAbsoluteWidth) and the relative maximum
 *          (\see minimumSidebarRelativeWidth) times the split view's frame
 *          width.
 *
 * \param splitView The split view.
 *
 * \return The maximum sidebar width.
 */
-(CGFloat)maximumSidebarWidthInSplitView:(NSSplitView *)splitView
{
        return MIN([self maximumSidebarAbsoluteWidth], [splitView frame].size.width * [self maximumSidebarRelativeWidth]);
}

/**
 * \brief Allow collapsing the sidebar.
 *
 * \param splitView The split view.
 *
 * \param subview The view to be collapsed.
 *
 * \return YES if `subview` is the sidebar (the split view's subview at
 *         index 0).
 */
-(BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
        return subview == [[splitView subviews] objectAtIndex:0];
}

/**
 * \brief Allow collapsing the sidebar with a double click.
 *
 * \param splitView The split view.
 *
 * \param subview The view to be collapsed.
 *
 * \param dividerIndex The divider index to collapse.
 *
 * \return YES if `splitView:canCollapseSubview:` returns YES.
 *
 * \see splitView:canCollapseSubview:
 */
-(BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
        return [self splitView:splitView canCollapseSubview:subview];
}

@end

/**
 * \file PLSplitViewController.h
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

#import <Cocoa/Cocoa.h>

/**
 * \class PLSplitViewController \headerfile \headerfile
 * \brief Controls a NSSplitView with a sidebar on the left and primary view on
 *        the right.
 *
 * \details The conroller provides the means to control the width of the sidebar
 *          on window resize. The sidebar can have an absolute min and max
 *          width, in which its width is fixed upon window resizing. In
 *          addition, it can have a min and max width relative to the window
 *          width, in which the split view divider is automatically moved upon
 *          window resize to enforce these values. Both types of constraints may
 *          be in place simultaneously as well, where the inner bounds will be
 *          enforced (e.g. the maximum of the two minimum values for a given
 *          window width).
 */
@interface PLSplitViewController : NSViewController <NSSplitViewDelegate>
{
        /**
         * \details The split view that this object controls.
         */
        NSSplitView * sidebarSplitView;
}

/**
 * \details The sidebar on the left side of the split view.
 */
@property (retain, readonly) NSView * sidebarView;

/**
 * \details The minimum sidebar width relative to the split view's frame.
 */
@property CGFloat minimumSidebarRelativeWidth;

/**
 * \details The maximum sidebar width relative to the split view's frame.
 */
@property CGFloat maximumSidebarRelativeWidth;

/**
 * \details The minimum absolute sidebar width.
 */
@property CGFloat minimumSidebarAbsoluteWidth;

/**
 * \details The maximum absolute sidebar width.
 */
@property CGFloat maximumSidebarAbsoluteWidth;

/**
 * \brief Initialize a split view controller with a sidebar view.
 *
 * \details Initializes a split view instance variable and sets the delegate as
 *          the controller. Set and retain its sidebar (the left view). Set the
 *          divider as vertical with a thin divider. Set the relative minimum
 *          and maximum sidebar width to 0 and 1, respectively. Set the absolute
 *          minimum and maximum sidebar width to the minimum and maximum CGFloat
 *          values.
 *
 * \param sidebarView The left view in the split view. This view is retained by
 *                    the view controller.
 *
 * \return The instantiated split view controller.
 */
-(id)initWithSidebarView:(NSView *)sidebarView;

@end

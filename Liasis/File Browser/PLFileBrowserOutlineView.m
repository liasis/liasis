/**
 * \file PLOutlineView.m
 * \brief Subclass of NSOutlineView
 *
 * \details This class subclasses the NSOutlineView to provide better control
 *          over displaying entries in the file browser.
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

#import "PLFileBrowserOutlineView.h"

@implementation PLFileBrowserOutlineView

/**
 * \brief Delegate method for highlighting selections in the outline view.
 *
 * \details This method highlights the rect of the selected item in the outline
 *          view. It specifies a gradient based on the color returned from a
 *          PLThemeManager to highlight the selection. Highlighting only occurs
 *          if the outline view is in focus.
 */
-(void)highlightSelectionInClipRect:(NSRect)clipRect
{
        NSInteger selectedRowIndex = [self selectedRow];
        
        if (selectedRowIndex < 0)
                return;
        
        if ([self isInFocus]) {
                NSRect aRowRect = NSInsetRect([self rectOfRow:selectedRowIndex], 1, 1);
                NSGradient * gradient = [[PLThemeManager defaultThemeManager] selectionGradient];
                [gradient drawInRect:aRowRect angle:90];
        }
}

-(BOOL)isInFocus
{
        return [[self window] firstResponder] == self && [[self window] isMainWindow] && [[self window] isKeyWindow];
}

@end

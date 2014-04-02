/**
 * \file PLFileBrowserMainView.h
 * \brief Liasis Python IDE file browser view.
 *
 * \details This is the main view for the file browser. It sends key equivalents
 *          to the file browser's view controller and draws its background
 *          color.
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

#import "PLFileBrowserMainView.h"

@implementation PLFileBrowserMainView

/**
 * \brief Set the background color and redraw the view.
 *
 * \details The background color is drawn in `drawRect:` so send the
 *          `setNeedsDisplay:` method to update the color.
 */
-(void)setBackgroundColor:(NSColor *)backgroundColor
{
        [backgroundColor retain];
        [_backgroundColor release];
        _backgroundColor = backgroundColor;
        [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect
{
        [self.backgroundColor set];
        NSRectFill(dirtyRect);
        [super drawRect:dirtyRect];
}

-(BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
        BOOL performEquivalent = NO;
        performEquivalent = [controller performKeyEquivalent:theEvent];
        if (performEquivalent == NO) {
                performEquivalent = [super performKeyEquivalent:theEvent];
        }
        return performEquivalent;
}

@end

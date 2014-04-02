/**
 * \file PLTabBarView.m
 *
 * \brief Liasis Python IDE tab bar view.
 *
 * \details This file includes the tab bar `NSView` subclass and the protocol
 *          for a delegate of the tab bar.
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
 */

#import "PLTabBarView.h"

@implementation PLTabBarView

#pragma mark - Mouse Events

/**
 * \brief Query the delegate if it will handle the mouseDown event.
 *
 * \param theEvent Object encapsulating information about the mouse down event.
 */
-(void)mouseDown:(NSEvent *)theEvent
{
        if ([_delegate shouldPerformMouseDownEvent:theEvent]) {
                [super mouseDown:theEvent];
        }
}

/**
 * \brief Query the delegate if it will handle the mouseDragged event.
 *
 * \param theEvent Object encapsulating information about the mouse dragged
 *                 event.
 */
-(void)mouseDragged:(NSEvent *)theEvent
{
        if ([_delegate shouldPerformMouseDraggedEvent:theEvent]) {
                [super mouseDragged:theEvent];
        }
}

@end

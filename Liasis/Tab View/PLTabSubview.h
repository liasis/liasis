/**
 * \file PLTabView.h
 * \brief Liasis Python IDE tab subview.
 *
 * \details A NSView subclass implemented to add a background color for tab
 *          subviews and send key equivalents to its delegate.
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

@interface PLTabSubview : NSView

/**
 * \brief The view's delegate.
 *
 * \details This object subclasses the performKeyEquivalent: method and sends it
 *          to its delegate before calling the superclass method.
 */
@property (assign) id delegate;

/**
 * \brief The background color.
 */
@property (retain) NSColor * backgroundColor;

@end

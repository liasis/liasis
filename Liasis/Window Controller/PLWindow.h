/**
 * \file PLWindow.m
 * \brief Liasis Python IDE main application window.
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

#import <Cocoa/Cocoa.h>

/**
 * \class PLWindow \headerfile \headerfile
 * \brief A `NSWindow` subclass that forwards first responder status to its
 *        delegate.
 *
 * \details This is primarily used in conjunction with the same method in
 *          `PLWindowController` to ensure that the tab view controller becomes
 *          first responder if the window does, which occurs in some
 *          application-launch scenarios.
 *
 * \see PLWindowController
 */
@interface PLWindow : NSWindow

@end

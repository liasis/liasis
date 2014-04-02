/**
 * \file PLOutlineView.h
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

#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>

/**
 * \class PLOutlineView \headerfile \headerfile
 * \brief Subclass of NSOutlineView.
 *
 * \details This is a subclass of the NSOutlineView, used to better control
 *          highlighting entries in an outline view and react to loss of focus.
 */
@interface PLFileBrowserOutlineView : NSOutlineView

/**
 * \brief Determine if the view is in focus.
 *
 * \details This method checks if the window is the first responder, is the main
 *          window, and is the key window. Therefore, after any event that
 *          causes the view not to be the focused element will cause this method
 *          to return NO.
 *
 * \return A boolean specifying if the view is in focus.
 */
-(BOOL)isInFocus;

@end

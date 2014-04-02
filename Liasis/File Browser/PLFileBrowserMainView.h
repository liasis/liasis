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

#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>

@interface PLFileBrowserMainView : NSView
{
        IBOutlet NSViewController * controller;
}

@property (nonatomic, retain) NSColor * backgroundColor;

@end

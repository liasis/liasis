/**
 * \file PLFileBrowserImageAndTextCell.h
 * \brief Liasis Python IDE image and text cell to use with the file browser.
 *
 * \details This file includes a NSTextFieldCell subclass that includes both an
 *          image and text. See the ImangeAndTextCell class in Apple's
 *          SourceView example for an editable implementation that this was
 *          derived from.
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
 * \class PLFileBrowserImageAndTextCell \headerfile \headerfile
 * \brief A NSTextFieldCell subclass to display both an image and text.
 *
 * \details Set the image as normal for `NSCell` (i.e. cell.image or
 *          `setImage:`) and the subclass will display the image on the left and
 *          the text on the right.
 */
@interface PLFileBrowserImageAndTextCell : NSTextFieldCell

/**
 * \brief The image to be displayed alongside the text in the cell.
 *
 * \details This overrides the `image` and `setImage:` methods of `NSCell`,
 *          which does not display the text if an image is set.
 */
@property (retain) NSImage * image;

@end

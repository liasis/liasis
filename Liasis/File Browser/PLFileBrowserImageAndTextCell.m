/**
 * \file PLFileBrowserImageAndTextCell.m
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

#import "PLFileBrowserImageAndTextCell.h"

@implementation PLFileBrowserImageAndTextCell

/**
 * \brief When copying, the new cell retains the cell's image.
 *
 * \details Without this, only the pointer to the image is copied over.
 *
 * \param zone The area of memory from which to allocate the new instance. See
 *             the superclass documentation.
 *
 * \returns A new instance that is a copy of the receiver.
 */
-(id)copyWithZone:(NSZone *)zone
{
        PLFileBrowserImageAndTextCell * cell = (PLFileBrowserImageAndTextCell *)[super copyWithZone:zone];
        cell.image = [self.image retain];
        return cell;
}

/**
 * \brief Release the image and call the super method.
 */
-(void)dealloc
{
        [_image release];
        [super dealloc];
}

/**
 * \brief Draw the image next to the text.
 *
 * \details If the image as been set, compute its frame and draw the image. Then
 *          call the super method to draw the text.
 */
-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
        NSRect newCellFrame, imageFrame;
        NSSize imageSize;
        CGFloat xShift = 3.0f;
        
        newCellFrame = cellFrame;
        if (self.image) {
                imageSize = [self.image size];
                NSDivideRect(newCellFrame, &imageFrame, &newCellFrame, imageSize.width, NSMinXEdge);
                if ([self drawsBackground]) {
                        [[self backgroundColor] set];
                        NSRectFill(imageFrame);
                }
                newCellFrame.origin.x += xShift + 2.0f;
                imageFrame.origin.x += xShift;
                imageFrame.origin.y += 1.0f;
                imageFrame.size = imageSize;

                [self.image drawInRect:imageFrame
                              fromRect:NSZeroRect
                             operation:NSCompositeSourceOver
                              fraction:1.0
                        respectFlipped:YES
                                 hints:nil];
        }
        [super drawWithFrame:newCellFrame inView:controlView];
}

/**
 * \brief Add the image size to the cell's size with a small spacing buffer.
 */
-(NSSize)cellSize
{
        NSSize cellSize = [super cellSize];
        cellSize.width += (self.image ? [self.image size].width : 0.0f) + 3.0f;
        return cellSize;
}

@end

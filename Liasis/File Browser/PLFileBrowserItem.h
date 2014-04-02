/**
 * \file PLFileBrowserItem.h
 *
 * \brief Liasis Python IDE file browser item.
 *
 * \details This class represents each item in the file browser tree.
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

#import <Foundation/Foundation.h>

/**
 * \class PLFileBrowserItem \headerfile \headerfile
 * \brief A `NSTreeNode` subclass representing an item in the file browser.
 *
 * \details This class represents an item in the file system tree. It overrides
 *          the superclass children methods to return items in the directory.
 *          Its `representedObject` will be the last path component of the full
 *          path, which is exposed as a property.
 */
@interface PLFileBrowserItem : NSTreeNode

/**
 * \brief The full path to the item in the file browser.
 *
 * \details The `representedObject` for the item is the last component of this
 *          path.
 */
@property (retain, readonly) NSString * fullPath;

/**
 * \brief Initialize a tree node.
 *
 * \details This method creates a new tree node whose `representedObject` is
 *          the last path component of `fullPath`. It stores the full path to
 *          this component as the `fullPath` property.
 *
 * \param fullPath The path to the file browser item.
 *
 * \return A `PLFileBrowserItem`.
 */
-(instancetype)initWithRepresentedObject:(NSString *)fullPath;

/**
 * \brief Factory method to create a new tree node.
 *
 * \details This method is only overridden as a notice to use a `NSString`
 *          representing a directory path as the `representedObject`.
 *
 * \param fullPath The path to the file browser item.
 *
 * \return A `PLFileBrowserItem` on the autorelease pool.
 */
+(instancetype)treeNodeWithRepresentedObject:(NSString *)fullPath;

@end

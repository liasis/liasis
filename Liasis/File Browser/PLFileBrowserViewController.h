/**
 * \file PLFileBrowserViewController.h
 * \brief Liasis Python IDE file browser view controller.
 *
 * \details This is a view controller for the file browser, displaying file
 *          system items in an `NSOutlineView`.
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
#import <LiasisKit/LiasisKit.h>
#import "PLFileBrowserItem.h"
#import "PLFileBrowserOutlineView.h"
#import "PLFileBrowserImageAndTextCell.h"
#import "PLFileBrowserMainView.h"

/**
 * \class PLFileBrowserViewController \headerfile \headerfile
 * \brief A `NSViewController` subclass that follows the `NSOutlineViewDelegate`
 *        protocol to control the file browser outline view.
 *
 * \details The view controller manages displaying and interacting with the file
 *          browser outline view. This includes applying its theme, handling
 *          selections in the outline view, and responding to when a user
 *          double clicks items in the file browser. To allow for opening these
 *          files, it exposes an `openDocumentHandler` property.
 */
@interface PLFileBrowserViewController : NSViewController <NSOutlineViewDelegate, PLThemeable>
{
        /**
         * \brief The outline view that displays the file browser tree.
         */
        IBOutlet PLFileBrowserOutlineView * outlineView;
        
        /**
         * \brief The file browser's scroll view.
         */
        IBOutlet NSScrollView * scrollView;
        
        /**
         * \brief The file browser's scroll view.
         */
        IBOutlet NSPopUpButton * directoryPopUpButton;

        /**
         * \brief The tree controller used to manage `outlineView`.
         */
        IBOutlet NSTreeController * treeController;
        
        /**
         * \brief The root directory of the file browser.
         */
        NSString * directoryPath;
        
        /**
         * \brief The menu item used in the directory pop up button to select
         *        a directory not in the list.
         */
        NSMenuItem * otherMenuItem;
}

/**
 * \brief The block that is called when the user requests to open a document
 *        from the file browser.
 *
 * \details If this property is not set, nothing will happen if the user
 *          double clicks an file in the browser.
 */
@property (copy) void (^openDocumentHandler)(NSURL * fileURL);

/**
 * \brief Factory method to create a file browser view controller.
 *
 * \return The instantiated file browser view controller on the autorelease
 *         pool.
 */
+(instancetype)viewController;

@end

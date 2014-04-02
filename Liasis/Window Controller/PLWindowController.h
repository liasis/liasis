/**
 * \file PLWindowController.h
 * \brief Liasis Python IDE window controller.
 *
 * \details This is the controller for the main windows of Liasis.
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
#import "PLTabViewController.h"
#import "PLFileBrowserViewController.h"
#import "PLSplitViewController.h"

/**
 * \class PLWindowController \headerfile \headerfile
 * \brief A `NSWindowController` subclass that manages the main windows
 *        consisting of a file browser and tab view controller, each part of a
 *        split view.
 */
@interface PLWindowController : NSWindowController <NSWindowDelegate, PLThemeable>
{
        /**
         * \brief The split view controller.
         *
         * \details The split view consists of a file browser on the left and
         *          a tab view on the right.
         */
        PLSplitViewController * splitViewController;

        /**
         * \brief The tab view controller.
         */
        PLTabViewController <PLThemeable> * tabViewController;

        /**
         * \brief The file browser view controller.
         */
        PLFileBrowserViewController <PLThemeable> * fileBrowserViewController;
}

/**
 * \brief Create a new window controller.
 *
 * \return A window controller on the autorelease pool.
 */
+(instancetype)windowController;

/**
 * \brief Check if the window controller contains an opened instance of a
 *        document.
 *
 * \param fileURL The URL of the document.
 *
 * \return YES if the window contains a tab with the document.
 */
-(BOOL)containsDocumentWithURL:(NSURL *)fileURL;

#pragma mark - Opening, Closing, and Saving

/**
 * \brief Create a new document using the default tab.
 */
-(void)newDocument;

/**
 * \brief Open a document.
 *
 * \details Uses `PLDocumentManager` to open the document. If the document is
 *          already open and the user requests that tabs contain unique
 *          documents, switch to that tab containing it. Otherwise, open it
 *          with the tab bundle registered for the file type. Presents an
 *          `NSError` if opening was not successful.
 *
 * \param fileURL The file URL to open.
 *
 * \return YES if opening was successful.
 */
-(BOOL)openDocumentWithURL:(NSURL *)fileURL;

/**
 * \brief Save the document of the active tab.
 */
-(void)saveDocument;

/**
 * \brief Save the document of the active tab as a new document.
 */
-(void)saveAsDocument;

/**
 * \brief Close the document of the active tab, closing the window too if it is
 *        the last tab.
 */
-(void)closeDocument;

#pragma mark - Tabs

/**
 * \brief The number of open tabs in the window.
 *
 * \return The number of open tabs in the window.
 */
-(NSUInteger)numberOfTabs;

/**
 * \brief Select the next tab in the tab bar by cycling forward.
 */
-(void)selectNextTab;

/**
 * \brief Select the previous tab in the tab bar by cycling backwards.
 */
-(void)selectPreviousTab;

@end

/**
 * \file LiasisAppDelegate.h
 * \brief Liasis Python IDE Application Delegate.
 *
 * \details Specification of the application delegate, which handles key events
 *          such as application launching and application termination.
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
#import <Python/Python.h>
#import <LiasisKit/LiasisKit.h>
#import "PLWindowController.h"
#import "PLCreditWindowController.h"

/**
 * \class LiasisAppDelegate \headerfile \headerfile
 * \brief Object serving as the application delegate.
 *
 * \details The app delegate class handles key events during application 
 *          launching, execution and termination. The object conforms to the
 *          NSApplicationDelegate protocol, enabling proper application
 *          initialization, such as setting up the tab view and loading
 *          standard extensions, and enabling proper termination, such as 
 *          confirming unsaved changes.
 */
@interface LiasisAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
        /**
         * \brief The font used for the application.
         *
         * \details This font is converted by the shared font manager upon
         *          receiving the changeFont: method.
         */
        NSFont * applicationFont;

        /**
         * \brief An array of all window controllers with open windows.
         */
        NSMutableArray * openWindowControllers;
        
        /**
         * \brief The window controller for the credit window.
         */
        PLCreditWindowController * creditWindowController;
}

@end

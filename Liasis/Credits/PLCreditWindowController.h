/**
 * \file PLCreditWindowController.m
 * \brief Liasis Python IDE credit window controller.
 *
 * \details This file contains the private interface, private implementation,
 *          and public implementation methods for the credit window controller.
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
 * \class PLCreditWindowController \headerfile \headerfile
 * \brief Control a window displaying the application credits.
 *
 * \details The PLCreditWindowController sets up and controls a window
 *          displaying credit information for Liasis, incuding the developers,
 *          license/copyright, and links to development resources. This window
 *          is displayed when selecting About Liasis from the menubar as
 *          controlled by LiasisAppDelegate.
 *
 * \see LiasisAppDelegate
 */
@interface PLCreditWindowController : NSWindowController <NSWindowDelegate>
{
        /**
         * \details The app icon image.
         */
        IBOutlet NSImageView * icon;
        
        /**
         * \details The app version.
         */
        IBOutlet NSTextField * version;
        
        /**
         * \details A button linking to the Liasis homepage.
         */
        IBOutlet NSButton * homepageButton;
        
        /**
         * \details A button linking to the Liasis github page.
         */
        IBOutlet NSButton * sourceCodeButton;
        
        /**
         * \details A button linking to the Liasis sourceforge page.
         */
        IBOutlet NSButton * downloadsButton;
}

/**
 * \brief Factory method for the window controller.
 *
 * \details Return a PLCreditWindowController initialized from the xib file
 *          on the autorelease pool.
 *
 * \return The window controller.
 */
+(id)windowController;

@end

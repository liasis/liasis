/**
 * \file PLCreditWindowController.h
 * \brief Liasis Python IDE credit window controller.
 *
 * \details This file contains the public interface for the credit window
 *          controller.
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

#import "PLCreditWindowController.h"

@implementation PLCreditWindowController

+(id)windowController
{
        return [[[PLCreditWindowController alloc] initWithWindowNibName:@"PLCreditWindowController"] autorelease];
}

/**
 * \brief Initialize the window once it loads from the xib.
 *
 * \details Set the window to only be closable with a title. Set up the app icon
 *          image and the version number text field. Set the properties of all
 *          link buttons to be bordered but only show the border on mouseover.
 */
-(void)windowDidLoad
{
        [super windowDidLoad];
        [[self window] setStyleMask:NSClosableWindowMask|NSTitledWindowMask];
        
        [icon setImage:[NSApp applicationIconImage]];
        [icon setImageFrameStyle:NSImageFrameNone];
        [icon setImageScaling:NSImageScaleProportionallyUpOrDown];
        
        [version setStringValue:[NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
        
        [homepageButton setBordered:YES];
        [homepageButton setShowsBorderOnlyWhileMouseInside:YES];
        [sourceCodeButton setBordered:YES];
        [sourceCodeButton setShowsBorderOnlyWhileMouseInside:YES];
        [downloadsButton setBordered:YES];
        [downloadsButton setShowsBorderOnlyWhileMouseInside:YES];
}

/**
 * \brief IBAction to open the license file.
 *
 * \details Open the license file stored in the application mainBundle.
 *
 * \param sender The action sender.
 *
 * \return An IBAction response.
 */
-(IBAction)openLicense:(id)sender
{
        [[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"LICENSE" ofType:nil]];
}

/**
 * \brief IBAction to open a web link.
 *
 * \details Depending on the sender, open one of three links. The sender is
 *          either the homepageButton, sourceCodeButton, or downloadsButton,
 *          which open the Liasis homepage, github page, or sourceforge page,
 *          respectively.
 *
 * \param sender The action sender.
 *
 * \return An IBAction response.
 */
-(IBAction)openLink:(id)sender
{
        if (sender == homepageButton)
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
        else if (sender == sourceCodeButton)
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/dnicklas/Liasis"]];
        else if (sender == downloadsButton)
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://sourceforge.net/projects/liasis/"]];
}

@end

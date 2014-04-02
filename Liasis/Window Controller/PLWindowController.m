/**
 * \file PLWindowController.m
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

#import "PLWindowController.h"

/* TODO: use constraints for split view and remove min size of window */

@implementation PLWindowController

/**
 * \brief Initialize the window controller.
 *
 * \details Observe the `PLThemeManagerDidChange` notification.
 *
 * \param window The window object to manage.
 *
 * \return The window controller.
 */
-(instancetype)initWithWindow:(NSWindow *)window
{
        self = [super initWithWindow:window];
        if (self) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(updateThemeManager)
                                                             name:PLThemeManagerDidChange
                                                           object:nil];
                [self updateThemeManager];
        }
        return self;
}

+(instancetype)windowController
{
        return [[[self alloc] initWithWindowNibName:@"PLWindowController"] autorelease];
}

/**
 * \brief Release all view controllers.
 */
-(void)dealloc
{
        [tabViewController release];
        [fileBrowserViewController release];
        [splitViewController release];
        [super dealloc];
}

/**
 * \brief Set up the split view, file browser, and tab view.
 */
-(void)windowDidLoad
{
        NSRect fileBrowserViewFrame;
        CGFloat fileBrowserAbsoluteMinimumWidth, fileBrowserRelativeMaximumWidth;

        [super windowDidLoad];

        /* Set up tab view */
        tabViewController = [[PLTabViewController tabViewController] retain];

        /* Set up file browser */
        fileBrowserViewController = [[PLFileBrowserViewController viewController] retain];
        [fileBrowserViewController setOpenDocumentHandler:^(NSURL * fileURL) {
                [self openDocumentWithURL:fileURL];
        }];

        /* Set up split view */
        splitViewController = [[PLSplitViewController alloc] initWithSidebarView:[fileBrowserViewController view]];
        [[self window] setContentView:[splitViewController view]];

        /* Set up split view file browser width */
        fileBrowserAbsoluteMinimumWidth = 180.0;  /* !! should be a function of font width when we have a global font */
        fileBrowserRelativeMaximumWidth = 0.5;
        [splitViewController setMinimumSidebarAbsoluteWidth:fileBrowserAbsoluteMinimumWidth];
        [splitViewController setMaximumSidebarRelativeWidth:fileBrowserRelativeMaximumWidth];
        fileBrowserViewFrame = [[fileBrowserViewController view] frame];
        fileBrowserViewFrame.size.width = fileBrowserAbsoluteMinimumWidth;
        [[fileBrowserViewController view] setFrame:fileBrowserViewFrame];
        [[splitViewController view] addSubview:[tabViewController view]];
}

#pragma mark - Opening and Saving Documents

-(void)newDocument
{
        [tabViewController addDefaultTab];
}

-(BOOL)openDocumentWithURL:(NSURL *)fileURL
{
        PLDocument <PLDocumentSubclass> * document = nil;
        NSBundle * defaultAddOnBundle = [[PLAddOnManager defaultManager] defaultAddOnBundle];
        BOOL successful = YES;
        NSString * fileType = [[fileURL path] pathExtension];
        
        document = [[PLDocumentManager sharedDocumentManager] documentForURL:fileURL];
        if (document == nil) {
                successful = NO;
                [self presentError:[NSError errorWithDomain:PLLiasisErrorDomain
                                                       code:PLErrorCodeModal
                                                   userInfo:@{NSLocalizedDescriptionKey: @"File could not be opened."}]];
                goto exit;
        }

        if ([[NSUserDefaults standardUserDefaults] boolForKey:PLUserDefaultUniqueDocuments] && [tabViewController containsTabWithURL:fileURL]) {
                [tabViewController setTabWithURLActive:fileURL];
        } else if ([[[PLAddOnManager defaultManager] allowedFileTypesForAddOn:defaultAddOnBundle] containsObject:fileType]){
                [tabViewController addTabWithAddOn:defaultAddOnBundle
                                      withDocument:document];
        } else {
                [tabViewController addTabWithAddOn:[[PLAddOnManager defaultManager] defaultAddOnForFileType:fileType]
                                      withDocument:document];
        }
exit:
        return successful;
}

-(void)saveDocument
{
        [tabViewController saveActiveTab];
}

-(void)saveAsDocument
{
        [tabViewController saveAsActiveTab];
}

-(void)closeDocument
{
        if ([tabViewController numberOfTabs] > 1) {
                [tabViewController closeActiveTab];
        } else {
                [[self window] performClose:self];
        }
}

#pragma mark - Tabs

-(NSUInteger)numberOfTabs
{
        return [tabViewController numberOfTabs];
}

-(void)selectNextTab
{
        [tabViewController selectNextTab];
}

-(void)selectPreviousTab
{
        [tabViewController selectPreviousTab];
}

#pragma mark - Themeable

/**
 * \brief Update the themes of both the tab view and file browser view.
 */
-(void)updateThemeManager
{
        [tabViewController updateThemeManager];
        [fileBrowserViewController updateThemeManager];
}

/**
 * \brief Update the font of both the tab view and file browser view, if they
 *        respond to the message.
 *
 * \param font The new font.
 */
-(void)updateFont:(NSFont *)font
{
        if ([tabViewController respondsToSelector:@selector(updateFont:)]) {
                [tabViewController updateFont:font];
        }

        if ([fileBrowserViewController respondsToSelector:@selector(updateFont:)]) {
                [fileBrowserViewController updateFont:font];
        }
}

#pragma mark -

-(BOOL)containsDocumentWithURL:(NSURL *)fileURL
{
        return [tabViewController containsTabWithURL:fileURL];
}

/**
 * \brief Forward first responder status to the tab view controller.
 *
 * \details This is primarily used in conjunction with the same method in
 *          `PLWindow` to ensure that the tab view controller becomes first
 *          responder if the window does, which occurs in some
 *          application-launch scenarios.
 *
 * \return YES if `tabViewController` accepted first responder.
 */
-(BOOL)becomeFirstResponder
{
        return [[self window] makeFirstResponder:tabViewController];
}

/**
 * \brief The window should close if the tab view controller can close all tabs.
 *
 * \param sender The window being closed.
 *
 * \return YES if the window should close.
 */
-(BOOL)windowShouldClose:(id)sender
{
        return [tabViewController shouldCloseAllTabs];
}

@end

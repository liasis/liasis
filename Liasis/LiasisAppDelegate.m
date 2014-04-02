/**
 * \file LiasisAppDelegate.m
 * \brief Liasis Python IDE Application Delegate.
 *
 * \details Implementation of the application delegate, which handles key events
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

#import "LiasisAppDelegate.h"

@implementation LiasisAppDelegate

#pragma mark - Object Lifecycle

/**
 * \brief Release instance variables and end the internal Python interpreter.
 */
-(void)dealloc
{
        [openWindowControllers release];
        [applicationFont release];
        Py_Finalize();
        [super dealloc];
}

/**
 * \brief Initialize the internal Python interpreter.
 */
-(void)awakeFromNib
{
        Py_Initialize();
}

/**
 * \brief Set the application font and load the builtin bundles.
 *
 * \details Windows are launched in `applicationDidFinishLaunching:` or one of
 *          the open file delegate methods.
 *
 * \param aNotification The notification object.
 */
-(void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
        openWindowControllers = [[NSMutableArray alloc] init];
        
        /* Set font */
        applicationFont = [[NSFont fontWithName:@"Menlo" size:14.0f] retain];
        [[NSFontManager sharedFontManager] setSelectedFont:applicationFont
                                                isMultiple:NO];
        [[NSFontManager sharedFontManager] setTarget:self];

        /* Load bundles */
        [[PLAddOnManager defaultManager] loadAddOnNamed:@"Introspector.plugin"];
        [[PLAddOnManager defaultManager] loadAddOnNamed:@"Editor.plugin"];
        [[PLAddOnManager defaultManager] loadAddOnNamed:@"Interpreter.plugin"];
}

/**
 * \brief Launch a window with an empty tab if no windows have been launched and
 *        register user defaults.
 *
 * \details Windows launched by opening a file will already have an open tab so
 *          this method launches a window and adds a tab with an empty document.
 *
 * \param aNotification The notification object.
 */
-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
        if ([[NSApp windows] count] == 0) {
                [self newWindowWithEmptyDocument];
        }
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{PLUserDefaultUniqueDocuments: @NO}];
}

/**
 * \brief Determine if the application should ternminate.
 *
 * \details This method tries to close all windows by sending them the
 *          `performClose:` message. If the window is still visible, cancel the
 *          termination.
 *
 * \param sender The application object that is about to be terminated.
 *
 * \return NSTerminateNow if the application should terminate or
 *         NSTerminateCancel if any window is still visible.
 */
-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
        NSApplicationTerminateReply reply = NSTerminateNow;
        for (NSWindow * window in [NSApp windows]) {
                [window performClose:self];
                if ([window isVisible]) {
                        reply = NSTerminateCancel;
                        break;
                }
        }
        
exit:
        return reply;
}

#pragma mark - Window Management

/**
 * \brief Add a new window controller.
 *
 * \details Observe the `NSWindowWillCloseNotification` for the associated
 *          window, save the controller in `openWindowControllers` and show the
 *          window.
 *
 *          Note that showing the window with the `NSWindowController` method
 *          `showWindow` doesn't cascade the first window with "visible at
 *          launch" unchecked in the xib file so `makeKeyAndOrderFront:` is used
 *          here.
 *
 * \param windowController The window controller to add.
 */
-(void)addWindowController:(NSWindowController *)windowController
{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(windowWillClose:)
                                                     name:NSWindowWillCloseNotification
                                                   object:[windowController window]];
        [openWindowControllers addObject:windowController];
        [[windowController window] makeKeyAndOrderFront:self];
}

/**
 * \brief Stop tracking the associated window controller.
 *
 * \details Remove the window controller from `openWindowControllers` and stop
 *          observing the `NSWindowWillCloseNotification`.
 *
 * \param notification The notification.
 */
-(void)windowWillClose:(NSNotification *)notification
{
        NSWindowController * windowController = [[notification object] windowController];
        if ([openWindowControllers containsObject:windowController]) {
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:NSWindowWillCloseNotification
                                                              object:[windowController window]];
                [openWindowControllers removeObject:windowController];
                if (windowController == creditWindowController) {
                        creditWindowController = nil;
                }
        }
}

/**
 * \brief Create a new window with tab containing an empty document.
 *
 * \details This method creates a new `PLWindowController`, displays it, and
 *          sends it the `newDocument` method.
 */
-(void)newWindowWithEmptyDocument
{
        PLWindowController * windowController = [PLWindowController windowController];
        [windowController window];
        [windowController newDocument];
        [self addWindowController:windowController];
}

/**
 * \brief Create a new window with a tab that opens a file at a URL.
 *
 * \details This methods creates a new `PLWindowController` and sends it the
 *          `openDocumentWithURL:` message.
 *
 * \param fileURL The file URL of the document to open.
 *
 * \return YES if opening the file was successful.
 */
-(BOOL)newWindowWithURL:(NSURL *)fileURL
{
        BOOL successful = NO;
        PLWindowController * windowController = nil;
        
        windowController = [PLWindowController windowController];
        [windowController window];
        successful = [windowController openDocumentWithURL:fileURL];
        [self addWindowController:windowController];
        return successful;
}

/**
 * \brief Create a new window with tab containing an empty document.
 */
-(IBAction)newWindow:(id)sender
{
        [self newWindowWithEmptyDocument];
}

#pragma mark - Opening, Saving, and Closing Files

/**
 * \brief Action to create a new file in the key window.
 *
 * \param sender The object sending the action message.
 */
-(IBAction)newFile:(id)sender
{
        if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                [(PLWindowController *)[[NSApp keyWindow] windowController] newDocument];
        }
}

/**
 * \brief Action to close a file in the key window.
 *
 * \details If the key window's controller is not a `PLWindowController`, send
 *          the window a `performClose:` message. Otherwise, close the active
 *          document in the window.
 *
 * \param sender The object sending the action message.
 */
-(IBAction)closeFile:(id)sender
{
        if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                [(PLWindowController *)[[NSApp keyWindow] windowController] closeDocument];
        } else {
                [[NSApp keyWindow] performClose:self];
        }
}

/**
 * \brief Action to save a file in the key window.
 *
 * \details Does nothing if the key window's controller is not a
 *          `PLWindowController`.
 *
 * \param sender The object sending the action message.
 */
-(IBAction)saveFile:(id)sender
{
        if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                [(PLWindowController *)[[NSApp keyWindow] windowController] saveDocument];
        }
}

/**
 * \brief Action to save a file as a new file in the key window.
 *
 * \details Does nothing if the key window's controller is not a
 *          `PLWindowController`.
 *
 * \param sender The object sending the action message.
 */
-(IBAction)saveAsFile:(id)sender
{
        if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                [(PLWindowController *)[[NSApp keyWindow] windowController] saveAsDocument];
        }
}

/**
 * \brief Action to open a file in the key window.
 *
 * \details Present a modal open panel in the key window and send its controller
 *          the `openDocumentWithURL:` message. Does nothing if the key window's
 *          controller responds to this message.
 *
 * \param sender The object sending the action message.
 */
-(IBAction)openFile:(id)sender
{
        NSOpenPanel * openPanel = nil;
        PLWindowController * keyWindowController = nil;
        
        keyWindowController = [[NSApp keyWindow] windowController];
        if ([keyWindowController isKindOfClass:[PLWindowController class]]) {
                openPanel = [NSOpenPanel openPanel];
                [openPanel setAllowedFileTypes:[[PLAddOnManager defaultManager] allAllowedFileTypes]];
                [openPanel setAllowsOtherFileTypes:YES];
                [openPanel setAllowsMultipleSelection:YES];
                [openPanel setCanChooseDirectories:NO];
                [openPanel setCanCreateDirectories:NO];
                [openPanel beginSheetModalForWindow:[keyWindowController window] completionHandler:^(NSInteger result) {
                        if (result == NSFileHandlingPanelOKButton) {
                                for (NSURL * fileURL in [openPanel URLs]) {
                                        [keyWindowController openDocumentWithURL:fileURL];
                                }
                        }
                }];
        }
}

/**
 * \brief Open a single file.
 *
 * \details Simply forward the message to `openFileWithURL:`.
 *
 * \param sender The application opening the file.
 *
 * \param filename The path to the file to open.
 *
 * \return YES if opening was successful.
 */
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
        return [self openFileWithURL:[NSURL fileURLWithPath:filename]];
}

/**
 * \brief Open multiple files.
 *
 * \details Forward the message to `openFileWithURL:` for each filename in
 *          `filenames`. Sends `NSApp` the `replyToOpenOrPrint:` message for
 *          each file with the `NSApplicationDelegateReplySuccess` value if
 *          opening was successful and `NSApplicationDelegateReplyFailure`
 *          otherwise.
 *
 * \param sender The application opening the file.
 *
 * \param filenames An array of paths to the files to open.
 *
 * \see openDocumentWithURL
 */
-(void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
        BOOL successful = NO;
        NSURL * fileURL = nil;
        
        for (NSString * filename in filenames) {
                fileURL = [NSURL fileURLWithPath:filename];
                successful = [self openFileWithURL:fileURL];
                if (successful) {
                        [NSApp replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
                } else {
                        [NSApp replyToOpenOrPrint:NSApplicationDelegateReplyFailure];
                }
        }
}

/**
 * \brief Open a single file.
 *
 * \details If the document is open and the user requests unique instances of
 *          documents, find the window containing the document and open it.
 *          Otherwise, open the document in the most recently used window whose
 *          controller is a `PLWindowController`. If no windows meet these
 *          criteria, create a new window to open the file in.
 *
 * \param fileURL The URL to the file to open.
 *
 * \return YES if opening was successful.
 */
-(BOOL)openFileWithURL:(NSURL *)fileURL
{
        PLWindowController * windowController = nil;
        BOOL successful = NO;

        if ([[PLDocumentManager sharedDocumentManager] documentIsOpen:fileURL] &&
            [[NSUserDefaults standardUserDefaults] boolForKey:PLUserDefaultUniqueDocuments]) {
                /* Find window with document open */
                for (NSWindow * window in [NSApp windows]) {
                        windowController = [window windowController];
                        if ([windowController isKindOfClass:[PLWindowController class]] && [windowController containsDocumentWithURL:fileURL]) {
                                successful = [windowController openDocumentWithURL:fileURL];
                                goto exit;
                        }
                }
        } else {
                /* Find window to open document in */
                for (NSWindow * window in [NSApp orderedWindows]) {
                        windowController = [window windowController];
                        if ([windowController isKindOfClass:[PLWindowController class]]) {
                                successful = [windowController openDocumentWithURL:fileURL];
                                goto exit;
                        }
                }
        }

        /* If reached here, create a new window and open the document */
        [self newWindowWithURL:fileURL];

exit:
        if (windowController) {
                [[windowController window] makeKeyAndOrderFront:self];
        }
        return successful;
}

#pragma mark - Tabs

/**
 * \brief Action used to cycle forward between active tabs.
 *
 * \param sender The object sending the message.
 */
-(IBAction)nextTab:(id)sender
{
        if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                [(PLWindowController *)[[NSApp keyWindow] windowController] selectNextTab];
        }
}

/**
 * \brief Action used to cycle backwards between active tabs.
 *
 * \param sender The object sending the message.
 */
-(IBAction)previousTab:(id)sender
{
        if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                [(PLWindowController *)[[NSApp keyWindow] windowController] selectPreviousTab];
        }
}

#pragma mark -

/**
 * \brief Validate menu items in the main menu.
 *
 * \details Creating a new window is always valid. Closing a window is only
 *          valid if there are any windows present. Otherwise, the menu item is
 *          only validated if the key window is a `PLWindowController`.
 *
 * \param menuItem The menu item.
 *
 * \return YES if the menu item is validated.
 */
-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
        BOOL validate = NO;

        if ([menuItem action] == @selector(newWindow:)) {
                validate = YES;
        } else if ([menuItem action] == @selector(closeFile:)) {
                validate = [[NSApp windows] count] > 0;
        } else if ([[[NSApp keyWindow] windowController] isKindOfClass:[PLWindowController class]]) {
                if ([menuItem action] == @selector(nextTab:) || [menuItem action] == @selector(previousTab:)) {
                        validate = [(PLWindowController *)[[NSApp keyWindow] windowController] numberOfTabs] > 1;
                } else {
                        validate = YES;
                }
        }
        
        return validate;
}

/**
 * \brief Display the application's credit window.
 *
 * \details If `creditWindowController` is nil, initialize it and display it
 *          with the `addWindowController:` method. Otherwise, make it the key
 *          window. Note that the controller is memory managed as all other
 *          windows are (i.e. with the `addWindowController:` and
 *          `windowWillClose:` methods).
 *
 * \param sender The object sending the action message.
 */
-(IBAction)showCreditWindow:(id)sender
{
        if (creditWindowController == nil) {
                creditWindowController = [PLCreditWindowController windowController];
                [self addWindowController:creditWindowController];
        } else {
                [[creditWindowController window] makeKeyAndOrderFront:self];
        }
}

/**
 * \brief Respond to a changed font.
 *
 * \details Convert the existing font to the new font and send the updateFont:
 *          message to the tab view controller and file browser view controller,
 *          if they implement it.
 */
-(void)changeFont:(id)sender
{
        NSFont * newFont = [sender convertFont:applicationFont];
        [applicationFont release];
        applicationFont = [newFont retain];
        for (NSWindow * window in [NSApp windows]) {
                if ([[window windowController] respondsToSelector:@selector(updateFont:)]) {
                        [[window windowController] updateFont:applicationFont];
                }
        }
}

@end

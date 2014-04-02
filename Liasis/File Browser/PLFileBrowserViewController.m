/**
 * \file PLFileBrowserViewController.m
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

#import "PLFileBrowserViewController.h"

/**
 * \brief The size of icon images used in the directory popup button and file
 *        browser outline view.
 */
static const CGFloat PLFileBrowserIconWidth = 16.0f;

@implementation PLFileBrowserViewController

#pragma mark - Object Lifecycle

/**
 * \brief Initialize a file browser view controller.
 *
 * \details Initialize a file browser view controller in a bundle with a
 *          tab view controller. Send the loadView message upon initialization.
 *          Set the outline view's target to itself and use the doubleClick
 *          method as the doubleAction for a user double click on an
 *          outline view item.
 *
 * \param nibNameOrNil The associated nib file name.
 *
 * \param aBundle An NSBundle to load the view controller from.
 *
 * \param aTabViewController The tab view controller used for opening files in
 *                           new tabs.
 *
 * \return The instantiated file browser view controller.
 */
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        PLFileBrowserImageAndTextCell * dataCell = nil;
        
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        [self loadView];
        if (self) {
                [outlineView setTarget:self];
                [outlineView setDoubleAction:@selector(doubleClick:)];
                dataCell = [[PLFileBrowserImageAndTextCell alloc] init];
                [dataCell setLineBreakMode:NSLineBreakByTruncatingMiddle];
                [[[outlineView tableColumns] objectAtIndex:0] setDataCell:dataCell];
                [dataCell release];

                otherMenuItem = [[NSMenuItem alloc] initWithTitle:@"Other..."
                                                           action:NULL
                                                    keyEquivalent:@""];
                [directoryPopUpButton setTarget:self];
                [directoryPopUpButton setAction:@selector(clickedDirectoryPopUpButton:)];
                [self setDirectoryRootPath:NSHomeDirectory()];
                [self updateThemeManager];
        }
        return self;
}

-(void)dealloc
{
        [otherMenuItem release];
        [super dealloc];
}

+(id)viewController
{
        PLFileBrowserViewController * viewController;
        viewController = [[self alloc] initWithNibName:@"PLFileBrowserViewController"
                                                bundle:[NSBundle bundleForClass:self]];
        return [viewController autorelease];
}

#pragma mark - Delegate, Action, Opening, and Theme

/**
 * \brief A delegate method for displaying cells in the outline view.
 *
 * \details This method is called before displaying cells in the outline view.
 *          Determine the font color to use for displayed cells: if selected,
 *          use the inverse of the selection color; otherwise, use the theme
 *          manager font color. If the outline view is out of focus, unhighlight
 *          any selected cell. If a cell is highlighted, set the highlight to
 *          NO in order to prevent the system from providing its default
 *          selection highlight. Selection highlighting is instead done by
 *          the PLOutlineView.
 *
 *          Set the image of the cell if it is a `PLFileBrowserImageAndTextCell`
 *          to the image associated with its file path.
 *
 * \param anOutlineView The outline view delegate.
 *
 * \param cell The cell to display.
 *
 * \param tableColumn The column in the table containing the cell.
 *
 * \param item The outline view item to display.
 *
 * \see PLOutlineView
 */
-(void)outlineView:(NSOutlineView *)anOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
        NSColor * textColor = nil, * selectionColor = nil;
        NSImage * cellImage = nil;
        
        if ([outlineView isInFocus] == NO) {
                [cell setHighlighted:NO];
        }
        
        if ([cell isHighlighted]) {
                selectionColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerSelection
                                                                              fromGroup:PLThemeManagerSettings];
                textColor = [NSColor colorWithInvertedRedGreenBlueComponents:selectionColor];
                [cell setHighlighted:NO];
        } else {
                textColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                         fromGroup:PLThemeManagerSettings];
        }
        [cell setTextColor:textColor];
        
        if ([cell isKindOfClass:[PLFileBrowserImageAndTextCell class]] && [[item representedObject] isKindOfClass:[PLFileBrowserItem class]]) {
                cellImage = [[NSWorkspace sharedWorkspace] iconForFile:[(PLFileBrowserItem *)[item representedObject] fullPath]];
                [cellImage setSize:NSMakeSize(PLFileBrowserIconWidth, PLFileBrowserIconWidth)];
                [(PLFileBrowserImageAndTextCell *)cell setImage:cellImage];
        }
}

/**
 * \brief Set the root directory or open a file when the user double clicks an
 *        entry in the file browser outline view.
 *
 * \details If the user double clicks an entry with no children (a file), this
 *          method calls the `openDocumentHandler` with the URL of the file.
 *          If the user double clicks a directory, set it as the new root
 *          directory for the file browser.
 *
 * \param object The object sending the message.
 */
-(void)doubleClick:(id)sender
{
        PLFileBrowserItem * clickedItem = [[outlineView itemAtRow:[outlineView clickedRow]] representedObject];

        if (clickedItem == nil) {
                goto exit;
        }

        if ([clickedItem childNodes]) {
                [self setDirectoryRootPath:clickedItem.fullPath];
        } else if (self.openDocumentHandler) {
                self.openDocumentHandler([NSURL fileURLWithPath:clickedItem.fullPath]);
        }

exit:
        return;
}

/**
 * \brief Update the theme manager.
 *
 * \details Update the background color and selection highlight color of the
 *          outline view.
 */
-(void)updateThemeManager
{
        NSColor * backgroundColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                 fromGroup:PLThemeManagerSettings];
        [(PLFileBrowserMainView *)[self view] setBackgroundColor:backgroundColor];
        [outlineView setBackgroundColor:backgroundColor];
}

#pragma mark - Directory Pop Up Button

/**
 * \brief Change the directory after selecting an item in the pop up button.
 *
 * \details Construct the path by combining entries in `directoryPopUpButton` up
 *          to the selected item and set this path as the root path of
 *          `PLFileBrowserItem`.
 *
 *          If clicking the `otherMenuItem`, present an Open dialog box and
 *          set the root path to the directory selected.
 *
 * \param sender The object sending the message.
 */
-(void)clickedDirectoryPopUpButton:(id)sender
{
        NSArray * newPathComponents = nil;
        NSArray * pathComponents = [directoryPath pathComponents];
        NSInteger selectedIndex = [directoryPopUpButton indexOfSelectedItem];
        NSOpenPanel * openPanel = nil;
        
        if ([directoryPopUpButton selectedItem] == otherMenuItem) {
                openPanel = [NSOpenPanel openPanel];
                [openPanel setCanChooseFiles:NO];
                [openPanel setCanChooseDirectories:YES];
                [openPanel setAllowsMultipleSelection:NO];
                [openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
                        if (result == NSFileHandlingPanelOKButton) {
                                [self setDirectoryRootPath:[[openPanel URL] path]];
                        } else {
                                [directoryPopUpButton selectItemAtIndex:0];
                        }
                }];
        } else if (selectedIndex >= 0) {
                newPathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - selectedIndex)];
                [self setDirectoryRootPath:[NSString pathWithComponents:newPathComponents]];
        }
}

/**
 * \brief Populate the items in the directory pop up button.
 *
 * \details Populate the pop up button with each component of the path to the
 *          root directory. This method sets the font attributes of the title
 *          cell.
 */
-(void)updateDirectoryPopUpButton
{
        NSMenuItem * menuItem = nil, * titleMenuItem = nil;
        NSImage * menuImage = nil;
        NSDictionary * attributes = nil;
        NSMutableParagraphStyle * titleParagraphStyle = nil;
        NSArray * pathComponents = [[NSFileManager defaultManager] componentsToDisplayForPath:directoryPath];
        NSString * currentPath = [NSString stringWithString:directoryPath];
        CGFloat titleImageWidth = PLFileBrowserIconWidth + 2.0f;
        
        [directoryPopUpButton removeAllItems];
        
        /* Create all menu items to allow duplicate titles and set the image */
        for (NSString * pathComponent in [pathComponents reverseObjectEnumerator]) {
                menuItem = [[NSMenuItem alloc] initWithTitle:pathComponent
                                                      action:NULL
                                               keyEquivalent:@""];
                menuImage = [[NSWorkspace sharedWorkspace] iconForFile:currentPath];
                [menuImage setSize:NSMakeSize(PLFileBrowserIconWidth, PLFileBrowserIconWidth)];
                [menuItem setImage:menuImage];
                [[directoryPopUpButton menu] addItem:menuItem];
                [menuItem release];
                currentPath = [currentPath stringByDeletingLastPathComponent];
        }
        [[directoryPopUpButton menu] addItem:[NSMenuItem separatorItem]];
        [[directoryPopUpButton menu] addItem:otherMenuItem];
        
        /* Set font for title cell */
        titleParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [titleParagraphStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
        attributes = @{NSForegroundColorAttributeName: [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                                                    fromGroup:PLThemeManagerSettings],
                       NSFontAttributeName: [NSFont menuFontOfSize:[NSFont systemFontSize] + 1],
                       NSParagraphStyleAttributeName: titleParagraphStyle};
        titleMenuItem = [directoryPopUpButton itemAtIndex:0];
        [titleMenuItem setAttributedTitle:[[[NSAttributedString alloc] initWithString:[titleMenuItem title]
                                                                           attributes:attributes] autorelease]];
        [titleParagraphStyle release];
        titleMenuItem.image.size = NSMakeSize(titleImageWidth, titleImageWidth);
}

/**
 * \brief Set the new root path for the directory pop up button.
 *
 * \details Stores the new path as `directoryPath` and updates `treeController`
 *          to use the children of the new path as its `content`. With this, the
 *          outline view displays the children of the root node. Finally,
 *          call `updateDirectoryPopUpButton` to refresh.
 *
 * \param path The new root path.
 *
 * \see updateDirectoryPopUpButton
 */
-(void)setDirectoryRootPath:(NSString *)path
{
        PLFileBrowserItem * rootNode = nil;
        NSMutableArray * nodes = nil;
        
        [path retain];
        [directoryPath release];
        directoryPath = path;
        
        rootNode = [PLFileBrowserItem treeNodeWithRepresentedObject:directoryPath];
        nodes = [NSMutableArray array];
        for (PLFileBrowserItem * child in [rootNode childNodes]) {
                [nodes addObject:[PLFileBrowserItem treeNodeWithRepresentedObject:child.fullPath]];
        }
        [treeController setContent:nodes];
        [self updateDirectoryPopUpButton];
}

@end

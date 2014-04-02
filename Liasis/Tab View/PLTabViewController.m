/**
 * \file PLTabViewController.m
 *
 * \brief Liasis Python IDE tab view controller.
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

#import "PLTabViewController.h"

const CGFloat PLTabItemMaxWidth = 200.0f;

/**
 * \brief The key used in the `NSTrackingArea` `userData` dictionary that maps
 *        to the associated tab item.
 */
NSString * const PLTabTrackingAreaTabItemKey = @"PLTabTrackingAreaTabItemKey";

@implementation PLTabViewController

#pragma mark - Object Lifecycle

+(id)tabViewController
{
        PLTabViewController * tabViewController = [[self alloc] initWithNibName:@"PLTabViewController"
                                                                         bundle:nil];
        [tabViewController loadView];
        return tabViewController;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        CGColorRef startColor = NULL, endColor = NULL;
        
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
                tabBar = [[PLTabBar alloc] init];
                activeTabColor = [[NSColor whiteColor] retain];
                activeTabSubview = nil;
                [tabBarView setPostsFrameChangedNotifications:YES];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(tabBarFrameDidChange:)
                                                             name:NSViewFrameDidChangeNotification
                                                           object:tabBarView];
                
                /* Create tab bar background */
                tabBarBackgroundLayer = [[CAGradientLayer layer] retain];
                startColor = CGColorCreateGenericGray(0.5f, 1.0f);
                endColor = CGColorCreateGenericGray(0.66f, 1.0f);
                tabBarBackgroundLayer.colors = @[(id)startColor, (id)endColor];
                CGColorRelease(startColor);
                CGColorRelease(endColor);
        }
        return self;
}

-(void)awakeFromNib
{
        NSRect buttonFrame, popUpFrame;

        buttonFrame = NSMakeRect(NSMaxX([tabBarView frame]) - [tabBarView frame].size.height,
                                 0.0f,
                                 [tabBarView frame].size.height - 10.0f,
                                 [tabBarView frame].size.height);
        popUpFrame = NSMakeRect(NSMaxX([tabBarView frame]) - 10.0f,
                                0.0f,
                                10.0f,
                                [tabBarView frame].size.height);
        addSubviewButton = [self createAddButton];
        addSubviewPopUp = [self createPopUpButton];
        [addSubviewButton setFrame:buttonFrame];
        [addSubviewPopUp setFrame:popUpFrame];
        [[tabBarView layer] addSublayer:tabBarBackgroundLayer];
        [tabBarView addSubview:addSubviewButton];
        [tabBarView addSubview:addSubviewPopUp];
        [tabBarView setDelegate:self];
        [tabSubview setDelegate:self];
        [self updateThemeManager];
}

-(void)dealloc
{
        [addSubviewButton removeFromSuperview];
        [addSubviewPopUp removeFromSuperview];
        [activeTabSubview removeFromSuperview];
        [activeTabSubview release];

        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                [item removeFromSuperlayer];
        }
        [tabBar release];
        [activeTabColor release];
        [tabBarBackgroundLayer removeFromSuperlayer];
        [tabBarBackgroundLayer release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [super dealloc];
}

#pragma mark - Theme Manager Methods

-(void)updateFont:(NSFont *)font
{
        NSViewController <PLTabSubviewController> * viewController = nil;
        
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                viewController = [tabBar viewControllerForTabItem:item];
                if ([viewController respondsToSelector:@selector(updateFont:)]) {
                        [viewController updateFont:font];
                }
        }
}

/**
 * \brief Update the theme manager.
 *
 * \details This method is used to update the theme manager properties of the
 *          tab view controller, the tab view, and any tab subview. This method
 *          sends a message to its tab subview controller that the theme manager
 *          has changed, in order to change the display of the tab subviews. All
 *          tab subviews that are loaded must be view extensions, conforming to
 *          the `PLAddOnViewExtension` protocol.
 *
 * \see PLAddOnExtension
 */
-(void)updateThemeManager
{
        NSViewController <PLTabSubviewController> * viewController = nil;
        NSColor * backgroundColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                 fromGroup:PLThemeManagerSettings];
        [activeTabColor release];
        activeTabColor = [backgroundColor retain];
        [self updateTabColors];
        [tabSubview setBackgroundColor:backgroundColor];
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                viewController = [tabBar viewControllerForTabItem:item];
                [viewController updateThemeManager];
        }
}

/**
 * \brief Update all tab colors.
 *
 * \details Sets the active tab to `activeTabColor` and all others to use
 *          the `tabBarBackgroundLayer` colors.
 */
-(void)updateTabColors
{
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                if (item == tabBar.activeTab) {
                        item.color = [activeTabColor CGColor];
                } else {
                        item.colors = tabBarBackgroundLayer.colors;
                }
        }
}

#pragma mark - Layout Calculation

/**
 * \brief Notification method when the tab bar's frame changes.
 *
 * \details Update its background layer's frame and recalculate all tab view
 *          item frames when it's `tabBarView` whose frame changes, not its
 *          subviews.
 *
 * \param notification The `NSViewFrameDidChangeNotification` object.
 */
-(void)tabBarFrameDidChange:(NSNotification *)notification
{
        if ([notification object] == tabBarView) {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                tabBarBackgroundLayer.frame = [tabBarView bounds];
                [CATransaction commit];
                [self positionTabBarItemsWithAnimation:NO];
        }
}

/**
 * \brief Method to update the tab layout.
 *
 * \details This method is used to calculate the layout for the tabs that are
 *          displayed in the tab bar. Tabs are placed slightly offset from the
 *          left edge and overlapping previous tabs.
 *
 * \return An array of `NSValue`-wrapped `NSRect` representing the frame of each
 *         tab item in the order they appear in the tab bar.
 */
-(NSArray *)calculateTabViewItems
{
        NSMutableArray * itemFrames = nil;
        NSSize tabSize;
        NSRect tabRect, barRect;
        CGFloat space = 0.0f;
        __block NSPoint location;

        barRect = NSMakeRect(0.0f, 0.0f, [tabBarView frame].size.width, [tabBarView frame].size.height);
        tabSize = NSMakeSize(PLTabItemMaxWidth, barRect.size.height - 3.0f);
        space = (barRect.size.width - [tabBarView frame].size.height) / [tabBar numberOfTabs];
        if (isnan(space) == NO)
                tabSize.width = MIN(tabSize.width, space);
        
        /* Calculate the frames of all tab items.
         * The starting location is offset from the left edge.
         */
        location = NSMakePoint(barRect.origin.x + 1.0f, barRect.origin.y);
        itemFrames = [NSMutableArray array];
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                tabRect = NSMakeRect(floorf(location.x),
                                     floorf(location.y),
                                     floorf(tabSize.width),
                                     floorf(tabSize.height));
                location.x += tabSize.width - 13.0f;  // overlap previous tab
                [itemFrames addObject:[NSValue valueWithRect:tabRect]];
        }
        return [NSArray arrayWithArray:itemFrames];
}

/**
 * \brief Convenience method to update the position of all tab items.
 *
 * \details This method adds a tracking area for the positioned tab and removes
 *          its old one. Finally, it updates the close button visibility of all
 *          tabs by determining the mouse location when this method was called.
 *          This allows for correct close button visibility if the mouse is
 *          stationary inside the tab bar and a new tab item appears at its
 *          location.
 *
 * \param item The tab item to position.
 *
 * \param itemFrames An array of `NSValue`-wrapped `NSRect`s specifying the
 *                   frame of each tab item in the same order as those in
 *                   `tabBarArray`. Same as the array returned by
 *                   `calculateTabViewItems`.
 *
 * \param animate YES if positioning the items should be animated.
 *
 * \see calculateTabViewItems
 */
-(void)positionTabBarItem:(PLTabBarItemLayer *)item withItemFrames:(NSArray *)itemFrames animate:(BOOL)animate
{
        NSTrackingArea * trackingArea = nil;
        NSUInteger itemIndex = NSNotFound;
        NSPoint locationInWindow = NSZeroPoint, locationInView = NSZeroPoint;

        itemIndex = [tabBar indexOfTabItem:item];
        if (itemIndex == NSNotFound)
                goto exit;
        
        [CATransaction begin];
        if (animate) {
                [CATransaction setAnimationDuration:0.2];
                [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        } else {
                [CATransaction setDisableActions:YES];
        }
        [item setFrame:[[itemFrames objectAtIndex:itemIndex] rectValue]];
        [CATransaction commit];
        
        /* Configure tracking area */
        trackingArea = [[NSTrackingArea alloc] initWithRect:[[itemFrames objectAtIndex:itemIndex] rectValue]
                                                    options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                                      owner:self
                                                   userInfo:@{PLTabTrackingAreaTabItemKey: item}];
        [tabBarView removeTrackingArea:[tabBar trackingAreaForTabItem:item]];
        [tabBarView addTrackingArea:trackingArea];
        [tabBar setTrackingArea:trackingArea forTabItem:item];
        [trackingArea release];

        /* Set close button visibility.
         * Ensure that the item has laid out its sublayers first. Without this,
         * closing a tab with the mouse over the tab bar will not cause the new
         * tab under the mouse to have its close button visible.
         */
        locationInWindow = [[tabBarView window] convertRectFromScreen:NSMakeRect([NSEvent mouseLocation].x, [NSEvent mouseLocation].y, 0, 0)].origin;
        locationInView = [tabBarView convertPoint:locationInWindow fromView:nil];
        [item layoutSublayers];
        [self updateTabCloseButtonWithPoint:locationInView];
        
exit:
        return;
}

/**
 * \brief Convenience method to update the position of one tab item.
 *
 * \details This method calls `calculateTabViewItems` and sets the frame of
 *          all tab items in `tabBarArray`.
 *
 * \param animate YES if positioning the items should be animated.
 *
 * \see calculateTabViewItems
 */
-(void)positionTabBarItemsWithAnimation:(BOOL)animate
{
        NSArray * itemFrames = [self calculateTabViewItems];
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                [self positionTabBarItem:item
                          withItemFrames:itemFrames
                                 animate:animate];
        }
}

/**
 * \brief Convenience method to update the tab layout of one tab item.
 *
 * \details This method will call `calculateTabViewItems` and use when sending
 *          the `positionTabBarItem:withItemFrames:animate` method.
 *
 * \param item The `PLTabBarItemView` to position.
 *
 * \param animate YES positioning the items should be animated.
 *
 * \see calculateTabViewItems
 */
-(void)positionTabBarItem:(PLTabBarItemLayer *)item animate:(BOOL)animate
{
        [self positionTabBarItem:item
                  withItemFrames:[self calculateTabViewItems]
                         animate:animate];
}

#pragma mark - Mouse Events

/**
 * \brief Return the tab bar item at a point.
 *
 * \details If multiple tab bar items are overlapping at the point, return the
 *          frontmost one by sorting by the item's `zPosition`.
 *
 * \param point An `NSPoint` in the coordinate system of `tabBarView`.
 *
 * \return The frontmost `PLTabBarItemLayer` containing `point` or nil if not
 *         within any tab items.
 */
-(PLTabBarItemLayer *)tabBarItemForPoint:(NSPoint)point
{
        NSArray * itemsWithPoint = nil, * sortDescriptors = nil;
        NSPoint locationInLayer = NSZeroPoint;
        
        locationInLayer = [tabBarView convertPointToLayer:point];
        itemsWithPoint = [tabBar.tabItems objectsAtIndexes:[tabBar.tabItems indexesOfObjectsPassingTest:^BOOL(PLTabBarItemLayer * item, NSUInteger idx, BOOL * stop) {
                return [item containsPoint:[[tabBarView layer] convertPoint:locationInLayer toLayer:item]];
        }]];

        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"zPosition" ascending:YES]];
        return [[itemsWithPoint sortedArrayUsingDescriptors:sortDescriptors] lastObject];
}

/**
 * \brief Update the visibility of the close button for all tabs.
 *
 * \details The tab item that contains `point` will have its close button
 *          visible. All others will hide their close button. If `point` is also
 *          within the close button frame, the close button will be highlighted.
 *
 * \param point An `NSPoint` in the coordinate system of `tabBarView`.
 */
-(void)updateTabCloseButtonWithPoint:(NSPoint)point
{
        PLTabBarItemLayer * itemInPoint = nil;
        NSPoint pointInLayer = NSZeroPoint;

        /* Update close button visibility */
        itemInPoint = [self tabBarItemForPoint:point];
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                if (item == itemInPoint) {
                        item.closeButtonHidden = NO;
                } else {
                        item.closeButtonHidden= YES;
                }
        }
        
        /* Update close button highlighting */
        pointInLayer = [tabBarView convertPointToLayer:point];
        if ([itemInPoint pointInCloseButton:[[tabBarView layer] convertPoint:pointInLayer toLayer:itemInPoint]]) {
                itemInPoint.closeButtonHighlighted = YES;
        } else {
                itemInPoint.closeButtonHighlighted = NO;
        }
}

/**
 * \brief Select or close a tab item.
 *
 * \details This method first determines if the event occurred within a tab
 *          item. If not, call the super method and return. If so, check if the
 *          event occurred within the item's close button and call the delegate
 *          method `clickedCloseButtonInTabViewItem:`. Otherwise, call the
 *          delegate method `mouseDownInTabViewItem:`.
 *
 * \param theEvent Object encapsulating information about the mouse down event.
 */
-(BOOL)shouldPerformMouseDownEvent:(NSEvent *)theEvent
{
        BOOL shouldPerform = NO;
        NSPoint locationInView = NSZeroPoint, locationInLayer = NSZeroPoint;
        PLTabBarItemLayer * clickedItem = nil;
        
        /* Find clicked tab item */
        locationInView = [tabBarView convertPoint:[theEvent locationInWindow] fromView:nil];
        clickedItem = [self tabBarItemForPoint:locationInView];
        if (clickedItem == nil) {
                shouldPerform = YES;
                goto exit;
        }
        
        /* Check if clicked in close button of tab item */
        locationInLayer = [tabBarView convertPointToLayer:locationInView];
        if ([clickedItem pointInCloseButton:[[tabBarView layer] convertPoint:locationInLayer toLayer:clickedItem]]) {
                [self closeTab:clickedItem];
        } else {
                [self setActiveTab:clickedItem];
        }
        
exit:
        return shouldPerform;
}

/**
 * \brief Initiate a dragging event if clicking inside a tab item.
 *
 * \details This method first determines if the event occurred within a tab
 *          item. If not, call the super method and return. If so, initiate a
 *          mouse-tracking loop that catches left mouse drag and left mouse up.
 *          This method uses the `hiddenTabItem` to include an empty space in
 *          the tab bar while dragging, simulating the location where the
 *          dragged tab would drop into.
 *
 *          Within this loop, continously move the x-position of the clicked tab
 *          by the `deltaX` of `theEvent` until receiving a left mouse up. At
 *          each iteration, determine where the dragging tab would be inserted
 *          in the tab bar and place the `hiddenTabItem` there. To do so, this
 *          method first compares its new x-position to its initial x-position
 *          to determine which direction it moved, then:
 *              - If moving right, find the first tab after the dragging tab's
 *                original index (enumerating in reverse) where the dragging
 *                tab's midpoint has passed the tab's origin.
 *              - If moving left, find the first tab before the dragging tab's
 *                original index where the dragging tab's origin has passed the
 *                tab's midpoint.
 *          A minor buffer region is added around the tab's midpoint so that
 *          hovering over the midpoint does not cause rapid tab switching.
 *          If the dragging tab has moved outside of its original position,
 *          reorder the `hiddenTabItem` in `tabBarArray` and use the
 *          `positionTabBarItem:animate:` method to refresh the tab positions.
 *          On mouse up, replace the `hiddenTabItem` with the tab being dragged.
 *
 * \param theEvent Object encapsulating information about the mouse dragged
 *                 event.
 */
-(BOOL)shouldPerformMouseDraggedEvent:(NSEvent *)theEvent
{
        BOOL shouldPerform = NO;
        NSPoint locationInView = NSZeroPoint;
        PLTabBarItemLayer * clickedItem = nil;
        NSUInteger clickedItemIndex = 0;
        CGFloat clickedItemOriginX = 0.0f;
        __block NSUInteger clickedItemNewIndex = NSNotFound;
        
        /* Find clicked tab item */
        locationInView = [tabBarView convertPoint:[theEvent locationInWindow] fromView:nil];
        clickedItem = [self tabBarItemForPoint:locationInView];
        if (clickedItem == nil) {
                shouldPerform = YES;
                goto exit;
        }
        clickedItemIndex = [tabBar indexOfTabItem:clickedItem];
        clickedItemOriginX = [clickedItem frame].origin.x;
        
        /* Use mouse-tracking loop to drag clicked tab item until mouseUp */
        while ([theEvent type] != NSLeftMouseUp) {
                theEvent = [[tabBarView window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [clickedItem setFrame:CGRectMake([clickedItem frame].origin.x + [theEvent deltaX],
                                                 [clickedItem frame].origin.y,
                                                 [clickedItem frame].size.width,
                                                 [clickedItem frame].size.height)];
                [CATransaction commit];
                
                /* Determine where the dragging tab would be inserted */
                if ([clickedItem frame].origin.x > clickedItemOriginX) {
                        /* Moving right */
                        [tabBar.tabItems enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PLTabBarItemLayer * item, NSUInteger idx, BOOL * stop) {
                                if (idx <= clickedItemIndex) {
                                        *stop = YES;
                                } else if (NSMaxX([clickedItem frame]) > [item frame].origin.x + [item frame].size.width * 0.55) {
                                        clickedItemNewIndex = idx;
                                        *stop = YES;
                                }
                        }];
                } else {
                        /* Moving left */
                        [tabBar.tabItems enumerateObjectsUsingBlock:^(PLTabBarItemLayer * item, NSUInteger idx, BOOL * stop) {
                                if (idx >= clickedItemIndex) {
                                        *stop = YES;
                                } else if (NSMinX([clickedItem frame]) < [item frame].origin.x + [item frame].size.width * 0.45) {
                                        clickedItemNewIndex = idx;
                                        *stop = YES;
                                }
                        }];
                }
                
                /* Reorder hidden tab if needed */
                if (clickedItemNewIndex != NSNotFound) {
                        /* Move replaced tab into position */
                        [tabBar moveTabItem:clickedItem toIndex:clickedItemNewIndex];
                        [self positionTabBarItem:[tabBar tabItemAtIndex:clickedItemIndex] animate:YES];
                        
                        /* Reset properties of the clicked tab to match that of the hidden tab */
                        clickedItemOriginX = [[[self calculateTabViewItems] objectAtIndex:clickedItemNewIndex] rectValue].origin.x;
                        clickedItemIndex = clickedItemNewIndex;
                        clickedItemNewIndex = NSNotFound;
                }
        }
        
        /* After mouse-up, insert the clicked tab */
        [self positionTabBarItem:clickedItem animate:YES];
        
exit:
        return shouldPerform;
}

/**
 * \brief Ensure that the close button is visible in tab items containing the
 *        mouse.
 *
 * \details This method is called by the tracking areas that cover each tab
 *          item. It is used instead of `mouseEntered:` in order to respect the
 *          non-rectangular masked area of the tab. This method will also hide
 *          the close button when the mouse exits through a masked edge, but
 *          remains in the tracking area. The `mouseExited:` method handles
 *          hiding the close button when the mouse exits through an unmasked
 *          edge (i.e. the bottom of the tab).
 *
 * \param theEvent Object encapsulating information about the mouse moved event.
 *
 * \see mouseExited:
 *
 * \see mouseEntered:
 */
-(void)mouseMoved:(NSEvent *)theEvent
{
        NSPoint locationInView = NSZeroPoint;
        
        locationInView = [tabBarView convertPoint:[theEvent locationInWindow] fromView:nil];
        [self updateTabCloseButtonWithPoint:locationInView];
}

/**
 * \brief Ensure that the close button is visible when switching windows.
 *
 * \details This method is only used for application switching: when the mouse
 *          is over a tab and the user switches applications with cmd-tab, the
 *          `mouseExited:` method is called, hiding the close button. This
 *          method is then called and is used to update the close button
 *          visibility again.
 *
 *          Note that this method uses the `updateTabCloseButtonWithPoint:`
 *          method because entering the tracking area doesn't necessarily mean
 *          entering the tab's masked area.
 *
 * \param theEvent Object encapsulating information about the mouse enter event.
 *
 * \see mouseMoved:
 *
 * \see mouseExited:
 */
-(void)mouseEntered:(NSEvent *)theEvent
{
        NSPoint locationInView = [tabBarView convertPoint:[theEvent locationInWindow] fromView:nil];
        [self updateTabCloseButtonWithPoint:locationInView];
}

/**
 * \brief Hide the close button when the mouse exits a tracking area.
 *
 * \details This method uses the sends the `userData` message to `theEvent` to
 *          determine the tab associated with the tracking area and sets its
 *          `closeButtonHidden` property to YES.
 *
 *          This method is used to hide the close button when the mouse exits
 *          through an unmasked edge of the tab. The `mouseMoved:` method will
 *          have already hidden the close button if the mouse exits through a
 *          masked edge.
 *
 * \param theEvent Object encapsulating information about the mouse exit event.
 *
 * \see mouseMoved:
 *
 * \see mouseEntered:
 */
-(void)mouseExited:(NSEvent *)theEvent
{
        NSDictionary * userData = nil;
        PLTabBarItemLayer * item = nil;

        userData = [theEvent userData];
        item = [userData objectForKey:PLTabTrackingAreaTabItemKey];
        item.closeButtonHidden = YES;
}

#pragma mark - Button Creation and Actions

/**
 * \brief Method called when pressing the add tab buttons in the tab view.
 *
 * \details This method is called when pressing either the add tab button or the
 *          add tab pop up button. The sender of the message is checked, and if
 *          sender is the pop up button, the addTab: method calls the appropriate
 *          add tab method in the tab view controller.
 *
 * \param id sender The object that sent the message. Should be either the add
 *                  tab button or add tab pop up button.
 */
-(IBAction)addTab:(id)sender
{
        NSString * title;
        PLAddOnManager * manager = [PLAddOnManager defaultManager];
        NSArray * viewExtensions = [manager extensionBundles];
        Class <PLAddOnExtension> aClass = nil;
        
        /* Add default tab if not clicking popup button */
        if (sender == addSubviewButton) {
                [self addDefaultTab];
                goto bail;
        }
        
        /* Add tab selected from popup button by name */
        title = [addSubviewPopUp titleOfSelectedItem];
        for (NSBundle * viewExtension in viewExtensions) {
                aClass = [viewExtension principalClass];
                if ([[aClass tabSubviewName] isEqualToString:title] == YES) {
                        [self addTabWithAddOn:viewExtension];
                        break;
                }
        }
bail:
        return;
}

/**
 * \brief Creates the add tabs button instance with all the appropriate
 *        attributes.
 *
 * \details The add tab button instance is initialized with the appropriate
 *          action and target and display behavior. Pressing the button
 *          sends an addTab: message to the tab view with the add tab button as
 *          as the sender. The tab view sends a meesage to the tab view
 *          controller telling it to add the default tab (text editor view).
 *
 * \return An NSPopUpButton object initialized with the properties required by
 *         the tab view.
 */
-(NSButton *)createAddButton
{
        NSButton * addButton = nil;
        addButton = [[NSButton alloc] init];
        [addButton setTarget:self];
        [addButton setBordered:NO];
        [addButton setAction:@selector(addTab:)];
        [addButton setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin];
        [addButton setButtonType:NSMomentaryChangeButton];
        [addButton setImage:[NSImage imageNamed:NSImageNameAddTemplate]];
        [addButton setImagePosition:NSImageOnly];
        [addButton setRefusesFirstResponder:YES];
        return [addButton autorelease];
}

/**
 * \brief Creates the pop up button instance with all the appropriate
 *        attributes.
 *
 * \details The pop up button instance is initialized with the view controller
 *          titles, that are displayed as a pull-down menu. Pressing a title
 *          sends a addTab: message to the tab view with the pop up button as
 *          as the sender. The tab view identifies the selected item from the
 *          pull-down menu and sends the corresponding addTypeTab: message.
 *
 * \return An NSPopUpButton object initialized with the properties required by
 *         the tab view.
 */
-(NSPopUpButton *)createPopUpButton
{
        NSPopUpButton * addButton = nil;
        addButton = [[NSPopUpButton alloc] init];
        [addButton setTarget:self];
        [addButton setBordered:NO];
        [addButton setAction:@selector(addTab:)];
        [addButton setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin];
        [addButton setPullsDown:YES];
        [addButton setButtonType:NSMomentaryChangeButton];
        [addButton setRefusesFirstResponder:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePopUpButton:)
                                                     name:NSPopUpButtonWillPopUpNotification
                                                   object:addButton];
        return [addButton autorelease];
}

#pragma mark - Notifications

-(void)documentSavedStateChanged:(NSNotification *)aNotification
{
        BOOL isUnsaved = NO;
        PLDocument<PLDocumentSubclass> * document;
        id <PLTabSubviewController> tabSubviewController;
        tabSubviewController = [tabBar viewControllerForTabItem:tabBar.activeTab];
        document = [tabSubviewController document];
        isUnsaved = [[PLDocumentManager sharedDocumentManager] documentIsEdited:document];
        [[[self view] window] setDocumentEdited:isUnsaved];
}

/**
 * \brief Method to update the list of available view extensions that can be
 *        added to the tab view.
 *
 * \details This method updates the add tab pop-up button by requesting the list
 *          of view extensions from the add on manager. This method is called
 *          in response to a `NSPopUpButtonWillPopUp` notification.
 *
 * \param aNotification The object posting the notification.
 */
-(void)updatePopUpButton:(NSNotification *)aNotification
{
        PLAddOnManager * manager = [PLAddOnManager defaultManager];
        Class <PLAddOnExtension> aClass;
        [addSubviewPopUp removeAllItems];
        [addSubviewPopUp addItemWithTitle:@""];
        for (NSBundle * viewExtension in [manager extensionBundles]) {
                aClass = [viewExtension principalClass];
                [addSubviewPopUp addItemWithTitle:[aClass tabSubviewName]];
        }
}

/**
 * \brief Method called when a subview's title changes.
 *
 * \details Find the tab item associated with the view controller that posted
 *          the notification and set its title. The title is determined by
 *          sending the subview controller the `title` message.
 */
-(void)updateTitle:(NSNotification *)aNotification
{
        NSViewController * subviewController = [aNotification object];
        
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                if ([tabBar viewControllerForTabItem:item] == subviewController) {
                        item.title = [subviewController title];
                        if (item == tabBar.activeTab) {
                                [self updateWindowTitle];
                        }
                        break;
                }
        }
}

-(void)activeSubviewChangedSavedState:(NSNotification *)aNotification
{
        BOOL isUnsaved = NO;
        id document = [[tabBar viewControllerForTabItem:tabBar.activeTab] document];
        isUnsaved = [[PLDocumentManager sharedDocumentManager] documentIsEdited:document];
        [[[self view] window] setDocumentEdited:isUnsaved];
}

#pragma mark - Tab Handling

-(NSUInteger)numberOfTabs
{
        return [tabBar numberOfTabs];
}

-(void)addDefaultTab
{
        if ([[PLAddOnManager defaultManager] defaultAddOnBundle]) {
                [self addTabWithAddOn:[[PLAddOnManager defaultManager] defaultAddOnBundle]];
        }
}

-(void)addTabWithAddOn:(NSBundle *)addOn
{
        [self addTabWithAddOn:addOn withDocument:nil];
}

-(void)addTabWithAddOn:(NSBundle *)addOn withDocument:(id)aDocument
{
        NSViewController <PLAddOnExtension> * viewController = nil;
        PLTabBarItemLayer * item = nil;
        CABasicAnimation * tabAnimation = nil;
        Class controllerClass = Nil;

        /* Add the subview controller */
        controllerClass = [addOn principalClass];
        if ([controllerClass conformsToProtocol:@protocol(PLAddOnExtension)] == NO) {
                NSLog(@"Error: view controller must conform to the PLAddOnExtension protocol.");
                /* Error Report Here */
                goto exit;
        }
        if (aDocument)
                viewController = [controllerClass viewControllerWithDocument:aDocument];
        else
                viewController = [controllerClass viewController];
        [viewController updateThemeManager];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateTitle:)
                                                     name:PLTabSubviewTitleDidChangeNotification
                                                   object:viewController];

        /* Add the tab item */
        item = [PLTabBarItemLayer layer];
        item.title = [viewController title];
        [tabBar addTabItem:item withViewController:viewController];
        [[tabBarView layer] addSublayer:item];
        [self positionTabBarItemsWithAnimation:NO];
        [self setActiveTab:item];
        
        /* Animate the tab into the tab bar if it's not the first one */
        if ([tabBar numberOfTabs] > 1) {
                tabAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation"];
                tabAnimation.duration = 0.15f;
                tabAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                tabAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(item.bounds.origin.x, item.bounds.origin.y - item.bounds.size.height)];
                tabAnimation.toValue = [NSValue valueWithPoint:item.bounds.origin];
                [item addAnimation:tabAnimation forKey:@"translation"];
        }

exit:
        return;
}

/**
 * \brief Remove a tab and its subview controller.
 *
 * \details Sets the active tab to the next tab in the bar unless it's already
 *          at the end, in which case the previous tab becomes the active tab.
 *          Sets the active tab to nil if it was the last tab. Removes the tab
 *          item, its tracking area, and the subview controller. If `tabItem` is
 *          does not exist in the tab bar, do nothing.
 *
 * \param tabItem The tab item to be removed.
 */
-(void)removeTab:(PLTabBarItemLayer *)tabItem
{
        NSViewController <PLTabSubviewController> * subviewController = nil;
        
        subviewController = [tabBar viewControllerForTabItem:tabItem];
        if (subviewController == nil) {
                goto exit;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:PLTabSubviewTitleDidChangeNotification
                                                      object:subviewController];

        if (tabItem == tabBar.activeTab) {
                if ([tabBar numberOfTabs] == 1) {
                        [self setActiveTab:nil];
                } else if ([tabBar indexOfTabItem:tabItem] == [tabBar numberOfTabs] - 1) {
                        [self selectPreviousTab];
                } else {
                        [self selectNextTab];
                }
        }
        
        /* Remove the tab item */
        [tabBarView removeTrackingArea:[tabBar trackingAreaForTabItem:tabItem]];
        [tabBar removeTabItem:tabItem];
        [tabItem removeFromSuperlayer];
        [self positionTabBarItemsWithAnimation:NO];

exit:
        return;
}

-(void)setActiveTab:(PLTabBarItemLayer *)tabItem
{
        NSViewController <PLTabSubviewController> * viewController = nil;
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];

        viewController = [tabBar viewControllerForTabItem:tabItem];
        if (tabItem && (tabItem == tabBar.activeTab || viewController == nil)) {
                goto exit;
        }
        
        /* Setup new view controller */
        [defaultCenter removeObserver:self
                                 name:PLTabSubviewDocumentChangedSavedSateNotification
                               object:[tabBar viewControllerForTabItem:tabBar.activeTab]];
        [defaultCenter addObserver:self
                          selector:@selector(documentSavedStateChanged:)
                              name:PLTabSubviewDocumentChangedSavedSateNotification
                            object:viewController];
        
        /* Setup tab subview */
        [activeTabSubview removeFromSuperview];
        [activeTabSubview release];
        activeTabSubview = [[viewController view] retain];
        [activeTabSubview setFrame:[tabSubview frame]];
        [tabSubview addSubview:activeTabSubview];
        [activeTabSubview setNeedsDisplay:YES];

        /* Set state changes */
        tabBar.activeTab = tabItem;
        [self documentSavedStateChanged:nil];
        [[[self view] window] makeFirstResponder:viewController];
        [[[self view] window] setDocumentEdited:[[PLDocumentManager sharedDocumentManager] documentIsEdited:[viewController document]]];
        [self updateWindowTitle];

        /* Reorder tabs and update their background color */
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [tabBar.tabItems enumerateObjectsUsingBlock:^(PLTabBarItemLayer * item, NSUInteger idx, BOOL * stop) {
                if (item == tabBar.activeTab) {
                        item.zPosition = [tabBar numberOfTabs];
                } else {
                        item.zPosition = [tabBar numberOfTabs] - idx - 1;
                }
        }];
        [CATransaction commit];
        [self updateTabColors];

exit:
        return;
}

-(void)selectNextTab
{
        NSUInteger activeTabIndex = 0, nextTabIndex = 0;
        
        if ([tabBar numberOfTabs] == 0) {
                goto exit;
        }
        
        activeTabIndex = [tabBar.tabItems indexOfObject:tabBar.activeTab];
        if (activeTabIndex == [tabBar numberOfTabs] - 1) {
                nextTabIndex = 0;
        } else {
                nextTabIndex = activeTabIndex + 1;
        }
        [self setActiveTab:[tabBar tabItemAtIndex:nextTabIndex]];

exit:
        return;
}

-(void)selectPreviousTab
{
        NSUInteger activeTabIndex = 0, previousTabIndex = 0;
        
        if ([tabBar numberOfTabs] == 0) {
                goto exit;
        }
        
        activeTabIndex = [tabBar.tabItems indexOfObject:tabBar.activeTab];
        if (activeTabIndex == 0) {
                previousTabIndex = [tabBar numberOfTabs] - 1;
        } else {
                previousTabIndex = activeTabIndex - 1;
        }
        [self setActiveTab:[tabBar tabItemAtIndex:previousTabIndex]];

exit:
        return;
}

-(BOOL)shouldCloseAllTabs
{
        BOOL shouldCloseAllTabs = YES;
        while (shouldCloseAllTabs == YES) {
                if (tabBar.activeTab == nil)
                        break;
                shouldCloseAllTabs = [[tabBar viewControllerForTabItem:tabBar.activeTab] tabSubviewShouldClose:self];
                if (shouldCloseAllTabs == YES) {
                        [self removeTab:tabBar.activeTab];
                }
        }
        return shouldCloseAllTabs;
}

#pragma mark - Documents

/**
 * \brief Return the tab item containing a document at a particular URL.
 *
 * \param fileURL The URL of the document.
 *
 * \return The `PLTabBarItemLayer` whose associated view controller contains
 *         the document at `fileURL` or nil if no tabs do.
 */
-(PLTabBarItemLayer *)tabItemForURL:(NSURL *)fileURL
{
        PLTabBarItemLayer * tabItem = nil;
        
        for (PLTabBarItemLayer * item in tabBar.tabItems) {
                if ([fileURL isEqualTo:[[[tabBar viewControllerForTabItem:item] document] fileURL]]) {
                        tabItem = item;
                        break;
                }
        }
        return tabItem;
}

-(BOOL)containsTabWithURL:(NSURL *)fileURL
{
        return [self tabItemForURL:fileURL] != nil;
}

-(void)setTabWithURLActive:(NSURL *)fileURL
{
        PLTabBarItemLayer * tabItem = [self tabItemForURL:fileURL];
        if (tabItem) {
                [self setActiveTab:tabItem];
        }
}

#pragma mark - Responder Chain

/**
 * \brief Forward first responder status to the view controller of the active
 *        tab.
 *
 * \return YES if the active view controller accepted first responder status.
 */
-(BOOL)becomeFirstResponder
{
        return [[[self view] window] makeFirstResponder:[tabBar viewControllerForTabItem:tabBar.activeTab]];
}

#pragma mark - Open, Save, Close

-(void)saveActiveTab
{
        NSViewController <PLTabSubviewController> * subviewController = nil;

        subviewController = [tabBar viewControllerForTabItem:tabBar.activeTab];
        [subviewController saveFile:self];
}

-(void)saveAsActiveTab
{
        NSViewController <PLTabSubviewController> * subviewController = nil;

        subviewController = [tabBar viewControllerForTabItem:tabBar.activeTab];
        [subviewController saveFileAs:self];
}

-(void)closeActiveTab
{
        [self closeTab:tabBar.activeTab];
}

/**
 * \brief Close a tab.
 *
 * \details This method sends a `closeFile:` action message to the subview
 *          controller of the active tab. The `closeFile:` method is part of the
 *          `PLTabSubviewController` protocol.
 *
 * \see PLTabSubviewController
 */
-(void)closeTab:(PLTabBarItemLayer *)tabItem
{
        NSViewController <PLTabSubviewController> * subviewController = nil;
        
        subviewController = [tabBar viewControllerForTabItem:tabItem];
        if ([subviewController tabSubviewShouldClose:self]) {
                [self removeTab:tabItem];
        }
}

#pragma mark -

/**
 * \brief Update the window's title and represented URL.
 *
 * \details The `representedURL` of the window is set to the `fileURL` of the
 *          active tab's document. Its title is set to the `filename` of the
 *          active tab's document. If there is no active tab, fall back to the
 *          application's name as the title.
 */
-(void)updateWindowTitle
{
        NSViewController <PLTabSubviewController> * subviewController = nil;
        NSString * windowTitle = nil;

        windowTitle = [[NSRunningApplication currentApplication] localizedName];
        if (tabBar.activeTab) {
                subviewController = [tabBar viewControllerForTabItem:tabBar.activeTab];
                if ([subviewController document]) {
                        windowTitle = [[subviewController document] filename];
                        [[[self view] window] setRepresentedURL:[[subviewController document] fileURL]];
                }
        }
        [[[self view] window] setTitle:windowTitle];
}

@end

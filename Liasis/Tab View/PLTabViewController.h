/**
 * \file PLTabViewController.h
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


#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>
#import "PLTabBar.h"
#import "PLTabBarView.h"
#import "PLTabSubview.h"

/**
 * \class PLTabViewController \headerfile \headerfile
 * \brief A subclass of NSViewController that manages multiple views using a tab 
 *        scheme.
 *
 * \details The PLTabViewController is a class that manages the tab subview
 *          controllers. The tab subview controllers must conform to the
 *          PLTabSubviewController protocol. The tab view has an array of tab
 *          bar items, each with a unique identifier string. The identifier
 *          strings serve as keys for a dictionary, thus linking the tabs with
 *          the tab subview controllers.
 */
@interface PLTabViewController : NSViewController <PLThemeable, PLTabBarViewDelegate> {
        /**
         * \brief The `PLTabBarView` where the tabs will be drawn.
         */
        IBOutlet PLTabBarView * tabBarView;

        /**
         * \brief The view where the current view extension will be drawn.
         */
        IBOutlet PLTabSubview * tabSubview;
        
        PLTabBar * tabBar;

        /**
         * \brief An NSButton object used to display the button for adding a
         *        default tab by sending a message to the addTab: private method.
         */
        NSButton * addSubviewButton;

        /**
         * \brief An NSPopUpButton object used to display the button for adding a
         *        tab that may not be the default tab. This button contains a
         *        list of tab subviews that can be added, and sends a message to
         *        the addTab: private method.
         */
        NSPopUpButton * addSubviewPopUp;

        /**
         * \brief An NSView object defining the current active tab subview
         *        that is being displayed.
         */
        NSView * activeTabSubview;
        
        /**
         * \brief The gradient used for the tab background and inactive tabs.
         */
        CAGradientLayer * tabBarBackgroundLayer;
        
        /**
         * \brief The color of the active tab.
         *
         * \details Setting this value updates the color of the active tab.
         */
        NSColor * activeTabColor;
}

/**
 * \brief The number of tabs in the tab bar.
 */
@property (readonly) NSUInteger numberOfTabs;

/**
 * \brief Class factory method that instantiates a new tab view controller
 *        with the specified nib file in the main bundle.
 *
 * \details The factory method creates a new tab view controller by calling
 *          initWithNibName:bundle:, where the nib name is PLTabViewController
 *          and the bundle is nil, specifying the main bundle.
 *
 * \return This function returns a new instance of a PLTabViewController object
 *         that is in the autorelease pool. If the object was not allocated,
 *         this method returns nil.
 *
 * \see PLAddOnExtension
 *
 */
+(id)tabViewController;

/**
 * \brief Add a tab with the default subview controller.
 *
 * \details This method extracts the principal class of the bundle returned
 *          by `[[PLAddOnManager defaultManager] defaultAddOnBundle]` and sends
 *          it a `viewController` message.
 *
 * \see setDefaultAddOnBundle
 */
-(void)addDefaultTab;

/**
 * \brief Call addTabWithAddOn:withDocument: with document set to nil.
 *
 * \param addOn An instance of a NSBundle object that has been loaded through
 *              the PLAddOnManager object. The principal class must conform to
 *              the PLAddOnViewExtension protocol.
 *
 * \see addTabWithAddOn:withDocument:
 *
 */
-(void)addTabWithAddOn:(NSBundle *)addOn;

/**
 * \brief Method to add an addon view extension with associated document.
 *
 * \details This method is used to add custom view extensions as tab subviews.
 *          The tab view controller adds subviews by using the methods as
 *          defined in the `PLAddOnViewExtension` protocol, which are inherited
 *          from the `PLTabSubviewController` protocol.
 *
 *          If aDocument is not nil, initialize the view controller by sending
 *          it the `viewControllerWithDocument:` message. Otherwise, initialize
 *          it with the `viewController` method.
 *
 * \param addOn An instance of a NSBundle object that has been loaded through
 *              the `PLAddOnManager` object. The principal class must conform to
 *              the `PLAddOnViewExtension` protocol.
 *
 * \param aDocument The document used by the addon.
 *
 * \see PLAddOnViewExtension
 *
 */
-(void)addTabWithAddOn:(NSBundle *)addOn withDocument:(id)aDocument;

/**
 * \brief Method used to programattically set the active tab. 
 *
 * \details Make the tab view's view controller the application window's first
 *          responder. Tab subview controllers should override the
 *          `becomeFirstResponder` `NSResponder` method to make one of its views
 *          the first responder and return YES.
 *
 *          This method does nothing if `tabName` already corresponds to the
 *          active tab or if no tabs are identified by `tabName`.
 *
 * \param tabItem The tab item to make active.
 */
-(void)setActiveTab:(PLTabBarItemLayer *)tabItem;

/**
 * \brief Select the next tab in the tab bar.
 *
 * \details Cycles around to the first tab if the active tab is the last tab.
 */
-(void)selectNextTab;

/**
 * \brief Select the previous tab in the tab bar.
 *
 * \details Cycles around to the last tab if the active tab is the first tab.
 */
-(void)selectPreviousTab;

#pragma mark - Documents

/**
 * \brief Check if the tab view contains a tab with a document.
 *
 * \param fileURL The URL of the document.
 *
 * \return YES if the tab view contains a tab with the document.
 */
-(BOOL)containsTabWithURL:(NSURL *)fileURL;

/**
 * \brief Set the active tab to the one containing a particular document.
 *
 * \details Does nothing of no tabs contain the document at `fileURL`.
 *
 * \param fileURL The URL of the document.
 */
-(void)setTabWithURLActive:(NSURL *)fileURL;

/**
 * \brief Method used to close all tabs and determine if all the tabs have been
 *        succesfully closed.
 *
 * \details The method sends all its tab subview controllers a tabSubviewShouldClose:
 *          message, closing each of them until it has closed all the tabs,
 *          unless a tab subview controller returns NO.
 *
 * \return A BOOL value with YES if all the tab view controllers tab subviews 
 *         have been succesfully closed. Otherwise, returns NO.
 *
 */
-(BOOL)shouldCloseAllTabs;

#pragma mark - Open, Save, and Close

/**
 * \brief Save the active tab.
 *
 * \details This method sends a `saveFile:` action message to the subview
 *          controller of the active tab. The `saveFile:` method is part of the
 *          `PLTabSubviewController` protocol.
 *
 * \see PLTabSubviewController
 */
-(void)saveActiveTab;

/**
 * \brief Save As the active tab.
 *
 * \details This method sends a `saveAsFile:` action message to the subview
 *          controller of the active tab. The `saveAsFile:` method is part of
 *          the `PLTabSubviewController` protocol.
 *
 * \see PLTabSubviewController
 */
-(void)saveAsActiveTab;

/**
 * \brief Close the active tab.
 *
 * \details This method sends a `closeFile:` action message to the subview
 *          controller of the active tab. The `closeFile:` method is part of the
 *          `PLTabSubviewController` protocol.
 *
 * \see PLTabSubviewController
 */
-(void)closeActiveTab;

@end

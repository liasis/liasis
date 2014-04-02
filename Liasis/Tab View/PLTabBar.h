/**
 * \file PLTabBar.h
 *
 * \brief Liasis Python IDE tab bar model object and its tab items.
 *
 * \details This file includes the model object for the tab bar and a `CALayer`
 *          subclass used for each tab item.
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

#import <Foundation/Foundation.h>
#import <LiasisKit/LiasisKit.h>

@class PLTabBarItemLayer;

/**
 * \class PLTabBar \headerfile \headerfile
 *
 * \brief The model object for the tab bar view.
 *
 * \details This class stores all tab items in the order they should appear in
 *          the tab bar. Each tab item is mapped to a view controller whose
 *          view should be displayed when the tab is active. Additionally, this
 *          class supports mapping a tracking area to a tab item.
 *
 *          Note: items in the tab bar are distinct from one another, but the
 *          associated view controllers are not required to be distinct (i.e.
 *          multiple tabs could use the same view controller).
 */
@interface PLTabBar : NSObject
{
        /**
         * \brief The mutable array of all tab bar items in the order they
         *        appear in the tab bar.
         */
        NSMutableArray * tabItemArray;

        /**
         * \brief The mapping of all tab bar items mapped to the associated tab
         *        subview controller that is displayed when the tab bar item is
         *        made active.
         */
        NSMapTable * tabItems;
        
        /**
         * \brief The mapping of all tab bar item names mapped to the associated
         *        tracking area.
         */
        NSMapTable * trackingAreas;
}

/**
 * \brief An array of all tab bar items.
 */
@property (retain, readonly) NSArray * tabItems;

/**
 * \brief The active tab bar item.
 */
@property (retain) PLTabBarItemLayer * activeTab;

#pragma mark - Adding, Removing, and Moving Tab Items

/**
 * \brief Add a tab item to the tab bar.
 *
 * \details Tab items are mapped to an associated view controller conforming to
 *          the `PLTabSubViewController` protocol. `item` and `viewController`
 *          must not be nil. Does nothing if `item` is already in the tab bar.
 *
 * \param item The tab item to add.
 *
 * \param viewController The tab item's associated view controller.
 */
-(void)addTabItem:(PLTabBarItemLayer *)item withViewController:(NSViewController <PLTabSubviewController> *)viewController;

/**
 * \brief Remove a tab bar item.
 *
 * \details Does nothing if `item` was not in the tab bar.
 *
 * \param The tab item to remove.
 */
-(void)removeTabItem:(PLTabBarItemLayer *)item;

/**
 * \brief Move a tab item to a new index.
 *
 * \details This method removes `item` and inserts it at the new index, pushing
 *          all following tabs up one index. Raises an exception if `item` is
 *          nil or `index` is out of bounds of the `tabItems` array.
 *
 * \param item The tab item to move.
 *
 * \param index The tab item's new index.
 */
-(void)moveTabItem:(PLTabBarItemLayer *)item toIndex:(NSUInteger)index;

#pragma mark - Querying Tab Items

/**
 * \brief Return the view controller associated with a tab item.
 *
 * \param item The tab item.
 *
 * \return The view controller associated with `item` or nil if `item` is not in
 *         the tab bar.
 */
-(NSViewController <PLTabSubviewController> *)viewControllerForTabItem:(PLTabBarItemLayer *)item;

/**
 * \brief Return the index of a tab item.
 *
 * \param item The tab item.
 *
 * \return The index of `item` or `NSNotFound` if `item` is not in the tab bar.
 */
-(NSUInteger)indexOfTabItem:(PLTabBarItemLayer *)item;

/**
 * \brief Return the tab item at an index in the tab bar.
 *
 * \param index The index.
 *
 * \return The tab item at `index`. Raises an exception if `index` it outside
 *         the bounds of the tab bar.
 */
-(PLTabBarItemLayer *)tabItemAtIndex:(NSUInteger)index;

/**
 * \brief Return the number of tabs in the tab bar.
 *
 * \return The number of tabs in the tab bar.
 */
-(NSUInteger)numberOfTabs;

#pragma mark - Tracking Areas

/**
 * \brief Return the tracking area associated with a tab item.
 *
 * \param item The tab item.
 *
 * \return The tracking area associated with a tab item or nil if `item` is not
 *         in the tab bar.
 *
 * \see setTrackingArea:forTabItem:
 */
-(NSTrackingArea *)trackingAreaForTabItem:(PLTabBarItemLayer *)item;

/**
 * \brief Set the tracking area for a tab item.
 *
 * \details Tab bar items are represented as `CALayer` objects. Therefore, if
 *          you are interested in tracking mouse movements over a tab item, set
 *          a `NSTrackingArea` associated with the tab item.
 *
 * \param trackingArea The tracking area.
 *
 * \param item The tab item.
 *
 * \see trackingAreaForTabItem:
 */
-(void)setTrackingArea:(NSTrackingArea *)trackingArea forTabItem:(PLTabBarItemLayer *)item;

@end

#pragma mark -

/**
 * \class PLTabBarItemLayer \headerfile \headerfile
 *
 * \brief Subclass of `CALayer` that controls visualization and aids interaction
 *        with tabs.
 *
 * \details This class adds a series of sublayers to design itself as a tab. It
 *          provides methods to set the tab's title and support for adding
 *          gradient colors as the tab color. Use the `containsPoint:` method to
 *          determine if a point lies within its masked area. Provides a
 *          `pointInCloseButton:` method to determine if a point falls within
 *          its sublayer representing a close button.
 */
@interface PLTabBarItemLayer : CALayer
{
        /**
         * \brief The background layer, masked to the tab path.
         */
        CAGradientLayer * backgroundLayer;
        
        /**
         * \brief The shadow layer.
         *
         * \details The `shadowPath` is the same path used to mask the
         *          `backgroundLayer`.
         */
        CAShapeLayer * shadowLayer;
        
        /**
         * \brief The layer used for the tab's title.
         */
        CATextLayer * titleLayer;
        
        /**
         * \brief The layer used to represent a close tab button.
         */
        CAShapeLayer * closeButtonLayer;
}

/**
 * \brief The tab's title.
 */
@property (assign) NSString * title;

/**
 * \brief The solid color used for the tab's background.
 *
 * \details This property is analogous to the `CALayer` `backgroundColor`
 *          property, but use this instead as it will respect the tab's mask
 *          shape. If a gradient is preferred, use the `colors` property
 *          instead, which will set this property to nil.
 *
 * \see colors
 */
@property (assign) CGColorRef color;

/**
 * \brief The array of colors used for the tab's gradient background.
 *
 * \details This property is analogous to the `CAGradientLayer` `colors`
 *          property. It takes an array of `CGColorRef`s that are used to create
 *          a gradient for the tab's background. If a solid color is preferred,
 *          use the `color` property instead, which will set this property to
 *          nil.
 *
 * \see color
 */
@property (assign) NSArray * colors;

/**
 * \brief Determines if the close button on the tab item is hidden. Defaults to
 *        YES.
 */
@property (assign) BOOL closeButtonHidden;

/**
 * \brief Emphasize the close button.
 *
 * \details This property may be used to highlight the close button when the
 *          user mouses over it. Highlighting the close button draws its lines
 *          with a thicker stroke. Defaults to NO.
 */
@property (nonatomic, assign) BOOL closeButtonHighlighted;

/**
 * \brief Determine if a point lies within the tab item's close button.
 *
 * \details The size of the close button hit area is slightly expanded from its
 *          displayed size.
 *
 * \param point A point in the receiver's coordinate system.
 *
 * \return YES if the point lies within the tab item's close button.
 */
-(BOOL)pointInCloseButton:(CGPoint)point;

@end

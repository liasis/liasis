/**
 * \file PLTabBar.m
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

#import "PLTabBar.h"

@implementation PLTabBar

#pragma mark - Object Lifecycle

-(instancetype)init
{
        self = [super init];
        if (self) {
                tabItemArray = [[NSMutableArray alloc] init];
                tabItems = [[NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory] retain];
                trackingAreas = [[NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableStrongMemory] retain];
        }
        return self;
}

-(void)dealloc
{
        self.activeTab = nil;
        [tabItemArray release];
        [tabItems release];
        [trackingAreas release];
        [super dealloc];
}

#pragma mark - Properties

-(NSArray *)tabItems
{
        return [NSArray arrayWithArray:tabItemArray];
}

#pragma mark - Adding, Removing, and Moving Tab Items

-(void)addTabItem:(PLTabBarItemLayer *)item withViewController:(NSViewController <PLTabSubviewController> *)viewController
{
        if ([tabItemArray containsObject:item] == NO) {
                [tabItemArray addObject:item];
                [tabItems setObject:viewController forKey:item];
        }
}

-(void)removeTabItem:(PLTabBarItemLayer *)item
{
        [tabItemArray removeObject:item];
        [tabItems removeObjectForKey:item];
        [trackingAreas removeObjectForKey:item];
}

-(void)moveTabItem:(PLTabBarItemLayer *)item toIndex:(NSUInteger)index
{
        [item retain];
        [tabItemArray removeObject:item];
        [tabItemArray insertObject:item atIndex:index];
        [item release];
}

#pragma mark - Querying Tab Items

-(NSViewController <PLTabSubviewController> *)viewControllerForTabItem:(PLTabBarItemLayer *)item
{
        return [tabItems objectForKey:item];
}

-(NSUInteger)indexOfTabItem:(PLTabBarItemLayer *)item
{
        return [tabItemArray indexOfObject:item];
}

-(PLTabBarItemLayer *)tabItemAtIndex:(NSUInteger)index
{
        return [tabItemArray objectAtIndex:index];
}

-(NSUInteger)numberOfTabs
{
        return [tabItemArray count];
}

#pragma mark - Tracking Areas

-(NSTrackingArea *)trackingAreaForTabItem:(PLTabBarItemLayer *)item
{
        return [trackingAreas objectForKey:item];
}

-(void)setTrackingArea:(NSTrackingArea *)trackingArea forTabItem:(PLTabBarItemLayer *)item
{
        [trackingAreas setObject:trackingArea forKey:item];
}

@end

#pragma mark -


@implementation PLTabBarItemLayer

#pragma mark - Object Lifecycle

/**
 * \brief Initialize the tab item layer.
 *
 * \details Create all sublayers, set their general properties, and add them
 *          to the tab item layer.
 *
 * \return A tab item layer.
 */
-(instancetype)init
{
        CGColorRef foregroundColor = NULL;
        
        self = [super init];
        if (self) {
                titleLayer = [[CATextLayer layer] retain];
                backgroundLayer = [[CAGradientLayer layer] retain];
                shadowLayer = [[CAShapeLayer layer] retain];
                closeButtonLayer = [[PLTabBarItemLayer createCloseButtonLayer] retain];
                
                /* Configure the shadow layer */
                shadowLayer.shadowOpacity = 0.4f;
                shadowLayer.shadowOffset = CGSizeMake(0.0f, 1.0f);
                shadowLayer.shadowRadius = 1.5f;
                
                /* Configure the title layer */
                foregroundColor = CGColorCreateGenericGray(0.0f, 1.0f);
                titleLayer.alignmentMode = kCAAlignmentCenter;
                titleLayer.truncationMode = kCATruncationEnd;
                titleLayer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
                titleLayer.fontSize = 12.0f;
                titleLayer.delegate = self;
                titleLayer.actions = @{@"contents": [NSNull null],       // disable implicit animation on setting its contents...
                                       @"contentsScale": [NSNull null]}; // ...and contents scale
                titleLayer.foregroundColor = foregroundColor;
                CGColorRelease(foregroundColor);
                
                /* Configure the close button layer */
                closeButtonLayer.frame = CGRectMake(20.0f,
                                                    8.0f,
                                                    closeButtonLayer.frame.size.width,
                                                    closeButtonLayer.frame.size.height);
                closeButtonLayer.hidden = YES;
                self.closeButtonHighlighted = NO;
                
                /* Add all sublayers */
                [self addSublayer:shadowLayer];
                [self addSublayer:backgroundLayer];
                [self addSublayer:titleLayer];
                [self addSublayer:closeButtonLayer];
        }
        return self;
}

/**
 * \brief Method used to initialize the layer used to identify where to
 *        click in order to close a tab.
 *
 * \details The method initializes the layer's size and adds a `CAShapeLayer` as
 *          as sublayer that represents a visual x-shape.
 *
 * \return The `CALayer` object used to represent the close tab action.
 */
+(CAShapeLayer *)createCloseButtonLayer
{
        CAShapeLayer * buttonLayer = nil;
        CGMutablePathRef linePath = NULL;
        CGColorRef strokeColor = NULL;
        
        /* Create button layer */
        buttonLayer = [CAShapeLayer layer];
        buttonLayer.frame = CGRectMake(0.0f, 0.0f, 8.0f, 8.0f);
        
        /* Define x-shaped path */
        linePath = CGPathCreateMutable();
        CGPathMoveToPoint(linePath, NULL, NSMinX([buttonLayer frame]), NSMinY([buttonLayer frame]));
        CGPathAddLineToPoint(linePath, NULL, NSMaxX([buttonLayer frame]), NSMaxY([buttonLayer frame]));
        CGPathMoveToPoint(linePath, NULL, NSMinX([buttonLayer frame]), NSMaxY([buttonLayer frame]));
        CGPathAddLineToPoint(linePath, NULL, NSMaxX([buttonLayer frame]), NSMinY([buttonLayer frame]));
        
        /* Create a shape layer using the x-shaped path and add as a sublayer */
        strokeColor = CGColorCreateGenericGray(0.0f, 1.0f);
        buttonLayer.path = linePath;
        buttonLayer.strokeColor = strokeColor;
        CGPathRelease(linePath);
        CGColorRelease(strokeColor);
        
        return buttonLayer;
}

/**
 * \brief Release all retained sublayers.
 */
-(void)dealloc
{
        [backgroundLayer release];
        [titleLayer release];
        [shadowLayer release];
        [closeButtonLayer release];
        [super dealloc];
}

#pragma mark - Delegate Methods

/**
 * \brief Delegate method to tell layers to inherit contents scale of windows.
 *
 * \details This method is called when a tab item is moved to a new window with
 *          a possibly different contents scale. It is currently used by the
 *          `titleLayer` to update its `contentsScale` property.
 *
 * \param layer The layer moving to a new window.
 *
 * \param newScale The contents scale for the new window.
 *
 * \param window The new window.
 *
 * \return Always YES.
 */
-(BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window
{
        return YES;
}

#pragma mark - Layout

/**
 * \brief Set the layout of all tab item sublayers.
 *
 * \details This method define the mask that creates the tab's shape
 *          and its shadow using the `CGPath` functions. It does nothing if
 *          `layer` is not a `PLTabBarItemLayer`.
 */
-(void)layoutSublayers
{
        CAShapeLayer * maskLayer = nil;
        CGMutablePathRef path;
        CGFloat endLength, xEdgeOffset, bottomRadius, topRadius;
        CGFloat x0, x1, x2, x3, y0, y1;
        NSPoint p0, p1, p2, p3, p4, p5;
        
        /* Define the tab's corner radii and its six vertices:
         *
         *           p2------------p3
         *          /                \
         *         /                  \
         * p0----p1                    p4----p5
         *
         */
        endLength = 5.0f;  // x length between points p0-p1 and p4-p5
        xEdgeOffset = 8.0f;  // x length between points p1-p2 and p3-p4
        bottomRadius = 6.0f;  // radius of arc at points p1 and p4
        topRadius = 7.0f;  // radius of arc at points p2 and p3
        
        x0 = NSMinX(self.bounds);
        x1 = NSMinX(self.bounds) + endLength;
        x2 = NSMaxX(self.bounds) - endLength;
        x3 = NSMaxX(self.bounds);
        y0 = NSMinY(self.bounds);
        y1 = NSMaxY(self.bounds) - 4.0f;
        
        p0 = NSMakePoint(x0, y0);
        p1 = NSMakePoint(x1, y0);
        p2 = NSMakePoint(x1 + xEdgeOffset, y1);
        p3 = NSMakePoint(x2 - xEdgeOffset, y1);
        p4 = NSMakePoint(x2, y0);
        p5 = NSMakePoint(x3, y0);
        
        /* Make the tab path and mask the layers */
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, p0.x, p0.y);
        CGPathAddArcToPoint(path, NULL, p1.x, p1.y, p2.x, p2.y, bottomRadius);
        CGPathAddArcToPoint(path, NULL, p2.x, p2.y, p3.x, p3.y, topRadius);
        CGPathAddArcToPoint(path, NULL, p3.x, p3.y, p4.x, p4.y, topRadius);
        CGPathAddArcToPoint(path, NULL, p4.x, p4.y, p5.x, p5.y, bottomRadius);
        
        maskLayer = [CAShapeLayer layer];
        maskLayer.path = path;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        backgroundLayer.mask = maskLayer;
        shadowLayer.shadowPath = path;
        shadowLayer.frame = self.bounds;
        backgroundLayer.frame = self.bounds;
        titleLayer.frame = CGRectMake(NSMaxX(closeButtonLayer.frame) + 1.0f,
                                      self.frame.origin.y + 4.0f,
                                      self.frame.size.width - 2 * (NSMaxX(closeButtonLayer.frame) + 1.0f),
                                      self.frame.size.height - 12.0f);
        [CATransaction commit];
        
        CGPathRelease(path);
        
exit:
        return;
}

#pragma mark - Hit Testing

/**
 * \brief Return's whether the tab contains a given point.
 *
 * \details This method overrides the `CALayer` method to return YES if the
 *          point falls within the masked area of the tab.
 *
 * \param The point in the receiver's coordinate system.
 *
 * \return YES if the point falls within the tab item.
 */
-(BOOL)containsPoint:(CGPoint)point
{
        return CGPathContainsPoint(shadowLayer.shadowPath, NULL, point, false);
}

-(BOOL)pointInCloseButton:(CGPoint)point
{
        CGRect hitRect = NSZeroRect;
        CGFloat offset = -3.0f;
        
        hitRect = CGRectInset(closeButtonLayer.frame, offset, offset);
        return CGRectContainsPoint(hitRect, point);
}

#pragma mark - Tab Properties

-(NSString *)title
{
        return titleLayer.string;
}

-(void)setTitle:(NSString *)title
{
        titleLayer.string = title;
}

-(CGColorRef)color
{
        return backgroundLayer.backgroundColor;
}

-(void)setColor:(CGColorRef)color
{
        backgroundLayer.colors = nil;
        backgroundLayer.backgroundColor = color;
}

-(NSArray *)colors
{
        return backgroundLayer.colors;
}

-(void)setColors:(NSArray *)colors
{
        backgroundLayer.backgroundColor = nil;
        backgroundLayer.colors = colors;
}

-(BOOL)closeButtonHidden
{
        return closeButtonLayer.hidden;
}

-(void)setCloseButtonHidden:(BOOL)closeButtonHidden
{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        closeButtonLayer.hidden = closeButtonHidden;
        [CATransaction commit];
}

-(void)setCloseButtonHighlighted:(BOOL)closeButtonHighlighted
{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        if (closeButtonHighlighted) {
                closeButtonLayer.lineWidth = 2.0f;
        } else {
                closeButtonLayer.lineWidth = 1.0f;
        }
        [CATransaction commit];
        _closeButtonHighlighted = closeButtonHighlighted;
}

@end

/**
 * \file PLTabBarView.h
 *
 * \brief Liasis Python IDE tab bar view.
 *
 * \details This file includes the tab bar `NSView` subclass and the protocol
 *          for a delegate of the tab bar.
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

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PLTabBarViewDelegate;

/**
 * \class PLTabBarView \headerfile \headerfile
 *
 * \brief Subclass of `NSView` that will display individual tab items.
 *
 * \details This class is responsible for notifying its delegate of mouseDown
 *          and mouseDragged events.
 *
 * \see PLTabViewController
 */
@interface PLTabBarView : NSView

/**
 * \brief The delegate that conforms to the PLTabViewDelegate protocol.
 */
@property (assign) id <PLTabBarViewDelegate> delegate;

@end

#pragma mark -

/** \protocol PLTabBarViewDelegate \headerfile \headerfile
 * \brief Protocol for a `PLTabBarView` delegate.
 *
 * \details The `PLTabBarView` delegate implements two methods that notify the
 *          delegate of mouseDown and and mouseDragged events.
 */
@protocol PLTabBarViewDelegate <NSObject>

/**
 * \brief Query the delegate if the tab bar should perform the mouse down event.
 *
 * \param theEvent The event passed to the `mouseDown:` method.
 *
 * \return A boolean denoting if the tab bar should perform the mouse down event
 *         or to ignore it if the delegate has handled the event.
 */
-(BOOL)shouldPerformMouseDownEvent:(NSEvent *)theEvent;

/**
 * \brief Query the delegate if the tab bar should perform the mouse dragged
 *        event.
 *
 * \param theEvent The event passed to the `mouseDragged:` method.
 *
 * \return A boolean denoting if the tab bar should perform the mouse dragged
 *         event or to ignore it if the delegate has handled the event.
 */
-(BOOL)shouldPerformMouseDraggedEvent:(NSEvent *)theEvent;

@end

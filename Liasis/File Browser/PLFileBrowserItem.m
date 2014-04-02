/**
 * \file PLFileBrowserItem.m
 *
 * \brief Liasis Python IDE file browser item.
 *
 * \details This class represents each item in the file browser tree.
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

#import "PLFileBrowserItem.h"

@implementation PLFileBrowserItem

#pragma mark - Object Lifecycle

-(instancetype)initWithRepresentedObject:(NSString *)fullPath
{
        self = [super initWithRepresentedObject:[fullPath lastPathComponent]];
        if (self) {
                _fullPath = [fullPath retain];
        }
        return self;
}

+(instancetype)treeNodeWithRepresentedObject:(NSString *)fullPath
{
        return [super treeNodeWithRepresentedObject:fullPath];
}

/**
 * \brief Release the `fullPath` property and call the superclass method.
 */
-(void)dealloc
{
        [_fullPath release];
        [super dealloc];
}

/**
 * \brief Get the children of the object.
 *
 * \details Children are all items within a directory with a .py extension that
 *          do not begin with a dot or are directories themselves.
 *
 * \return An array of `PLFileBrowserItem` objects or nil if the item is not a
 *         directory.
 */
-(NSArray *)childNodes
{
        NSMutableArray * children = nil;
        NSFileManager * fileManager = nil;
        NSArray * fileContents = nil;
        PLFileBrowserItem * newChild = nil;
        BOOL isDir = NO, fileExists = NO, childIsDir = NO;
        
        fileManager = [NSFileManager defaultManager];
        fileExists = [fileManager fileExistsAtPath:self.fullPath isDirectory:&isDir];
        
        if (fileExists && isDir) {
                fileContents = [fileManager contentsOfDirectoryAtPath:self.fullPath error:NULL];
                children = [NSMutableArray array];
                for (NSString * name in fileContents) {
                        [fileManager fileExistsAtPath:[self.fullPath stringByAppendingPathComponent:name]
                                          isDirectory:&childIsDir];
                        if ([name characterAtIndex:0] != '.' && (childIsDir || [[name pathExtension] isEqualToString:@"py"])) {
                                newChild = [PLFileBrowserItem treeNodeWithRepresentedObject:[self.fullPath stringByAppendingPathComponent:name]];
                                [children addObject:newChild];
                        }
                }
        }
        return children;
}

@end

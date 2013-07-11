//
//  PXRectangle.h
//  PXEngine
//
//  Created by Kevin Lindsey on 5/30/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PXEngine/PXShape.h>
#import <PXEngine/PXBoundable.h>
#import <PXEngine/PXCornerRadius.h>

/**
 *  A PXShape sub-class used to render rectangles
 */
@interface PXRectangle : PXShape <PXBoundable>

/**
 *  The size (width and height) of this rectangle
 */
@property (nonatomic) CGSize size;

/**
 *  The x-coordinate of the top-left corner of this rectangle
 */
@property (nonatomic) CGFloat x;

/**
 *  The y-coordinate of the top-left corner of this rectangle
 */
@property (nonatomic) CGFloat y;

/**
 *  The width of this rectangle
 */
@property (nonatomic) CGFloat width;

/**
 *  The height of this rectangle
 */
@property (nonatomic) CGFloat height;

/**
 *  The x-radius of the rounded corners of this rectangle
 */
@property (nonatomic) PXCornerRadius *cornerRadius;

/**
 *  Initializes a newly allocated rectangle using the specified bounds
 *
 *  @param bounds The bounds point of the rectangle
 */
- (id)initWithRect:(CGRect)bounds;

/**
 *  Initializes a newly allocated rectangle using the specified bounds and rounds the corners with the specified radius
 *
 *  @param bounds The bounds point of the rectangle
 *  @param radius The radius of the rounded corners of the rectangle
 *
- (id)initWithRect:(CGRect)bounds radius:(CGFloat)radius;

**
 *  Initializes a newly allocated rectangle using the specified bounds and rounds the corners with the specified radii
 *
 *  @param bounds The bounds point of the rectangle
 *  @param radii The x- and y-radii of the rounded corners of the rectangle
 *
- (id)initWithRect:(CGRect)bounds radii:(CGSize)radii;
*/
@end

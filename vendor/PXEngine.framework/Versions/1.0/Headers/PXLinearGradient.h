//
//  PXLinearGradient.h
//  PXEngine
//
//  Created by Kevin Lindsey on 6/8/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PXEngine/PXPaint.h>
#import <PXEngine/PXGradient.h>

/**
 *  PXLinearGradient is an implementation of a linear gradient. Linear gradients may be specified by an angle, or by two
 *  user-defined points.
 */
@interface PXLinearGradient : PXGradient

/**
 *  The angle to be used when calculating the rendering of this gradient
 */
@property (nonatomic) CGFloat angle;

/**
 *  Angles in iOS and CSS differ. This is a convenience property that allows angles to follow the CSS specification's
 *  definition of an angle
 */
@property (nonatomic) CGFloat cssAngle;

/**
 *  The first point in the gradient
 */
@property (nonatomic) CGPoint p1;

/**
 *  The last point in the gradient
 */
@property (nonatomic) CGPoint p2;

/**
 *  Allocate and initialize a new linear gradient using the specified starting and ending colors
 *
 *  @param startColor The starting color of this gradient
 *  @param endColor The ending color of this gradient
 */
+ (PXLinearGradient *)gradientFromStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end

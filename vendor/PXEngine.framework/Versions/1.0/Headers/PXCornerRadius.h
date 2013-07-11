//
//  PXCornerRadius.h
//  PXEngine
//
//  Created by Kevin Lindsey on 12/17/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXCornerRadius : NSObject

@property (nonatomic, readonly) CGSize topLeft;
@property (nonatomic, readonly) CGSize topRight;
@property (nonatomic, readonly) CGSize bottomRight;
@property (nonatomic, readonly) CGSize bottomLeft;
@property (nonatomic, readonly) BOOL hasRadius;

- (id)initWithRadius:(CGFloat)radius;
- (id)initWithRadiusX:(CGFloat)radiusX radiusY:(CGFloat)radiusY;
- (id)initWithRadiusSize:(CGSize)radii;
- (id)initWithTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomRight:(CGFloat)bottomRight bottomLeft:(CGFloat)bottomLeft;
- (id)initWithTopLeftSize:(CGSize)topLeft topRight:(CGSize)topRight bottomRight:(CGSize)bottomRight bottomLeft:(CGSize)bottomLeft;

@end

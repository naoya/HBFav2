//
//  PXEngineConfiguration.h
//  PXEngine
//
//  Created by Kevin Lindsey on 1/23/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PXStyleable.h"

/**
 *  A PXParseErrorDestination enumeration captures the various parse error logging destinations. These are set using the
 *  parse-error-destination property for the pixate-config element.
 */
typedef enum {
    PXParseErrorDestinationNone,
    PXParseErrorDestinationConsole,
#ifdef PX_LOGGING
    PXParseErrorDestination_Logger
#endif
} PXParseErrorDestination;

/**
 *  A PXUpdateStylesType enumeration determines if the PXEngine will try to automatically style views.
 */
typedef enum {
    PXUpdateStylesTypeAuto,
    PXUpdateStylesTypeManual,
} PXUpdateStylesType;

/**
 *  A PXCacheStylesType enumeration determines if the PXEngine will try to cache styling.
 */
typedef enum {
    PXCacheStylesTypeAuto,
    PXCacheStylesTypeNone,
} PXCacheStylesType;

/**
 *  The PXEngineConfiguration class is used to set and retrieve global settings for the PXEngine.
 */
@interface PXEngineConfiguration : NSObject <PXStyleable>

/**
 *  Allow a style id to be associated with this object
 */
@property (nonatomic, copy) NSString *styleId;

/**
 *  Allow a style class to be associated with this object
 */
@property (nonatomic, copy) NSString *styleClass;

/**
 *  Determine where parse errors will be emitted
 */
@property (nonatomic) PXParseErrorDestination parseErrorDestination;

/**
 *  Determine when views should have their style updated
 */
@property (nonatomic) PXUpdateStylesType updateStylesType;

/**
 *  Determine if view styling is cached
 */
@property (nonatomic) PXCacheStylesType cacheStylesType;

/*
 *  Return the property value for the specifified property name
 *
 *  @param name The name of the property
 */
- (id)propertyValueForName:(NSString *)name;

/*
 *  Set the property value for the specified property name
 *
 *  @param value The new value
 *  @param name The property name
 */
- (void)setPropertyValue:(id)value forName:(NSString *)name;

/**
 *  Log the specified message to the target indicated by the loggingType property
 *
 *  @param message The message to emit
 */
- (void)sendParseMessage:(NSString *)message;

@end

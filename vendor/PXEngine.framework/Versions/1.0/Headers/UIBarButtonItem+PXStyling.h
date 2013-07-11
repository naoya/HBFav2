//
//  UIBarButtonItem+PXStyling.h
//  PXEngine
//
//  Created by Kevin Lindsey on 12/11/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PXEngine/PXVirtualControl.h>

/**
 *
 *  UIBarButtonItem supports the following element name:
 *
 *  - bar-button-item
 *
 *  UIBarButtonItem supports the following properties:
 *
 *  - PXFillStyler
 *  - PXBorderStyler
 *  - PXTextContentStyler
 *
 */
@interface UIBarButtonItem (PXStyling) <PXVirtualControl>

// make styleParent writeable here
@property (nonatomic, readwrite, copy) id pxStyleParent;

@end

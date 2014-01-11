//
//  HTMLPurifier_AttrDef_Length.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

/**
 * Represents a Length as defined by CSS.
 */

@class HTMLPurifier_Length;

@interface HTMLPurifier_AttrDef_Length : HTMLPurifier_AttrDef
{

    /**
     * @type HTMLPurifier_Length|string
     */
    HTMLPurifier_Length* min;

    /**
     * @type HTMLPurifier_Length|string
     */
    HTMLPurifier_Length* max;
}

- (id)initWithMin:(HTMLPurifier_Length*)newMin max:(HTMLPurifier_Length*)newMax;

- (id)init;

- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;


@end

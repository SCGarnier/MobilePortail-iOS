//
//  PaddedTextField.m
//  App Installer
//
//  Created by AppleBetas on 2017-07-02.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "PaddedTextField.h"

#define kPaddedTextFieldInsets UIEdgeInsetsMake(0, 32, 0, 32)

@implementation PaddedTextField

-(CGRect)textRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], kPaddedTextFieldInsets);
}

-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], kPaddedTextFieldInsets);
}

-(CGRect)editingRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect([super textRectForBounds:bounds], kPaddedTextFieldInsets);
}

@end

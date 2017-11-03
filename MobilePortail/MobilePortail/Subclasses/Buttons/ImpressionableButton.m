//
//  ImpressionableButton.m
//  App Installer
//
//  Created by AppleBetas on 2017-07-02.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "ImpressionableButton.h"

@implementation ImpressionableButton

-(void)didMoveToWindow
{
    [super didMoveToWindow];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setColours];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = highlighted ? 0.8f : 1.0f;
    }];
}

-(void)setColours
{
    self.backgroundColor = self.tintColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end

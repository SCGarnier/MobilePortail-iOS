//
//  RoundedView.m
//  Impeached
//
//  Created by Justin Proulx on 2017-08-24.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "RoundedView.h"

@implementation RoundedView

- (void)layoutSubviews
{
    ///self.layer.borderWidth = 10;
    //self.layer.borderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0].CGColor;
    self.layer.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0].CGColor;
    self.layer.masksToBounds = YES;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 7.0f);
    self.layer.shadowOpacity = 0.2f;
    //self.layer.borderWidth = 4;
    //self.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self doEdgeRadius];
}

-(void)doEdgeRadius
{
    self.layer.cornerRadius = self.bounds.size.width / 6;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

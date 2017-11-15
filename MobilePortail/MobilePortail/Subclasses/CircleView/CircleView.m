//
//  RoundedView.m
//  Impeached
//
//  Created by Justin Proulx on 2017-08-24.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (void)layoutSubviews
{

    self.layer.masksToBounds = YES;
    
    [self doEdgeRadius];
}

-(void)doEdgeRadius
{
    self.layer.cornerRadius = self.frame.size.width/2;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

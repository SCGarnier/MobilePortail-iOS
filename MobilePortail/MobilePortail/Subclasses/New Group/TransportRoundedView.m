//
//  TransportRoundedView.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-12-16.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "TransportRoundedView.h"

@implementation TransportRoundedView

- (void)layoutSubviews
{
    
    [self doEdgeRadius];
}

-(void)doEdgeRadius
{
    self.layer.cornerRadius = self.frame.size.width / 12;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

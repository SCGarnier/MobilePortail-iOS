//
//  BeautifulTableViewCell.m
//  Speed Math
//
//  Created by Justin Proulx on 2017-08-16.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

//  This TableViewCell is not selectable. Just build a new one if you need to select it.

#import "BeautifulTableViewCell.h"

@implementation BeautifulTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self doCircleRadius];
    [self setTintColor:[UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:1.0]];
    [self setColours];
    
    self.layer.masksToBounds = YES;
}


- (void)setFrame:(CGRect)frame
{
    //seperate cells
    frame.origin.y += 8;
    frame.size.height -= 2 * 8;
    
    //inset cells from edges
    frame.origin.x += 16;
    frame.size.width -=2 * 16;
    
    [super setFrame:frame];
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setColours];
}

-(void)setColours
{
    self.backgroundColor = self.tintColor;
    self.textLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.textColor = [UIColor whiteColor];
}

- (void)doCircleRadius
{
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 4;
}

@end

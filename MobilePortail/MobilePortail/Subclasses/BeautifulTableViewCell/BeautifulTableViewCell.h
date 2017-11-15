//
//  BeautifulTableViewCell.h
//  Speed Math
//
//  Created by Justin Proulx on 2017-08-16.
//  Copyright © 2017 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeautifulTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *classLabel;
@property (nonatomic, weak) IBOutlet UILabel *teacherLabel;
@property (nonatomic, weak) IBOutlet UILabel *resultLabel;
@property (nonatomic, weak) IBOutlet UIView *circleView;

@end

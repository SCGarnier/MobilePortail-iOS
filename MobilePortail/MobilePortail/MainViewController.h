//
//  MainViewController.h
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-30.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "ViewController.h"
#import <SafariServices/SafariServices.h>

@interface MainViewController : UITableViewController
{
    IBOutlet UILabel *usernameLabel;
    
    IBOutlet UILabel *period1Class;
    IBOutlet UILabel *period1Teacher;
    
    IBOutlet UILabel *period2Class;
    IBOutlet UILabel *period2Teacher;
    
    IBOutlet UILabel *period3Class;
    IBOutlet UILabel *period3Teacher;
    
    IBOutlet UILabel *period4Class;
    IBOutlet UILabel *period4Teacher;
    
    IBOutlet UITableView *TableView;
    
    IBOutlet UILabel *busStatusLabel;
    IBOutlet UILabel *schoolStatusLabel;
    
    IBOutlet UIView *busStatusView;
    IBOutlet UIView *schoolStatusView;
    
    BOOL isConnectedToInternet;
    
    @public BOOL cancelRefresh;
    
    float timerPeriod;
    
    int updateNumber;
    
    IBOutlet UITableViewCell *snowDayRow;
    
    BOOL shouldIBeUpdating;
}

- (void)deleteOldData;
- (BOOL)checkForAuthentification;

@end

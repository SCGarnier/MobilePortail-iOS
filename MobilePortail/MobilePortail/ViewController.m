//
//  ViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-18.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "ViewController.h"
#import "BlackSFSafariViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)support:(UIButton *)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=JustinAlexP"]];
    }
    else
    {
        BlackSFSafariViewController *safari = [[BlackSFSafariViewController alloc] initWithURL:[NSURL URLWithString: @"https://twitter.com/JustinAlexP"] entersReaderIfAvailable:NO];
        [self presentViewController:safari animated:YES completion:nil];
    }
}


@end

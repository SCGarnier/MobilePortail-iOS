//
//  ViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-18.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "ViewController.h"
#import "MPRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)login:(id)sender
{
    // username string
    NSString *username = usernameTextField.text;
    
    // password string
    NSString *password = passwordTextField.text;

    MPRequest *request = [MPRequest new];
    //request for class results
    [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx" withUsername:username andPassword:password saveResponseToFileName:@"resultdata.html"];
    //request for schedule
    [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx?ReturnUrl=%2fPortailEleves%2fEmploiDuTemps.aspx" withUsername:username andPassword:password saveResponseToFileName:@"schedule.html"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

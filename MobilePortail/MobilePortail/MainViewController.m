//
//  MainViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-30.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "MPRequest.h"
#import "SAMKeychain.h"
#import "SAMKeychainQuery.h"
#import "MPStringFromHTML.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self checkForAuthentification];
}

- (void)checkForAuthentification
{
    //retrieve saved login info
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    NSString *savedPassword = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
    
    
    if ([savedUsername length] == 0 || [savedPassword length] == 0)
    {
        //if there is some missing saved info, open the login screen
        [self openLoginPage];
    }
    else
    {
        //if all the login info is saved, try to log in
        
        MPRequest *request = [MPRequest new];
        //request for class results
        [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx" withUsername:savedUsername andPassword:savedPassword saveResponseToFileName:@"resultdata.html" isMainRequest:YES isAutoLogin:YES];
        //request for schedule
        [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx?ReturnUrl=%2fPortailEleves%2fEmploiDuTemps.aspx" withUsername:savedUsername andPassword:savedPassword saveResponseToFileName:@"schedule.html" isMainRequest:NO isAutoLogin:YES];
        
        
    }
}

- (void)openLoginPage
{
    ViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self presentViewController:login animated:YES completion:nil];
}

- (NSString *)getDayNumberText:(NSString *)dayNumberText
{
    MPStringFromHTML *getString = [MPStringFromHTML new];
    
    //get string from data
    NSString *rawHTML = [getString getStringFromHTMLWithFileName:@"schedule"];
    
    
    
    return dayNumberText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

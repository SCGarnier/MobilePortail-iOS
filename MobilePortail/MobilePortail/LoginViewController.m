//
//  LoginViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-30.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "LoginViewController.h"
#import "MPRequest.h"
#import "SAMKeychain.h"
#import "SAMKeychainQuery.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    //retrieve saved info and then put them in the textfields
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    usernameTextField.text = savedUsername;
    passwordTextField.text = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)login:(id)sender
{
    // username string
    NSString *username = usernameTextField.text;
    
    // password string
    NSString *password = passwordTextField.text;
    
    MPRequest *request = [MPRequest new];
    //request for class results
    [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx" withUsername:username andPassword:password saveResponseToFileName:@"resultdata.html" isMainRequest:YES isAutoLogin:NO];
    //request for schedule
    [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx?ReturnUrl=%2fPortailEleves%2fEmploiDuTemps.aspx" withUsername:username andPassword:password saveResponseToFileName:@"schedule.html" isMainRequest:NO isAutoLogin:NO];
    
    //save login info
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"PortailUsername"];
    [SAMKeychain setPassword:password forService:@"Portail" account:username];
    
    
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

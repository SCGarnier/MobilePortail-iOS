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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:Nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
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

#pragma mark - keyboard stuff

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)keyboardWasShown:(NSNotification *)notif
{
    CGSize keyboardSize = [[[notif userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    position = squircleView.frame.origin.y;
    
    [UIView animateWithDuration:0.35 animations:^
     {
         squircleView.frame = CGRectMake(squircleView.frame.origin.x, position - keyboardSize.height/2, squircleView.frame.size.width, squircleView.frame.size.height);
         
         titleLabel.alpha = 0;
     }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
    
}
/*
- (void)keyboardWasHidden:(NSNotification *)notif
{
    [UIView animateWithDuration:0.35 animations:^
     {
         squircleView.frame = CGRectMake(squircleView.frame.origin.x, position, squircleView.frame.size.width, squircleView.frame.size.height);
         
         titleLabel.alpha = 1;
     }];
    
    position = squircleView.frame.origin.y;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:Nil];
}*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

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
#import "HTMLReader.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    
    self.navigationController.navigationBar.prefersLargeTitles = true;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self checkForAuthentification];
    
    usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
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
        
        NSArray *schedule = [self DaySchedule];
        
    }
}

- (void)openLoginPage
{
    ViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self presentViewController:login animated:YES completion:nil];
}

- (NSMutableArray *)DaySchedule
{
    NSMutableArray *schedule = [[NSMutableArray alloc] init];
    
    MPStringFromHTML *getString = [MPStringFromHTML new];
    
    //get string from data
    NSString * rawHTML = [getString getStringFromHTMLWithFileName:@"schedule.html"];
    
    //get document for parsing from the string
    HTMLDocument * schedulePage = [HTMLDocument documentWithString:rawHTML];
    
    HTMLNode *scheduleTable = [schedulePage firstNodeMatchingSelector:@"table.text"];
    
    HTMLNode *actualTable = [scheduleTable childAtIndex:1];
    
    HTMLNode * periodOneList = [actualTable childAtIndex:1];
    HTMLNode * periodTwoList = [actualTable childAtIndex:2];
    HTMLNode * periodThreeList = [actualTable childAtIndex:3];
    HTMLNode * periodFourList = [actualTable childAtIndex:4];
    
    int dayNumber = [self currentDayNumberWithPeriodOne:periodOneList andPeriodTwo:periodTwoList andPeriodThree:periodThreeList andPeriodFour:periodFourList];
    
    if (dayNumber == 0)
    {
        //say there's no school
        self.navigationItem.title = @"Pas de cours";
    }
    else
    {
        //set title to day number
        self.navigationItem.title = [@"Jour " stringByAppendingString:[NSString stringWithFormat:@"%d", dayNumber]];
        
        NSOrderedSet *periodOneClassInfo = [[[[[periodOneList children] objectAtIndex:dayNumber] children] objectAtIndex:0] children];
        NSOrderedSet *periodTwoClassInfo = [[[[[periodTwoList children] objectAtIndex:dayNumber] children] objectAtIndex:0] children];
    }
    
    
    
    
    
    //NSLog(@"%@", periodOneClassInfo);
    
    return schedule;
}

- (int)currentDayNumberWithPeriodOne:(HTMLNode *)pOne andPeriodTwo:(HTMLNode *)pTwo andPeriodThree:(HTMLNode *)pThree andPeriodFour:(HTMLNode *)pFour
{
    int dayNumber;
    BOOL foundCurrentDay = NO;
    
    NSDictionary *dataDict = [self searchClassesForDayNumberWithPeriod:pOne];
    foundCurrentDay = [[dataDict objectForKey:@"foundCurrentDay"] boolValue];
    
    if (!foundCurrentDay)
    {
        dataDict = [self searchClassesForDayNumberWithPeriod:pTwo];
        foundCurrentDay = [[dataDict objectForKey:@"foundCurrentDay"] boolValue];
    }
    
    if (!foundCurrentDay)
    {
        NSDictionary *dataDict = [self searchClassesForDayNumberWithPeriod:pThree];
        foundCurrentDay = [[dataDict objectForKey:@"foundCurrentDay"] boolValue];
    }
    
    if (!foundCurrentDay)
    {
        NSDictionary *dataDict = [self searchClassesForDayNumberWithPeriod:pFour];
        foundCurrentDay = [[dataDict objectForKey:@"foundCurrentDay"] boolValue];
    }
    
    dayNumber = [[dataDict objectForKey:@"dayNumber"] intValue];
    
    return dayNumber;
}

- (NSDictionary *)searchClassesForDayNumberWithPeriod:(HTMLNode *)period
{
    int dayNumber = 0;
    BOOL foundCurrentDay = NO;
    
    NSOrderedSet *classList = [period children];
    
    for (id item in classList)
    {
        HTMLNode * currentColumn = [period childAtIndex:[classList indexOfObject:item]];
        
        if ([[currentColumn innerHTML] containsString:@"<b>"])
        {
            foundCurrentDay = YES;
            dayNumber = (int)[classList indexOfObject:item] - 1;
        }
    }
    
    NSDictionary * dataDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:dayNumber], @"dayNumber", [NSNumber numberWithBool:foundCurrentDay], @"foundCurrentDay", nil];
    
    return dataDict;
}




- (IBAction)logout:(id)sender
{
    [self openLoginPage];
    
    //delete saved password
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    [SAMKeychain deletePasswordForService:@"Portail" account:username];
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

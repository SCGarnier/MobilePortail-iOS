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

#pragma mark - Loading
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

#pragma mark - Authentification
- (void)openLoginPage
{
    ViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self presentViewController:login animated:YES completion:nil];
}

- (IBAction)logout:(id)sender
{
    [self openLoginPage];
    
    //delete saved password
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    [SAMKeychain deletePasswordForService:@"Portail" account:username];
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
        
        
        //get and display info after login
        NSArray *schedule = [self DaySchedule];
        
        //display period 1
        period1Class.text = [[schedule objectAtIndex:0] objectForKey:@"courseName"];
        period1Teacher.text = [[schedule objectAtIndex:0] objectForKey:@"teacherName"];
        
        if ([period1Class.text length] == 0)
        {
            period1Class.text = @"Aucun cours";
        }
        
        if ([period1Teacher.text length] == 0) {
            period1Teacher.text = @"Aucun enseignant";
        }
        
        //display period 2
        period2Class.text = [[[[[schedule objectAtIndex:1] objectForKey:@"courseName"] stringByAppendingString:@" ("] stringByAppendingString:[[schedule objectAtIndex:1] objectForKey:@"courseCode"]] stringByAppendingString:@")"];
        period2Teacher.text = [[schedule objectAtIndex:1] objectForKey:@"teacherName"];
        
        if ([period2Class.text length] == 0)
        {
            period2Class.text = @"Aucun cours";
        }
        
        if ([period2Teacher.text length] == 0)
        {
            period2Teacher.text = @"Aucun enseignant";
        }
        //display period 3
        period3Class.text = [[[[[schedule objectAtIndex:2] objectForKey:@"courseName"] stringByAppendingString:@" ("] stringByAppendingString:[[schedule objectAtIndex:2] objectForKey:@"courseCode"]] stringByAppendingString:@")"];
        period3Teacher.text = [[schedule objectAtIndex:2] objectForKey:@"teacherName"];
        
        if ([period3Class.text length] == 0)
        {
            period3Class.text = @"Aucun cours";
        }
        
        if ([period3Teacher.text length] == 0)
        {
            period3Teacher.text = @"Aucun enseignant";
        }
        
        //display period 4
        period4Class.text = [[[[[schedule objectAtIndex:3] objectForKey:@"courseName"] stringByAppendingString:@" ("] stringByAppendingString:[[schedule objectAtIndex:3] objectForKey:@"courseCode"]] stringByAppendingString:@")"];
        period4Teacher.text = [[schedule objectAtIndex:3] objectForKey:@"teacherName"];
        
        if ([period4Class.text length] == 0)
        {
            period4Class.text = @"Aucun cours";
        }
        
        if ([period4Teacher.text length] == 0)
        {
            period4Teacher.text = @"Aucun enseignant";
        }
    }
}


#pragma mark - Schedule related things
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
        schedule = nil;
    }
    else
    {
        //set title to day number
        self.navigationItem.title = [@"Jour " stringByAppendingString:[NSString stringWithFormat:@"%d", dayNumber]];
        
        //set up the ordered sets for all the class info
        NSOrderedSet *periodOneClassInfo = [self getClassInfoWithOverviewList:periodOneList andDayNumber:dayNumber];
        NSOrderedSet *periodTwoClassInfo = [self getClassInfoWithOverviewList:periodTwoList andDayNumber:dayNumber];
        NSOrderedSet *periodThreeClassInfo = [self getClassInfoWithOverviewList:periodThreeList andDayNumber:dayNumber];
        NSOrderedSet *periodFourClassInfo = [self getClassInfoWithOverviewList:periodFourList andDayNumber:dayNumber];
        
        
        //get useful information for classes
        NSDictionary *periodOneInfoArray = [self getClassInfoArrayFromClassInfoOrderedSet:periodOneClassInfo];
        NSDictionary *periodTwoInfoArray = [self getClassInfoArrayFromClassInfoOrderedSet:periodTwoClassInfo];
        NSDictionary *periodThreeInfoArray = [self getClassInfoArrayFromClassInfoOrderedSet:periodThreeClassInfo];
        NSDictionary *periodFourInfoArray = [self getClassInfoArrayFromClassInfoOrderedSet:periodFourClassInfo];
        
        
        schedule = [NSMutableArray arrayWithObjects:periodOneInfoArray, periodTwoInfoArray, periodThreeInfoArray, periodFourInfoArray, nil];
    }
    
    return schedule;
}

- (NSDictionary *)getClassInfoArrayFromClassInfoOrderedSet:(NSOrderedSet *)classInfoOrderedSet
{
    NSDictionary *classInfoDict = [[NSDictionary alloc] init];
    
    if ([classInfoOrderedSet count] > 0)
    {
        //get course info
        NSString *teacherName = [[classInfoOrderedSet objectAtIndex:3] textContent];
        NSString *courseCode = [[classInfoOrderedSet objectAtIndex:1] textContent];
        NSString *courseName = [[[classInfoOrderedSet objectAtIndex:0] childAtIndex:0] textContent];
        
        //add course info to array
        classInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:teacherName, @"teacherName", courseCode, @"courseCode", courseName, @"courseName", nil];
    }
    else
    {
        classInfoDict = [[NSDictionary alloc] init];;
    }
    
    
    return classInfoDict;
}

- (NSOrderedSet *)getClassInfoWithOverviewList:(HTMLNode *)classOverview andDayNumber:(int)dayNumber
{
    NSOrderedSet * classInfo = [[NSOrderedSet alloc] init];
    
    NSOrderedSet * classHead = [[[classOverview children] objectAtIndex:dayNumber+1] children];
    if ([classHead count] > 0)
    {
        classInfo = [[[[[classOverview children] objectAtIndex:dayNumber + 1] children] objectAtIndex:0] children];
    }
    
    return classInfo;
}

- (int)currentDayNumberWithPeriodOne:(HTMLNode *)pOne andPeriodTwo:(HTMLNode *)pTwo andPeriodThree:(HTMLNode *)pThree andPeriodFour:(HTMLNode *)pFour
{
    int dayNumber;
    BOOL foundCurrentDay = NO;
    
    NSDictionary *dataDict = [[NSDictionary alloc] init];
    
    NSArray *periodArray = [NSArray arrayWithObjects:pOne, pTwo, pThree, pFour, nil];
    int index = 0;
    
    while (!foundCurrentDay)
    {
        dataDict = [self searchClassesForDayNumberWithPeriod:[periodArray objectAtIndex:index]];
        foundCurrentDay = [[dataDict objectForKey:@"foundCurrentDay"] boolValue];
        
        index++;
        
        if (index >= [periodArray count])
        {
            dayNumber = -1;
            break;
        }
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




#pragma mark - Other

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

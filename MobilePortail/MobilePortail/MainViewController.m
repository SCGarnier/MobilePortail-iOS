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
#import "Reachability.h"
#import "BlackSFSafariViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) NSData *cachedPassword;

@end

@implementation MainViewController

#pragma mark - Loading
- (void)viewDidLoad
{
    shouldIBeUpdating = YES;
    
    MPRequest *request = [MPRequest new];
    BOOL isLoggedIn = [request checkForSuccessfulLogin:@"resultdata.html" isMainRequest:YES isAutoLogin:YES];
    if (isLoggedIn)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(midnightRefresh) name:NSCalendarDayChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStuff) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    }
    
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    NSString *savedPassword = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
    
    _cachedPassword = [savedPassword dataUsingEncoding:NSUTF8StringEncoding];
    
    //sets the name to your username
    usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    
    //sexy title
    if (@available(iOS 11.0, *))
    {
        self.navigationController.navigationBar.prefersLargeTitles = true;
    }
    else
    {
        // Fallback on earlier versions
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
     */
    
    [self refreshTableView];
}

- (BOOL)checkForInternet
{
    //check for internet
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == ReachableViaWiFi || networkStatus == ReachableViaWWAN)
    {
        isConnectedToInternet = YES;
        return YES;
    }
    else
    {
        isConnectedToInternet = NO;
        return NO;
    }
}

- (void)deleteOldData
{
    [self checkForInternet];
    
    if (isConnectedToInternet)
    {
        MPRequest *request = [MPRequest new];
        [request deleteOldData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    shouldIBeUpdating = YES;
    
    BOOL isOnline = [self checkForInternet];
    
    [self checkForAuthentification];
    
    MPRequest *request = [MPRequest new];
    BOOL isLoggedIn = [request checkForSuccessfulLogin:@"resultdata.html" isMainRequest:YES isAutoLogin:YES];
    if (isLoggedIn && isOnline)
    {
        [self updateStuff];
    }
    
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    NSString *savedPassword = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
    if ([savedPassword length] != 0 && [savedUsername length] != 0)
    {
        [self updateScheduleInfo];
    }
    
    usernameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    
    [self refreshTableView];
}

#pragma mark - Authentification
- (void)openLoginPage
{
    ViewController *login = [self.storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self presentViewController:login animated:YES completion:nil];
}

- (IBAction)logout:(id)sender
{
    shouldIBeUpdating = NO;
    
    //delete saved password
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    [SAMKeychain deletePasswordForService:@"Portail" account:username];
    
    //delete mark info
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentMarks"];
    
    [self deleteOldData];
    
    //open login page only after cleaning out all the saved data
    [self openLoginPage];
    return;
}

- (void)logOutLogIn
{
    shouldIBeUpdating = NO;
    //delete mark info
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentMarks"];
    
    [self deleteOldData];
    
    [self viewDidLoad];
    [self viewDidAppear:YES];
}

- (BOOL)checkForAuthentification
{
    //retrieve saved login info
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    NSString *savedPassword = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
    
    //fix for log out issue. While the app is waiting for the keychain to become available after coming back into the foreground, just use the cached copy of it.
    if ([savedPassword length] == 0)
    {
        savedPassword = [[NSString alloc] initWithData:_cachedPassword encoding:NSUTF8StringEncoding];
    }
    else
    {
        _cachedPassword = [savedPassword dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    BOOL isOnline = [self checkForInternet];
    
    if (isOnline)
    {
        if ([savedUsername length] == 0 || [savedPassword length] == 0)
        {
            //if there is some missing saved info, open the login screen
            [self deleteOldData];
            [self openLoginPage];
            return NO;
        }
        else
        {
            //if all the login info is saved, try to log in
            
            MPRequest *request = [MPRequest new];
            //request for class results
            [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx" withUsername:savedUsername andPassword:savedPassword saveResponseToFileName:@"resultdata.html" isMainRequest:NO isAutoLogin:YES expectsPDF:NO showErrors:NO];
            //request for schedule
            [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx?ReturnUrl=%2fPortailEleves%2fEmploiDuTemps.aspx" withUsername:savedUsername andPassword:savedPassword saveResponseToFileName:@"schedule.html" isMainRequest:NO isAutoLogin:YES expectsPDF:NO showErrors:NO];
            
            //download snow day data
            [request downloadSnowDayData];
            
            //fail check one last time in case it missed it
            BOOL isLoggedIn = [request checkForSuccessfulLogin:@"resultdata.html" isMainRequest:YES isAutoLogin:YES];
            
            if (!isLoggedIn)
            {
                [self logout:nil];
            }
            else
            {
                [self updateScheduleInfo];
            }
            
            return isLoggedIn;
        }
    }
    else
    {
        return NO;
    }
    
}

#pragma mark - Refreshing things
- (void)updateScheduleInfo
{
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
    period2Class.text = [[schedule objectAtIndex:1] objectForKey:@"courseName"];
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
    period3Class.text = [[schedule objectAtIndex:2] objectForKey:@"courseName"];
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
    period4Class.text = [[schedule objectAtIndex:3] objectForKey:@"courseName"];
    period4Teacher.text = [[schedule objectAtIndex:3] objectForKey:@"teacherName"];
    
    if ([period4Class.text length] == 0)
    {
        period4Class.text = @"Aucun cours";
    }
    
    if ([period4Teacher.text length] == 0)
    {
        period4Teacher.text = @"Aucun enseignant";
    }
    
    //snow day things
    NSArray *snowDayArray = [self getSnowDayStatus];
    
    @try
    {
        schoolStatusLabel.text = [snowDayArray objectAtIndex:0];
        busStatusLabel.text = [snowDayArray objectAtIndex:1];
    }
    @catch (NSException *exception)
    {
        schoolStatusLabel.text = @"Échec";
        busStatusLabel.text = @"Échec";
    }
    
    if ([schoolStatusLabel.text length] == 0)
    {
        schoolStatusLabel.text = @"Chargement...";
    }
    
    if ([busStatusLabel.text length] == 0)
    {
        busStatusLabel.text = @"Chargement...";
    }
    
    //bus status colors
    if ([busStatusLabel.text containsString:@"normal"])
    {
        busStatusView.backgroundColor = [UIColor colorWithRed:0.49 green:0.83 blue:0.00 alpha:1.0];
    }
    else if ([busStatusLabel.text containsString:@"annulé"])
    {
        busStatusView.backgroundColor = [UIColor colorWithRed:0.86 green:0.00 blue:0.00 alpha:1.0];
    }
    else if ([busStatusLabel.text containsString:@"perturbé"])
    {
        busStatusView.backgroundColor = [UIColor colorWithRed:0.88 green:0.75 blue:0.00 alpha:1.0];
    }
    else
    {
        busStatusView.backgroundColor = [UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:1.0];
    }
    
    
    //school status colors
    if ([schoolStatusLabel.text containsString:@"ouverte"])
    {
        schoolStatusView.backgroundColor = [UIColor colorWithRed:0.49 green:0.83 blue:0.00 alpha:1.0];
    }
    else if ([schoolStatusLabel.text containsString:@"annulé"])
    {
        schoolStatusView.backgroundColor = [UIColor colorWithRed:0.86 green:0.00 blue:0.00 alpha:1.0];
    }
    else if ([schoolStatusLabel.text containsString:@"perturbé"])
    {
        schoolStatusView.backgroundColor = [UIColor colorWithRed:0.88 green:0.75 blue:0.00 alpha:1.0];
    }
    else
    {
        schoolStatusView.backgroundColor = [UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:1.0];
    }
    
    [self refreshTableView];
}

- (void)midnightRefresh
{
    [self updateStuff];
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateStuff) userInfo:nil repeats:NO];
}

- (void)updateStuff
{
    [self checkForAuthentification];
    [self refreshTableView];
    [self performSelector:@selector(updateScheduleInfo) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(updateScheduleInfo) withObject:nil afterDelay:3.0];
    NSLog(@"updated");
}

- (void)refreshTableView
{
    @try
    {
        [TableView reloadData];
    }
    @catch (NSException *exception)
    {
        MPRequest *request = [MPRequest new];
        [request failureAlert:@"Échec" withMessage:@"L'application n'a pas pu charger les informations actualisés"];
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
    
    int dayNumber;
    @try
    {
        dayNumber = [self currentDayNumberWithPeriodOne:periodOneList andPeriodTwo:periodTwoList andPeriodThree:periodThreeList andPeriodFour:periodFourList];
    }
    @catch (NSException *exception)
    {
        @try
        {
            [self logOutLogIn];
        }
        @catch (NSException *exception)
        {
            [self logout:nil];
        }
        
        if (shouldIBeUpdating)
        {
            MPRequest *request = [MPRequest new];
            [request failureAlert:@"Échec" withMessage:@"Il y a eu une erreur. Si vous voyez l'écran de login, s'il vous plaît, veuillez re-rentrer votre nom d'utilisateur et votre mot de passe"];
        }
    }
    
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
    
    @try
    {
        if ([classInfoOrderedSet count] > 0)
        {
            //get course info
            NSString *teacherName = [[classInfoOrderedSet objectAtIndex:3] textContent];
            if ([teacherName hasPrefix:@" "] && [teacherName length] > 1)
            {
                teacherName = [teacherName substringFromIndex:1];
            }
            
            NSString *courseCode = [[classInfoOrderedSet objectAtIndex:1] textContent];
            if ([courseCode hasPrefix:@" "] && [courseCode length] > 1)
            {
                courseCode = [courseCode substringFromIndex:1];
            }
            
            NSString *courseName = [[[classInfoOrderedSet objectAtIndex:0] childAtIndex:0] textContent];
            if ([courseName hasPrefix:@" "] && [courseName length] > 1)
            {
                courseName = [courseName substringFromIndex:1];
            }
            
            
            //add course info to array
            classInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:teacherName, @"teacherName", courseCode, @"courseCode", courseName, @"courseName", nil];
        }
        else
        {
            classInfoDict = [[NSDictionary alloc] init];;
        }
    }
    @catch (NSException * exception)
    {
        MPRequest *request = [MPRequest new];
        [request failureAlert:@"Échec" withMessage:@"L'application fonctionne actuellement seulement avec Saint-Charles-Garnier. S'il vous plait, re-essayez lorsqu'il y a une mise à jour."];
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

#pragma mark - Snow Day
- (NSArray *)getSnowDayStatus
{
    MPStringFromHTML *getString = [MPStringFromHTML new];
    
    //get string from data
    NSString * rawHTML = [getString getStringFromHTMLWithFileName:@"snowday.html"];
    
    //get document for parsing from the string
    HTMLDocument * snowDayPage = [HTMLDocument documentWithString:rawHTML];
    
    HTMLNode *snowDayTable = [snowDayPage firstNodeMatchingSelector:@"div#profile"];
    
    NSArray *tempSchoolInfoArray = [[[[[snowDayTable childAtIndex:1] childAtIndex:1] childAtIndex:3] children] array];
                                                     
    NSMutableArray *schoolInfoArray = [tempSchoolInfoArray mutableCopy];
    
    for (HTMLNode *node in tempSchoolInfoArray)
    {
        if ([[node children] count] == 0)
        {
            [schoolInfoArray removeObject:node];
        }
    }
    
    NSString *schoolNameFromPortail = [self getSchoolName];
    
    NSString *schoolStatus = [[NSString alloc] init];
    NSString *busStatus = [[NSString alloc] init];
    
    for (HTMLNode *node in schoolInfoArray)
    {
        NSString *schoolNameFromSnowDay = [[node firstNodeMatchingSelector:@"span.visible-xs"] textContent];
        
        if ([schoolNameFromPortail containsString:schoolNameFromSnowDay])
        {
            
            HTMLNode *school = [node childAtIndex:5];
            schoolStatus = [[school childAtIndex:1] textContent];
            busStatus = [[school childAtIndex:3] textContent];
            
            break;
        }
    }
    
    NSArray * snowDayStatusArray = [NSArray arrayWithObjects:schoolStatus, busStatus, nil];
    
    return snowDayStatusArray;
}

- (NSString *)getSchoolName
{
    //this try-catch is kinda bootleg but it fixes an issue that i can't manage to track down because I can't time reproduction perfectly
    @try
    {
        NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
        NSString *savedPassword = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
        
        MPRequest *request = [MPRequest new];
        
        [request requestLoginAtURL:@"https://apps.cscmonavenir.ca/PortailEleves/InfoEcole.aspx" withUsername:savedUsername andPassword:savedPassword saveResponseToFileName:@"schoolinfo.html" isMainRequest:NO isAutoLogin:NO expectsPDF:NO showErrors:NO];
        
        MPStringFromHTML *getString = [MPStringFromHTML new];
        //get string from data
        NSString * rawHTML = [getString getStringFromHTMLWithFileName:@"schoolinfo.html"];
        
        //get document for parsing from the string
        HTMLDocument * schoolInfoPage = [HTMLDocument documentWithString:rawHTML];
        
        HTMLNode *schoolNameNode = [schoolInfoPage firstNodeMatchingSelector:@"span#LNomEcole"];
        
        return [schoolNameNode textContent];
    }
    @catch (NSException *exception)
    {
        return @"nil";
    }
}

#pragma mark - TableView stuff
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *clickedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (clickedCell == snowDayRow)
    {
        BlackSFSafariViewController *safari = [[BlackSFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.cscmonavenir.ca/ecole/"] entersReaderIfAvailable:NO];
        
        safari.modalPresentationCapturesStatusBarAppearance = true;
        
        [self presentViewController:safari animated:YES completion:nil];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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

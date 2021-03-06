//
//  ResultsTableViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-11-07.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "ResultsTableViewController.h"
#import "BeautifulTableViewCell.h"
#import "MPStringFromHTML.h"
#import "HTMLReader.h"
#import "ClassSummaryViewController.h"
#import "MainViewController.h"

@interface ResultsTableViewController ()

@property (nonatomic, strong) id previewingContext;

@end

@implementation ResultsTableViewController

#pragma mark - Information acquisition
- (void)viewDidLoad
{
    [self threeDTouchIntialize];
    
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setContentInset:UIEdgeInsetsMake(32, 0, 32, 0)];
    
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)refresh:(id)sender
{
    MainViewController *main = [MainViewController new];
    BOOL isAuthenticated = [main checkForAuthentification];
    
    if (isAuthenticated)
    {
        [_tableView reloadData];
    }
    
    [sender endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *results = [self getSchoolResults];
    
    return [results count];
}

- (HTMLNode *)getResultTable
{
    MPStringFromHTML *getString = [MPStringFromHTML new];
    
    //get string from data
    NSString * rawHTML = [getString getStringFromHTMLWithFileName:@"resultdata.html"];
    
    //get document for parsing from the string
    HTMLDocument * schedulePage = [HTMLDocument documentWithString:rawHTML];
    
    HTMLNode *scheduleTable = [schedulePage firstNodeMatchingSelector:@"table#Table1"];
    
    return scheduleTable;
}

- (NSArray *)getSchoolResults
{
    @try
    {
        //9th+ grade results
        NSArray *results = [[NSArray alloc] init];
        
        //get the result table
        HTMLNode *scheduleTable = [self getResultTable];
        
        NSOrderedSet *markTable = [[[scheduleTable children] objectAtIndex:1] children];
        NSMutableArray *markInfo = [[NSMutableArray alloc] init];
        
        for (id item in markTable)
        {
            if ([markTable indexOfObject:item] != 0)
            {
                int index = (int)[markTable indexOfObject:item];
                
                NSOrderedSet * classMarkInfoSet = [[markTable objectAtIndex:index] children];
                
                if ([classMarkInfoSet count] > 0)
                {
                    //get the teacher and the course name
                    NSOrderedSet *teacherAndCourseName = [[[[classMarkInfoSet objectAtIndex:1] children] objectAtIndex:0] children];
                    
                    NSString *teacher = [[teacherAndCourseName objectAtIndex:2] textContent];
                    NSString *className = [[[[teacherAndCourseName objectAtIndex:0] children] objectAtIndex:0] textContent];
                    
                    
                    //the next two if/else statements are purely to fix an issue that only occured on Veron's account
                    BOOL hasData;
                    if ([[[[[markTable objectAtIndex:index] children] objectAtIndex:4] children] count] != 0)
                    {
                        hasData = YES;
                    }
                    else
                    {
                        hasData = NO;
                    }
                    
                    NSString *performance = [[NSString alloc] init];
                    if (hasData == YES)
                    {
                        performance = [[[[[[markTable objectAtIndex:index] children] objectAtIndex:4] children] objectAtIndex:0] textContent];
                    }
                    else
                    {
                        performance = @"N/A";
                    }
                    //end of Veron's if statements
                    
                    //put the current class' mark info in an array
                    NSArray *currentClassInfo = [NSArray arrayWithObjects:teacher, className, performance, nil];
                    
                    //add the current class to the array of classes
                    [markInfo addObject:currentClassInfo];
                }
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:markInfo forKey:@"currentMarks"];
        
        results = [NSArray arrayWithArray:markInfo];
        classResults = [NSArray arrayWithArray:markInfo];
        
        return results;
    }
    @catch (NSException *exception)
    {
        //8th- grade results
        
        
        //finish in future update
        /*
        NSArray *results = [[NSArray alloc] init];
        
        //get the result table
        HTMLNode *scheduleTable = [self getResultTable];
        
        NSOrderedSet *markTable = [[[scheduleTable children] objectAtIndex:1] children];
        NSMutableArray *markInfo = [[NSMutableArray alloc] init];
        
        for (id item in markTable)
        {
            
        }
        */
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Échec" message:@"L'application fonctionne seulement avec des comptes d'élèves qui sont en 9e année ou plus." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BeautifulTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[BeautifulTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    //set values to variables
    NSString *className = [[classResults objectAtIndex:indexPath.row] objectAtIndex:1];
    NSString *teacherName = [[[classResults objectAtIndex:indexPath.row] objectAtIndex:0] stringByReplacingOccurrencesOfString:@"Enseignant(e): " withString:@""];
    NSString *resultString = [[classResults objectAtIndex:indexPath.row] objectAtIndex:2];
    
    //set class label to the class name
    cell.classLabel.text = className;
    
    //set the teacher's name to the right label if a teacher name is found
    if ([[teacherName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        cell.teacherLabel.text = @"Inconnu";
    }
    else
    {
        cell.teacherLabel.text = teacherName;
    }
    
    //set result to the right label if a result is found
    if ([[resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || [resultString containsString:@"N/A"])
    {
        cell.resultLabel.text = @"N/A";
        cell.circleView.backgroundColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
    }
    else
    {
        cell.resultLabel.text = resultString;
        
        //set color-coding and specific properties for marks
        if ([resultString containsString:@"4"])
        {
            cell.circleView.backgroundColor = [UIColor colorWithRed:0.34 green:0.79 blue:0.00 alpha:1.0];
        }
        else if ([resultString containsString:@"3"])
        {
            cell.circleView.backgroundColor = [UIColor colorWithRed:0.00 green:0.55 blue:0.79 alpha:1.0];
        }
        else if ([resultString containsString:@"2"])
        {
            cell.circleView.backgroundColor = [UIColor colorWithRed:0.87 green:0.83 blue:0.00 alpha:1.0];
        }
        else if ([resultString containsString:@"N/D"])
        {
            cell.circleView.backgroundColor = [UIColor colorWithRed:0.60 green:0.60 blue:0.60 alpha:1.0];
        }
        else
        {
            cell.circleView.backgroundColor = [UIColor colorWithRed:0.87 green:0.00 blue:0.00 alpha:1.0];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasData = [self checkForData:indexPath.row];
    
    if (hasData == YES)
    {
        ClassSummaryViewController *summaryViewController = [self finishSettingUpMarkDetails:indexPath];
        if (summaryViewController != nil)
        {
            [self presentViewController:summaryViewController animated:YES completion:nil];
        }
        else
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (BOOL)checkForData:(long)indexPath
{
    //get the result table
    HTMLNode *scheduleTable = [self getResultTable];
    
    NSOrderedSet *markTable = [[[scheduleTable children] objectAtIndex:1] children];
    
    BOOL hasData;
    if ([[[[[markTable objectAtIndex:indexPath+1] children] objectAtIndex:4] children] count] != 0)
    {
        hasData = YES;
    }
    else
    {
        hasData = NO;
    }
    
    return hasData;
}

- (ClassSummaryViewController *)finishSettingUpMarkDetails:(NSIndexPath *)indexPath
{
    //get the result table
    HTMLNode *scheduleTable = [self getResultTable];
    
    NSOrderedSet *markTable = [[[scheduleTable children] objectAtIndex:1] children];
    
    HTMLNode *linkNode = [[[[[markTable objectAtIndex:indexPath.row+1] children] objectAtIndex:4] children] objectAtIndex:0];
    
    if ([[linkNode children] count] > 0)
    {
        //cut off the beginning unnecessary part and fix the ampersands
        NSString *linkString = [[[linkNode serializedFragment] stringByReplacingOccurrencesOfString:@"<a onclick=\"javascript:window.open('" withString:@""] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        //cut off the end unnecessary part
        NSRange range = [linkString rangeOfString:@"'"];
        if (range.location != NSNotFound)
        {
            linkString = [@"https://apps.cscmonavenir.ca" stringByAppendingString:[linkString substringToIndex:range.location]];
        }
        else
        {
            linkString = @"";
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:linkString forKey:@"desiredSummary"];
        
        //open class summary view
        ClassSummaryViewController *summaryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PDFViewer"];
        
        return summaryViewController;
    }
    else
    {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
        return nil;
    }
}

#pragma mark - Peek and Pop

-(void)threeDTouchIntialize
{
    if ([self is3DTouchAvailable])
    {
        self.previewingContext = [self registerForPreviewingWithDelegate:self  sourceView:self.view];
    }
}

- (BOOL)is3DTouchAvailable
{
    BOOL is3DTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)])
    {
        is3DTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return is3DTouchAvailable;
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing> )previewingContext viewControllerForLocation:(CGPoint)location
{
    CGPoint cellPostion = [_tableView convertPoint:location fromView:self.view];
    
    NSIndexPath *path = [_tableView indexPathForRowAtPoint:cellPostion];
    
    if (path)
    {
        @try
        {
            UITableViewCell *tableCell = [_tableView cellForRowAtIndexPath:path];
            
            ClassSummaryViewController *summaryViewController = [self finishSettingUpMarkDetails:path];
            
            if (summaryViewController != nil)
            {
                previewingContext.sourceRect = [self.view convertRect:tableCell.frame fromView: _tableView];
                
                return summaryViewController;
            }
            else
            {
                return nil;
            }
        }
        @catch (NSException *exception)
        {
            //do nothing if there is no grade
        }
    }
    
    return nil;
}

-(void)previewingContext:(id )previewingContext commitViewController: (UIViewController *)viewControllerToCommit
{
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end

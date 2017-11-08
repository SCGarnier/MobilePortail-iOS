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

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

- (void)viewDidLoad
{
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView setContentInset:UIEdgeInsetsMake(8, 0, 0, 0)];
    
    
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

- (NSArray *)getSchoolResults
{
    NSArray *results = [[NSArray alloc] init];
    
    MPStringFromHTML *getString = [MPStringFromHTML new];
    
    //get string from data
    NSString * rawHTML = [getString getStringFromHTMLWithFileName:@"resultdata.html"];
    
    //get document for parsing from the string
    HTMLDocument * schedulePage = [HTMLDocument documentWithString:rawHTML];
    
    HTMLNode *scheduleTable = [schedulePage firstNodeMatchingSelector:@"table#Table1"];
    
    //NSLog(@"%@", [[[[[[[scheduleTable children] objectAtIndex:1] children] objectAtIndex:0] children] objectAtIndex:1] children]);
    
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
                
                
                
                
            }

            //NSString *className = [[[[[[classMarkInfoSet objectAtIndex:1] children] objectAtIndex:0] children] objectAtIndex:2] textContent];
        }
    }
    
    return results;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BeautifulTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[BeautifulTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    cell.textLabel.text = [booksArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
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

//
//  MPRequest.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-25.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "MPRequest.h"
#import "AFNetworking.h"
#import "ViewController.h"
#import "LoginViewController.h"
#import "HTMLReader.h"
#import "MPStringFromHTML.h"
#import "ClassSummaryViewController.h"

@implementation MPRequest

#pragma mark - Log in and main information
- (void)requestLoginAtURL:(NSString *)postURL withUsername:(NSString *)username andPassword:(NSString *)password saveResponseToFileName:(NSString *)responseFileName isMainRequest:(BOOL)isMainRequest isAutoLogin:(BOOL)isAutoLogin expectsPDF:(BOOL)expectsPDF showErrors:(BOOL)doesShowErrors
{
    //parameters, do not touch anything pls
    NSDictionary *parameterDictionary = @{
                                            @"__VIEWSTATE":@"/wEPDwULLTE1OTEzODk5NDRkZHeWIDblnhXfWVgudGFcvrqUrsa8oUjUBNqAwiyC5bQZ",
                                            @"__VIEWSTATEGENERATOR":@"3738FB10",
                                            @"__EVENTVALIDATION":@"/wEdAAS/EmKn67wLWprMxhcvNZYzNV4T48EJ76cvY4cUAzjjnR0O4L6f0pzi6oGvFfSn1SztaUkzhlzahAalhIckp3krG4fQXm17dVV5HUDhFMYg3hg06HAD0C/01YYOsiBthV8=",
                                            @"Tlogin":username,
                                            @"Tpassword":password,
                                            @"Blogin":@"Entrer"
                                          };
    
    //set up internet connection things
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/html", @"application/pdf", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    manager.responseSerializer = responseSerializer;
    
    NSString *chosenUserAgent;
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"UA.plist"];
    //if the user agents lists exists, pick one of them as the user agent. if not, default to Chrome
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:filePath])
    {
        NSArray *userAgentArray = [NSArray arrayWithContentsOfFile:filePath];
        int index = arc4random_uniform((int)[userAgentArray count]);
        chosenUserAgent = userAgentArray[index];
    }
    else
    {
        chosenUserAgent = @"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";
    }
    
    //NSLog(@"%@", chosenUserAgent);
    
    NSString *userAgent = [manager.requestSerializer  valueForHTTPHeaderField:@"User-Agent"];
    userAgent = chosenUserAgent;
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [manager POST:postURL parameters:parameterDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         //set up file manager
         NSFileManager *fileManager = [NSFileManager defaultManager];
         
         //get documents directory
         NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
         
         //get the data directory
         NSString *dataDir = [documentsDirectory stringByAppendingPathComponent:@"tempData"];
         
         //get the data file path
         NSString *htmlFilePath = [dataDir stringByAppendingPathComponent:responseFileName];
         
         //create a directory for the data files if it doesn't already exist
         if (![fileManager fileExistsAtPath:dataDir])
         {
             NSError *error;
             [fileManager createDirectoryAtPath:dataDir withIntermediateDirectories:YES attributes:nil error:&error];
         }
         
         //delete old data
         if ([fileManager fileExistsAtPath:htmlFilePath])
         {
             [fileManager removeItemAtPath:htmlFilePath error:nil];
         }
         
         //write data to HTML file
         [fileManager createFileAtPath:htmlFilePath contents:responseObject attributes:nil];
         
         
         //check for successful login
         if (expectsPDF != YES)
         {
             [self checkForSuccessfulLogin:responseFileName isMainRequest:isMainRequest isAutoLogin:isAutoLogin];
         }
     }
     failure:^(NSURLSessionDataTask  *_Nullable task, NSError  *_Nonnull error)
     {
         if (isMainRequest)
         {
             [self failureAlert:@"Échec" withMessage:error.localizedDescription];
         }
         [self resetButtonText];
         
         NSLog(@"%@", error);
     }];
}

- (void)downloadUserAgentList
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //download current version
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/Sn0wCh1ld/Various-Files/master/popular-browser-user-agents"];
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
                                              {
                                                  plistData = [NSData dataWithContentsOfURL:location];
                                                  
                                                  //delete the old version of the file if it already exists
                                                  if ([fileManager fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@"UA.plist"]])
                                                  {
                                                      [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:@"UA.plist"] error:&error];
                                                  }
                                                  
                                                  [plistData writeToFile:[documentsDirectory stringByAppendingPathComponent:@"UA.plist"] atomically:YES];
                                              }];
    [downloadTask resume];
}

- (BOOL)checkForSuccessfulLogin:(NSString *)fileName isMainRequest:(BOOL)isMainRequest isAutoLogin:(BOOL)isAutoLogin
{
    MPStringFromHTML *getString = [MPStringFromHTML new];
    
    //get string from data
    NSString *rawHTML = [getString getStringFromHTMLWithFileName:fileName];
    
    //make an HTML document for HTMLReader to parse
    HTMLDocument *document = [HTMLDocument documentWithString:rawHTML];
    
    //if it's the main request (the one that returns the school performance), then keep going. Otherwise, skip this whole section
    if (isMainRequest)
    {
        if ([[document firstNodeMatchingSelector:@"title"].textContent containsString:@"portail"])
        {
            [self autoLoginFailure:isAutoLogin showErrors:YES];
            
            return NO;
        }
        else if ([[document firstNodeMatchingSelector:@"title"].textContent containsString:@"scolaires"])
        {
            //If it contains "scolaires", then the login succeeded.
            
            UIViewController *topController = [self getTopController];
            
            [self resetButtonText];
            
            //dismiss the login view controller
            [topController dismissViewControllerAnimated:YES completion:nil];
            
            return YES;
        }
        else if ([[document firstNodeMatchingSelector:@"title"].textContent length] == 0)
        {
            return NO;
        }
        else
        {
            //If neither are contained, either portail is broken, or got a large enough update that it warrants an app update
            [self resetButtonText];
            
            [self failureAlert:@"Portail est brisé" withMessage:@"Le portail des élèves ne marche pas comme il faut. S'il vous plaît, essayez encore plus tard"];
            
            return NO;
        }
    }
    else
    {
        if ([[document firstNodeMatchingSelector:@"title"].textContent containsString:@"portail"])
        {
            [self autoLoginFailure:isAutoLogin showErrors:NO];
            
            return NO;
        }
        else
        {
            //just return no because if it's not the main request no one cares
            return NO;
        }
    }
}

- (void)autoLoginFailure:(BOOL)isAutoLogin showErrors:(BOOL)doesShowErrors
{
    //If the title contains "portail", then the login failed due to an incorrect username or password.
    if (isAutoLogin)
    {
        UIViewController *topController = [self getTopController];
        
        //if the autologin fails, open the manual login screen
        @try
        {
            ViewController *login = [topController.storyboard instantiateViewControllerWithIdentifier:@"login"];
            [topController presentViewController:login animated:YES completion:nil];
        }
        @catch (NSException *exception)
        {
            //i don't really trust the code I wrote inside the try statement, which is why it's in a try-catch setup. There's no way to easily test it unless the school board messed up our passwords again, so if it fails, we just handle it gracefully.
            if (doesShowErrors)
            {
                [self failureAlert:@"Échec de l'application" withMessage:@"S'il ne fonctionne plus, veuillez s'il-vous-plaît supprimer l'application et ensuite la re-télécharger"];
            }
        }
    }
    
    [self resetButtonText];
    
    if (doesShowErrors)
    {
        [self failureAlert:@"Nom d'utilisateur ou mot de passe incorrect" withMessage:@"Veuillez entrer le bon nom d'utilisateur et mot de passe"];
    }
}


#pragma mark - Snow Day
- (void)downloadSnowDayData
{
    //get documents directory
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    //get the data directory
    NSString *dataDir = [documentsDirectory stringByAppendingPathComponent:@"tempData"];
    NSString *filePath = [dataDir stringByAppendingPathComponent:@"snowday.html"];
    
    //page URL
    NSURL *url = [NSURL URLWithString:@"https://www.cscmonavenir.ca/ecole/"];
    
    //NSError *error;
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
    {
        NSData *downloadedData = [NSData dataWithContentsOfURL:location];
        
        [downloadedData writeToFile:filePath atomically:YES];
    }];
    [downloadTask resume];
    
    /*
    //convert HTML to NSData
    NSString *rawHTML = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSData *pageData = [rawHTML dataUsingEncoding:NSUTF8StringEncoding];
    
    //Write data to file
    [pageData writeToFile:filePath atomically:YES];*/
}

#pragma mark - other

- (void)resetButtonText
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"loggingInDone"];
}

- (void)deleteOldData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //get documents directory
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    //get the data directory
    NSString *dataDir = [documentsDirectory stringByAppendingPathComponent:@"tempData"];
    
    if ([fileManager fileExistsAtPath:dataDir])
    {
        [fileManager removeItemAtPath:dataDir error:nil];
    }
}

- (void)failureAlert:(NSString *)title withMessage:(NSString *)message
{
    [self resetButtonText];
    
    UIViewController *topController = [self getTopController];
    
    //show the failure alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [topController presentViewController:alert animated:YES completion:nil];
}
                 
- (UIViewController *)getTopController
{
    //necessary stuff to show an alert from an NSObject subclass
    //finds the current view controller
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //honestly not quire sure what this does
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end

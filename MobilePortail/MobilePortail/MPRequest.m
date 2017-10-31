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
#import "HTMLReader.h"

@implementation MPRequest

- (void)requestLoginAtURL:(NSString *)postURL withUsername:(NSString *)username andPassword:(NSString *)password saveResponseToFileName:(NSString *)responseFileName isMainRequest:(BOOL)isMainRequest
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
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/html", @"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    manager.responseSerializer = responseSerializer;
    
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
         [self checkForSuccessfulLogin:htmlFilePath isMainRequest:isMainRequest];
     }
     failure:^(NSURLSessionDataTask  *_Nullable task, NSError  *_Nonnull error)
     {
         [self failureAlert:@"Échec" withMessage:error.localizedDescription];
     }];
}

- (void)checkForSuccessfulLogin:(NSString *)filePath isMainRequest:(BOOL)isMainRequest
{
    //get data from html file
    NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
    
    //get string from data
    NSString *rawHTML = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    //make an HTML document for HTMLReader to parse
    HTMLDocument *document = [HTMLDocument documentWithString:rawHTML];
    
    if (isMainRequest && [[document firstNodeMatchingSelector:@"title"].textContent containsString:@"portail"])
    {
        [self failureAlert:@"Nom d'utilisateur ou mot de passe incorrect" withMessage:@"Veuillez entrer le bon nom d'utilisateur et mot de passe"];
    }
    else if ([[document firstNodeMatchingSelector:@"title"].textContent containsString:@"scolaires"])
    {
        //necessary stuff to show an alert from an NSObject subclass
        //finds the current view controller
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        //honestly not quire sure what this does
        while (topController.presentedViewController)
        {
            topController = topController.presentedViewController;
        }
        
        [topController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)failureAlert:(NSString *)title withMessage:(NSString *)message
{
    //necessary stuff to show an alert from an NSObject subclass
    //finds the current view controller
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //honestly not quire sure what this does
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    //show the failure alert
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [topController presentViewController:alert animated:YES completion:nil];
}

@end

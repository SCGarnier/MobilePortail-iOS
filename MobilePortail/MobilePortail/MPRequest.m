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

@implementation MPRequest

- (void)requestLoginWithUsername:(NSString *)username andPassword:(NSString *)password
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
    
    //url to post to
    NSString *postURL = @"https://apps.cscmonavenir.ca/PortailEleves/index.aspx";
    
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
         NSString *htmlFilePath = [dataDir stringByAppendingPathComponent:@"data.html"];
         
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
     }
     failure:^(NSURLSessionDataTask  *_Nullable task, NSError  *_Nonnull error)
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
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Échec" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
         [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
         [topController presentViewController:alert animated:YES completion:nil];
     }];
}

@end

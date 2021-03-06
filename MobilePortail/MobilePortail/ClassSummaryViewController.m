//
//  ClassSummaryViewController.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-11-15.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "ClassSummaryViewController.h"
#import "MPRequest.h"
#import "SAMKeychain.h"
#import "SAMKeychainQuery.h"
#import <PDFKit/PDFKit.h>

@interface ClassSummaryViewController ()

@end

@implementation ClassSummaryViewController

- (void)viewDidLoad
{
    isShownAlready = NO;
    
    if (@available(iOS 11.0, *))
    {
        self.navigationController.navigationBar.prefersLargeTitles = true;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    //delete old summary
    [self deleteOldData];
    
    NSString *linkToDownloadFrom = [[NSUserDefaults standardUserDefaults] objectForKey:@"desiredSummary"];
    
    //retrieve saved login info
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:@"PortailUsername"];
    NSString *savedPassword = [SAMKeychain passwordForService:@"Portail" account:savedUsername];
    
    MPRequest *request = [MPRequest new];
    
    [request requestLoginAtURL:linkToDownloadFrom withUsername:savedPassword andPassword:savedPassword saveResponseToFileName:@"summary.pdf" isMainRequest:NO isAutoLogin:NO expectsPDF:YES showErrors:YES];
    
    
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkForDownloadCompletion) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:checkTimer forMode:NSDefaultRunLoopMode];
    [checkTimer fire];
}

- (void)hideActivityIndicator
{
    //hide the loading thingy
    [loadingIndicator stopAnimating];
    loadingIndicator.hidden = YES;
}

- (void)checkForDownloadCompletion
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"tempData"] stringByAppendingPathComponent:@"summary.pdf"];
    
    if ([fileManager fileExistsAtPath:path])
    {
        [checkTimer invalidate];
        
        for(UIView *currentView in mainView.subviews)
        {
            if (@available(iOS 11.0, *))
            {
                if([currentView isKindOfClass:[PDFView class]] || [currentView isKindOfClass:[UIWebView class]])
                {
                    isShownAlready = YES;
                }
            }
            else
            {
                // Fallback on earlier versions
                if([currentView isKindOfClass:[UIWebView class]])
                {
                    isShownAlready = YES;
                }
            }
        }
        
        if (!isShownAlready)
        {
            [self showPDF:path];
            isShownAlready = YES;
        }
    }
}

- (void)showPDF:(NSString *)path
{
    [self hideActivityIndicator];
    
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    if (@available(iOS 11.0, *))
    {
        //Display PDF properly if iOS version is 11.0 or higher
        PDFDocument *pdfDocument = [[PDFDocument alloc] initWithURL:fileURL];
        
        PDFView *pdfView = [[PDFView alloc] initWithFrame: self.view.bounds];
        pdfView.document = pdfDocument;
        pdfView.displayMode = kPDFDisplaySinglePageContinuous;
        pdfView.autoScales = true;
        pdfView.scaleFactor = pdfView.scaleFactor * 0.95;
        
        [self.view addSubview:pdfView];
    }
    else
    {
        //if it fails to use PDFKit (device is probably on iOS 9 or 10 or whatever), just use the old crusty way of displaying PDFs
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        [webView setScalesPageToFit:YES];
        webView.opaque = NO;
        webView.backgroundColor = [UIColor clearColor];
        
        webView.center = CGPointMake(webView.center.x, webView.center.y + 64);
        
        NSURL *targetURL = fileURL;
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webView loadRequest:request];
        
        [self.view addSubview:webView];
    }
}

- (void)deleteOldData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //get documents directory
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    //get the data directory
    NSString *dataPath = [[documentsDirectory stringByAppendingPathComponent:@"tempData"] stringByAppendingPathComponent:@"summary.pdf"];
    
    if ([fileManager fileExistsAtPath:dataPath])
    {
        [fileManager removeItemAtPath:dataPath error:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

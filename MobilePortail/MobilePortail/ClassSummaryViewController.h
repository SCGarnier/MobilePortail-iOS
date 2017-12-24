//
//  ClassSummaryViewController.h
//  MobilePortail
//
//  Created by Justin Proulx on 2017-11-15.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "ViewController.h"
#import <PDFKit/PDFKit.h>

@interface ClassSummaryViewController : UIViewController
{
    IBOutlet UIActivityIndicatorView *loadingIndicator;
    
    IBOutlet UIView *mainView;
    
    NSTimer *checkTimer;
    
    BOOL isShownAlready;
}

@end

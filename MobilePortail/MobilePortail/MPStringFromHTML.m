//
//  MPStringFromHTML.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-31.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "MPStringFromHTML.h"

@implementation MPStringFromHTML

- (NSString *)getStringFromHTMLWithFileName:(NSString *)fileName
{
    //get documents directory
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    //get the data directory
    NSString *dataDir = [documentsDirectory stringByAppendingPathComponent:@"tempData"];
    
    //get the data file path
    NSString *htmlFilePath = [dataDir stringByAppendingPathComponent:fileName];
    
    //get data from HTML file
    NSData *htmlData = [NSData dataWithContentsOfFile:htmlFilePath];
    
    //get string from data
    NSString *rawHTML = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    
    return rawHTML;
}

@end

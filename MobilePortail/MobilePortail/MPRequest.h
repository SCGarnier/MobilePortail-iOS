//
//  MPRequest.h
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-25.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPRequest : NSObject
{
    NSData *plistData;
}

- (void)requestLoginAtURL:(NSString *)postURL withUsername:(NSString *)username andPassword:(NSString *)password saveResponseToFileName:(NSString *)responseFileName isMainRequest:(BOOL)isMainRequest isAutoLogin:(BOOL)isAutoLogin expectsPDF:(BOOL)expectsPDF showErrors:(BOOL)doesShowErrors;

- (BOOL)checkForSuccessfulLogin:(NSString *)fileName isMainRequest:(BOOL)isMainRequest isAutoLogin:(BOOL)isAutoLogin;

- (void)failureAlert:(NSString *)title withMessage:(NSString *)message;

- (void)deleteOldData;

- (void)downloadSnowDayData;

- (void)downloadUserAgentList;

@end

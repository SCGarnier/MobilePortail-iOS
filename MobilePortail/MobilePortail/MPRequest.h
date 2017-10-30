//
//  MPRequest.h
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-25.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPRequest : NSObject

- (void)requestLoginAtURL:(NSString *)postURL withUsername:(NSString *)username andPassword:(NSString *)password saveResponseToFileName:(NSString *)responseFileName;

@end

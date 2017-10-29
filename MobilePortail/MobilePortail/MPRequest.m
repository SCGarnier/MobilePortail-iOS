//
//  MPRequest.m
//  MobilePortail
//
//  Created by Justin Proulx on 2017-10-25.
//  Copyright © 2017 Bricc Squad. All rights reserved.
//

#import "MPRequest.h"
#import "AFNetworking.h"

@implementation MPRequest

- (void)requestLoginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    
    manager.responseSerializer = responseSerializer;
    
    [manager POST:@"https://apps.cscmonavenir.ca/PortailEleves/index.aspx" parameters:<#(nullable id)#> progress:<#^(NSProgress * _Nonnull uploadProgress)uploadProgress#> success:<#^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)success#> failure:<#^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)failure#>];
}

@end

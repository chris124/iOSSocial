//
//  IGRequest.m
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "IGRequest.h"
//#import "Instagram.h"

@implementation IGRequest

#import "LocalInstagramUser.h"
- (NSURL *)authorizedURL
{
    NSString *access_token = [NSString stringWithFormat:@"?access_token=%@", [[LocalInstagramUser localInstagramUser] oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:self.URL];
    
    return url;
}

@end
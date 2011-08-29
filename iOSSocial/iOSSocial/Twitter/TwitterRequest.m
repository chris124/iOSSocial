//
//  TwitterRequest.m
//  PhotoStream
//
//  Created by Christopher White on 8/18/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import "TwitterRequest.h"

@implementation TwitterRequest

#import "LocalTwitterUser.h"
- (NSURL *)authorizedURL
{
    NSString *access_token = [NSString stringWithFormat:@"?oauth_token=%@", [[LocalTwitterUser localTwitterUser] oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:self.URL];
    
    return url;
}

@end

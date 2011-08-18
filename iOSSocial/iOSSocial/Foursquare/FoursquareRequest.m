//
//  FoursquareRequest.m
//  PhotoStream
//
//  Created by Christopher White on 8/18/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import "FoursquareRequest.h"

@implementation FoursquareRequest

#import "LocalFoursquareUser.h"
- (NSURL *)authorizedURL
{
    NSString *access_token = [NSString stringWithFormat:@"?oauth_token=%@", [[LocalFoursquareUser localFoursquareUser] oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:self.URL];
    
    return url;
    
    //return [Instagram authorizeURL:self.URL];
}

@end

//
//  GTMOAuthAuthentication+Additions.m
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "GTMOAuthAuthentication+Additions.h"

@interface GTMOAuthAuthentication ()

- (void)setKeysForResponseDictionary:(NSDictionary *)dict;

@end

static NSString *const kOAuth1TwitterUserIDKey      = @"user_id";
static NSString *const kOAuth1TwitterUserNameKey    = @"screen_name";
static NSString *const kOAuth1FlickrUserIDKey       = @"user_nsid";
static NSString *const kOAuth1FlickrUserNameKey     = @"username";

@interface GTMOAuthAuthenticationWithAdditions ()

@property(nonatomic, readwrite, retain)  NSString *userID;      // User identifier.
@property(nonatomic, readwrite, retain)  NSString *username;    // The user's alias

@end

@implementation GTMOAuthAuthenticationWithAdditions

@synthesize userID;
@synthesize username;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setKeysForResponseDictionary:(NSDictionary *)dict 
{
    [super setKeysForResponseDictionary:dict];
    
    //Try Twitter
    NSString *newUserID = [dict objectForKey:kOAuth1TwitterUserIDKey];
    if (newUserID) {
        [self setUserID:newUserID];
    }
    
    NSString *newUsername = [dict objectForKey:kOAuth1TwitterUserNameKey];
    if (newUsername) {
        [self setUsername:newUsername];
    }
    
    //Try Flickr
    newUserID = [dict objectForKey:kOAuth1FlickrUserIDKey];
    if (newUserID) {
        [self setUserID:newUserID];
    }
    
    newUsername = [dict objectForKey:kOAuth1FlickrUserNameKey];
    if (newUsername) {
        [self setUsername:newUsername];
    }
}

@end

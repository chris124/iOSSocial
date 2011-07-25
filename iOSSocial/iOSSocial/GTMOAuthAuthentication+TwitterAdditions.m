//
//  GTMOAuthAuthentication+TwitterAdditions.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "GTMOAuthAuthentication+TwitterAdditions.h"

@interface GTMOAuthAuthentication ()

- (void)setKeysForResponseDictionary:(NSDictionary *)dict;

@end

static NSString *const kOAuthTwitterUserIDKey          = @"user_id";
static NSString *const kOAuthTwitterUserNameKey        = @"screen_name";

@interface GTMOAuthAuthenticationWithTwitterAdditions ()

@property(nonatomic, readwrite, retain)  NSString *userID;   // User identifier.
@property(nonatomic, readwrite, retain)  NSString *username;    // The user's alias

@end

@implementation GTMOAuthAuthenticationWithTwitterAdditions

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
    
    NSString *newUserID = [dict objectForKey:kOAuthTwitterUserIDKey];
    if (newUserID) {
        [self setUserID:newUserID];
    }
    
    NSString *newUsername = [dict objectForKey:kOAuthTwitterUserNameKey];
    if (newUsername) {
        [self setUsername:newUsername];
    }
}

@end

//
//  TwitterUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "TwitterUser.h"
#import "TwitterUser+Private.h"

@implementation TwitterUser

@synthesize userDictionary;
@synthesize userID;
@synthesize alias;
@synthesize fetchUserDataHandler;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)theUserDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.userDictionary = theUserDictionary;
    }
    
    return self;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    userDictionary = theUserDictionary;
    
    self.userID = [theUserDictionary objectForKey:@"id"];
    NSString *username = [theUserDictionary objectForKey:@"username"];
    if (username) {
        self.alias = username;
    } else {
        self.alias = [theUserDictionary objectForKey:@"screen_name"];
    }
}

@end

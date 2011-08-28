//
//  FoursquareUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "FoursquareUser.h"
#import "FoursquareUser+Private.h"


@implementation FoursquareUser

@synthesize userDictionary;
@synthesize userID;
@synthesize alias;
@synthesize firstName;
@synthesize fetchUserDataHandler;
@synthesize profilePictureURL;
@synthesize dataSource;
@synthesize index;

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
    
    NSDictionary *responseDict = [theUserDictionary objectForKey:@"response"];
    if (responseDict) {
        NSDictionary *userDict = [responseDict objectForKey:@"user"];
        if (userDict) {
            self.userID = [userDict objectForKey:@"id"];
            self.alias = [userDict objectForKey:@"firstName"];
            self.firstName = [userDict objectForKey:@"firstName"];
            self.profilePictureURL = [userDict objectForKey:@"photo"];
        }
    }
    
    
    /*
     self.lastName = [theUserDictionary objectForKey:@"last_name"];
     self.profilePictureURL = [theUserDictionary objectForKey:@"profile_picture"];
     self.bio = [theUserDictionary objectForKey:@"bio"];
     self.website = [theUserDictionary objectForKey:@"website"];
     
     NSDictionary *counts = [userDictionary objectForKey:@"counts"];
     if (counts) {
     //self.mediaCount = [counts objectForKey:@"media"];
     //self.followsCount = [counts objectForKey:@"follows"];
     //self.followedByCount = [counts objectForKey:@"followed_by"];
     }
     */
}

@end

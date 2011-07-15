//
//  InstagramUser.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstagramUser.h"

@interface InstagramUser ()

@property(nonatomic, readwrite, retain) NSString *userID;
@property(nonatomic, readwrite, retain) NSString *alias;
@property(nonatomic, readwrite, retain) NSString *firstName;
@property(nonatomic, readwrite, retain) NSString *lastName;
@property(nonatomic, readwrite, retain) NSString *profilePictureURL;
@property(nonatomic, readwrite, retain) NSString *bio;
@property(nonatomic, readwrite, retain) NSString *website;
@property(nonatomic, readwrite, assign) NSInteger mediaCount;
@property(nonatomic, readwrite, assign) NSInteger followsCount;
@property(nonatomic, readwrite, assign) NSInteger followedByCount;
@property (nonatomic, copy)             LoadPhotoHandler loadPhotoHandler;

@end

@implementation InstagramUser

@synthesize userID;
@synthesize alias;
@synthesize firstName;
@synthesize lastName;
@synthesize profilePictureURL;
@synthesize bio;
@synthesize website;
@synthesize mediaCount;
@synthesize followsCount;
@synthesize followedByCount;
@synthesize loadPhotoHandler;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)userDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.userID = [userDictionary objectForKey:@"id"];
        self.alias = [userDictionary objectForKey:@"username"];
        self.firstName = [userDictionary objectForKey:@"first_name"];
        self.lastName = [userDictionary objectForKey:@"last_name"];
        self.profilePictureURL = [userDictionary objectForKey:@"profile_picture"];
        self.bio = [userDictionary objectForKey:@"bio"];
        self.website = [userDictionary objectForKey:@"website"];
        
        NSDictionary *counts = [userDictionary objectForKey:@"counts"];
        if (counts) {
            //self.mediaCount = [counts objectForKey:@"media"];
            //self.followsCount = [counts objectForKey:@"follows"];
            //self.followedByCount = [counts objectForKey:@"followed_by"];
        }
    }
    
    return self;
}

- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler
{
    self.loadPhotoHandler = completionHandler;
    
    //a request has to be authorised
    /*
    NSString *path = [NSString stringWithFormat:@"%@/picture", self.userID];
    FBRequest *request = [[SocialManager socialManager].facebook requestWithGraphPath:path andDelegate:self];
    [self recordRequest:request withType:FBUserPictureRequestType];
    */
}

@end

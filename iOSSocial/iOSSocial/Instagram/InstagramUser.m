//
//  InstagramUser.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstagramUser.h"
#import "InstagramUser+Private.h"
#import "Instagram.h"
#import "iOSSRequest.h"

@interface InstagramUser ()

@property(nonatomic, copy)  LoadPhotoHandler loadPhotoHandler;

@end

@implementation InstagramUser

@synthesize userDictionary;
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
    self.alias = [theUserDictionary objectForKey:@"username"];
    self.firstName = [theUserDictionary objectForKey:@"first_name"];
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

}

- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler
{
    self.loadPhotoHandler = completionHandler;
    
    NSString *urlString = self.profilePictureURL;
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.loadPhotoHandler) {
                self.loadPhotoHandler(nil, error);
                self.loadPhotoHandler = nil;
            }
        } else {
            UIImage *image = [UIImage imageWithData:responseData];
            
            if (self.loadPhotoHandler) {
                self.loadPhotoHandler(image, nil);
                self.loadPhotoHandler = nil;
            }
        }
    }];
}

@end

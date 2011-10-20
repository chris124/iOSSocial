//
//  TwitterUserLegacy.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "TwitterUserLegacy.h"
#import "TwitterUserLegacy+Private.h"
#import "iOSSRequest.h"

@interface TwitterUserLegacy ()

@property(nonatomic, copy)      LoadPhotoHandler loadPhotoHandler;

@end

@implementation TwitterUserLegacy

@synthesize userDictionary;
@synthesize userID;
@synthesize alias;
@synthesize fetchUserDataHandler;
@synthesize loadPhotoHandler;
@synthesize profilePictureURL;

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
    NSMutableDictionary *newUserDictionary = [NSMutableDictionary dictionary];
    
    NSString *theUserID = [theUserDictionary objectForKey:@"id"];
    if (theUserID) {
        self.userID = theUserID;
        [newUserDictionary setObject:self.userID forKey:@"id"];
    }
    
    NSString *theProfilePictureURL = [theUserDictionary objectForKey:@"profile_image_url_https"];
    if (theProfilePictureURL) {
        self.profilePictureURL = theProfilePictureURL;
        [newUserDictionary setObject:self.profilePictureURL forKey:@"profile_image_url_https"];
    }
    NSString *theUsername = [theUserDictionary objectForKey:@"username"];
    if (theUsername) {
        self.alias = theUsername;
        [newUserDictionary setObject:self.alias forKey:@"username"];
    } else {
        self.alias = [theUserDictionary objectForKey:@"screen_name"];
        [newUserDictionary setObject:self.alias forKey:@"screen_name"];
    }
    
    userDictionary = newUserDictionary;
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

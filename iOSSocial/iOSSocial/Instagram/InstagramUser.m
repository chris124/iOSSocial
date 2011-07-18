//
//  InstagramUser.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstagramUser.h"
#import "InstagramUser+Private.h"
#import "IGRequest.h"

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
    
    //NSURL *imageURL = [NSURL URLWithString:profilePictureURLString];
    //UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
    //self.imageView.image = image;
}

- (void)fetchUserData
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/", self.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            //
            int i = 0;
            i = 1;
        } else {
            //
            
            NSString *jsonStr = [[NSString alloc] initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
            /*
             {"meta": {"code": 200}, "data": {"username": "mrchristopher124", "bio": "", "website": "", "profile_picture": "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg", "full_name": "", "counts": {"media": 9, "followed_by": 15, "follows": 40}, "id": "4885060"}}
             */
            
            int i = 0;
            i = 1;
        }
    }];
}

- (void)fetchRecentMedia
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent", self.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            //
            int i = 0;
            i = 1;
        } else {
            //
            
            NSString *jsonStr = [[NSString alloc] initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
            /*
             {"meta": {"code": 200}, "data": {"username": "mrchristopher124", "bio": "", "website": "", "profile_picture": "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg", "full_name": "", "counts": {"media": 9, "followed_by": 15, "follows": 40}, "id": "4885060"}}
             */
            
            int i = 0;
            i = 1;
        }
    }];
}

- (void)fetchFollows
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/follows", self.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            //
            int i = 0;
            i = 1;
        } else {
            //
            
            NSString *jsonStr = [[NSString alloc] initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
            /*
             {"meta": {"code": 200}, "data": {"username": "mrchristopher124", "bio": "", "website": "", "profile_picture": "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg", "full_name": "", "counts": {"media": 9, "followed_by": 15, "follows": 40}, "id": "4885060"}}
             */
            
            int i = 0;
            i = 1;
        }
    }];
}

- (void)fetchFollowedBy
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/followed-by", self.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            //
            int i = 0;
            i = 1;
        } else {
            //
            
            NSString *jsonStr = [[NSString alloc] initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
            /*
             {"meta": {"code": 200}, "data": {"username": "mrchristopher124", "bio": "", "website": "", "profile_picture": "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg", "full_name": "", "counts": {"media": 9, "followed_by": 15, "follows": 40}, "id": "4885060"}}
             */
            
            int i = 0;
            i = 1;
        }
    }];
}

@end

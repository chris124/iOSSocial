/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

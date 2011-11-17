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

#import "TwitterUser.h"
#import "TwitterUser+Private.h"
#import "iOSSRequest.h"

@interface TwitterUser ()

@property(nonatomic, copy)      LoadPhotoHandler loadPhotoHandler;

@end

@implementation TwitterUser

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

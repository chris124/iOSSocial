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

#import "FlickrUser.h"
#import "FlickrUser+Private.h"
#import "iOSSRequest.h"

@interface FlickrUser ()

@property(nonatomic, copy)      LoadPhotoHandler loadPhotoHandler;

@end

@implementation FlickrUser

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
    userDictionary = theUserDictionary;
    
    NSDictionary *personDictionary = [theUserDictionary objectForKey:@"person"];
    if (personDictionary) {
        //
        self.userID = [personDictionary objectForKey:@"id"];
        NSDictionary *usernameDictionary = [personDictionary objectForKey:@"username"];
        if (usernameDictionary) {
            self.alias = [usernameDictionary objectForKey:@"_content"];
        }
    } else {
        self.userID = [theUserDictionary objectForKey:@"id"];
        //self.profilePictureURL = [theUserDictionary objectForKey:@"profile_image_url_https"];
        NSString *username = [theUserDictionary objectForKey:@"username"];
        if (username) {
            self.alias = username;
        }
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

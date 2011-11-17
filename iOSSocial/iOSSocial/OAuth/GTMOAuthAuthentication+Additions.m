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

#import "GTMOAuthAuthentication+Additions.h"

@interface GTMOAuthAuthentication ()

- (void)setKeysForResponseDictionary:(NSDictionary *)dict;

@end

static NSString *const kOAuth1TwitterUserIDKey      = @"user_id";
static NSString *const kOAuth1TwitterUserNameKey    = @"screen_name";
static NSString *const kOAuth1FlickrUserIDKey       = @"user_nsid";
static NSString *const kOAuth1FlickrUserNameKey     = @"username";

@interface GTMOAuthAuthenticationWithAdditions ()

@property(nonatomic, readwrite, retain)  NSString *userID;      // User identifier.
@property(nonatomic, readwrite, retain)  NSString *username;    // The user's alias

@end

@implementation GTMOAuthAuthenticationWithAdditions

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
    
    //Try Twitter
    NSString *newUserID = [dict objectForKey:kOAuth1TwitterUserIDKey];
    if (newUserID) {
        [self setUserID:newUserID];
    }
    
    NSString *newUsername = [dict objectForKey:kOAuth1TwitterUserNameKey];
    if (newUsername) {
        [self setUsername:newUsername];
    }
    
    //Try Flickr
    newUserID = [dict objectForKey:kOAuth1FlickrUserIDKey];
    if (newUserID) {
        [self setUserID:newUserID];
    }
    
    newUsername = [dict objectForKey:kOAuth1FlickrUserNameKey];
    if (newUsername) {
        [self setUsername:newUsername];
    }
}

@end

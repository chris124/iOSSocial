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

#import "FoursquareUser.h"
#import "FoursquareUser+Private.h"
#import "iOSSRequest.h"

@interface FoursquareUser ()

@property(nonatomic, copy)      LoadPhotoHandler loadPhotoHandler;

@end


@implementation FoursquareUser

@synthesize userDictionary;
@synthesize userID;
@synthesize alias;
@synthesize firstName;
@synthesize fetchUserDataHandler;
@synthesize profilePictureURL;
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

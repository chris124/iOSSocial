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

#import "Instagram.h"
#import "iOSSLog.h"
#import "LocalInstagramUser.h"


@interface Instagram ()

@property(nonatomic, readwrite, assign)  BOOL primary;

@end

static Instagram *instagramService = nil;

@implementation Instagram

@synthesize name;
@synthesize logoImage;
@synthesize primary;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(instagramService == nil) {
            instagramService = [[super allocWithZone:NULL] init];
        }
    }
    return instagramService;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params asPrimary:(BOOL)isPrimary
{
    [super assignOAuthParams:params];
    
    self.primary = isPrimary;
    
    [[iOSSocialServicesStore sharedServiceStore] registerService:self];
}

- (NSString*)name
{
    return @"Instagram";
}

- (UIImage*)logoImage
{
    NSURL *logoURL = [[NSBundle mainBundle] URLForResource:@"instagram_trans" withExtension:@"png"];
    UIImage *theLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:logoURL]];
    return theLogoImage;
}

- (NSString*)serviceKeychainItemName
{
    return self.keychainItemName;
}

- (id<iOSSocialLocalUserProtocol>)localUser
{
    return [[LocalInstagramUser alloc] init];
}

- (id<iOSSocialLocalUserProtocol>)localUserWithDictionary:(NSDictionary*)dictionary
{
    LocalInstagramUser *theUser = [[LocalInstagramUser alloc] initWithDictionary:dictionary];
    return theUser;
}

- (id<iOSSocialLocalUserProtocol>)localUserWithIdentifier:(NSString*)identifier
{
    return [[LocalInstagramUser alloc] initWithIdentifier:identifier];
}

@end

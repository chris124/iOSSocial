//
//  Flickr.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Flickr.h"
#import "iOSSLog.h"
#import "LocalFlickrUser.h"

@interface Flickr ()

@property(nonatomic, readwrite, assign)  BOOL primary;

@end

static Flickr *FlickrService = nil;

@implementation Flickr

@synthesize name;
@synthesize logoImage;
@synthesize primary;
@synthesize keychainItemName;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(FlickrService == nil) {
            FlickrService = [[super allocWithZone:NULL] init];
        }
    }
    return FlickrService;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
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
    return @"Flickr";
}

- (UIImage*)logoImage
{
    NSURL *logoURL = [[NSBundle mainBundle] URLForResource:@"flickr-logo" withExtension:@"png"];
    UIImage *theLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:logoURL]];
    return theLogoImage;
}

- (NSString*)serviceKeychainItemName
{
    return self.keychainItemName;
}

- (id<iOSSocialLocalUserProtocol>)localUser
{
    return [[LocalFlickrUser alloc] init];
}

- (id<iOSSocialLocalUserProtocol>)localUserWithDictionary:(NSDictionary*)dictionary
{
    LocalFlickrUser *theUser = [[LocalFlickrUser alloc] initWithDictionary:dictionary];
    return theUser;
}

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid
{
    return [[LocalFlickrUser alloc] initWithUUID:uuid];
}

@end

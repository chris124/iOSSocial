//
//  Foursquare.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Foursquare.h"
#import "iOSSLog.h"
#import "LocalFoursquareUser.h"


@interface Foursquare ()

@property(nonatomic, readwrite, assign)  BOOL primary;

@end

static Foursquare *foursquareService = nil;

@implementation Foursquare

@synthesize name;
@synthesize logoImage;
@synthesize primary;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(foursquareService == nil) {
            foursquareService = [[super allocWithZone:NULL] init];
            [[iOSSocialServicesStore sharedServiceStore] registerService:foursquareService];
        }
    }
    return foursquareService;
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
}

- (NSString*)name
{
    return @"Foursquare";
}

- (UIImage*)logoImage
{
    NSURL *logoURL = [[NSBundle mainBundle] URLForResource:@"foursquare_trans" withExtension:@"png"];
    UIImage *theLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:logoURL]];
    return theLogoImage;
}

- (id<iOSSocialLocalUserProtocol>)localUser
{
    return [[LocalFoursquareUser alloc] init];
}

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid
{
    return [[LocalFoursquareUser alloc] initWithUUID:uuid];
}

@end

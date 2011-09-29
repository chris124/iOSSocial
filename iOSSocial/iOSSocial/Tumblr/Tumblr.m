//
//  Tumblr.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Tumblr.h"
#import "iOSSLog.h"
#import "LocalTumblrUser.h"

@interface Tumblr ()

@property(nonatomic, readwrite, assign)  BOOL primary;

@end

static Tumblr *TumblrService = nil;

@implementation Tumblr

@synthesize name;
@synthesize logoImage;
@synthesize primary;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(TumblrService == nil) {
            TumblrService = [[super allocWithZone:NULL] init];
            [[iOSSocialServicesStore sharedServiceStore] registerService:TumblrService];
        }
    }
    return TumblrService;
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
}

- (NSString*)name
{
    return @"Tumblr";
}

- (UIImage*)logoImage
{
    NSURL *logoURL = [[NSBundle mainBundle] URLForResource:@"tumblr-logo" withExtension:@"png"];
    UIImage *theLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:logoURL]];
    return theLogoImage;
}

- (id<iOSSocialLocalUserProtocol>)localUser
{
    return [[LocalTumblrUser alloc] init];
}

- (id<iOSSocialLocalUserProtocol>)localUserWithDictionary:(NSDictionary*)dictionary
{
    return nil;
}

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid
{
    return [[LocalTumblrUser alloc] initWithUUID:uuid];
}

@end

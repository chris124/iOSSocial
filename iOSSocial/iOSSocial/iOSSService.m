//
//  iOSSService.m
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSService.h"
#import "iOSSocialLocalUser.h"

@interface iOSSService ()

@property(nonatomic, readwrite, retain)  NSString *name;
@property(nonatomic, readwrite, retain)  NSURL *photoUrl;
@property(nonatomic, readwrite, retain)  id<iOSSocialLocalUserProtocol> localUser;

@end

@implementation iOSSService

@synthesize name;
@synthesize photoUrl;
@synthesize localUser;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)serviceDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.name = [serviceDictionary objectForKey:@"name"];
        self.photoUrl = [serviceDictionary objectForKey:@"photoUrl"];
        self.localUser = [serviceDictionary objectForKey:@"localUser"];
    }
    
    return self;
}

- (BOOL)isConnected
{
    //assert if instagram is nil. params have not been set!
    
    //if (NO == [self.instagram isSessionValid])
    //    return NO;
    return [self.localUser isAuthenticated];
}

@end

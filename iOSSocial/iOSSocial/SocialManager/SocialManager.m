//
//  SocialManager.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "SocialManager.h"
#import "Instagram.h"

static SocialManager *socialManager = nil;

@interface SocialManager ()

@property (nonatomic, readwrite, retain)   Instagram *instagram;

@end

@implementation SocialManager

@synthesize instagram;

+ (SocialManager *)socialManager
{
    @synchronized(self) {
        if(socialManager == nil)
            socialManager = [[super allocWithZone:NULL] init];
    }
    return socialManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (Instagram*)instagram
{
    if (nil == self.instagram) {
        self.instagram = [[Instagram alloc] initWithClientID:kSMInstagramClientID 
                                                clientSecret:kSMInstagramClientSecret 
                                                 redirectURI:kSMInstagramRedirectURI 
                                         andKeyChainItemName:kSMInstagramKeychainItemName];
    }
    
    return self.instagram;
}

@end

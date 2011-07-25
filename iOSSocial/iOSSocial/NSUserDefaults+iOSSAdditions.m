//
//  NSUserDefaults+iOSSAdditions.m
//  iOSSocial
//
//  Created by Christopher White on 7/19/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "NSUserDefaults+iOSSAdditions.h"

NSString *const iOSSDefaultsKeyInstagramUserDictionary = @"ioss_instagramUserDictionary";
NSString *const iOSSDefaultsKeyTwitterUserDictionary = @"ioss_twitterUserDictionary";
NSString *const iOSSDefaultsKeyFoursquareUserDictionary = @"ioss_foursquareUserDictionary";

@implementation NSUserDefaults (iOSSAdditions)

- (NSDictionary *)ioss_instagramUserDictionary 
{ 
    return [self objectForKey:iOSSDefaultsKeyInstagramUserDictionary];
}

- (void)ioss_setInstagramUserDictionary:(NSDictionary *)username 
{ 
    [self setObject:username forKey:iOSSDefaultsKeyInstagramUserDictionary];
    [self synchronize];
}

- (NSDictionary *)ioss_twitterUserDictionary 
{ 
    return [self objectForKey:iOSSDefaultsKeyTwitterUserDictionary];
}

- (void)ioss_setTwitterUserDictionary:(NSDictionary *)username 
{ 
    [self setObject:username forKey:iOSSDefaultsKeyTwitterUserDictionary];
    [self synchronize];
}

- (NSDictionary *)ioss_foursquareUserDictionary 
{ 
    return [self objectForKey:iOSSDefaultsKeyFoursquareUserDictionary];
}

- (void)ioss_setFoursquareUserDictionary:(NSDictionary *)username 
{ 
    [self setObject:username forKey:iOSSDefaultsKeyFoursquareUserDictionary];
    [self synchronize];
}

@end

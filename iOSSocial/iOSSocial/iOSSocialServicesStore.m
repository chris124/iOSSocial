//
//  iOSSocialServicesStore.m
//  iOSSocial
//
//  Created by Christopher White on 8/28/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSocialServicesStore.h"
#import "iOSSocialLocalUser.h"

NSString *const iOSSDefaultsKeyServiceStoreDictionary  = @"ioss_serviceStoreDictionary";

static iOSSocialServicesStore *serviceStore = nil;

@interface iOSSocialServicesStore () {
}

@property(nonatomic, readwrite, retain)    NSMutableArray *services;
@property(nonatomic, readwrite, retain)    NSMutableArray *accounts;
@property(nonatomic, readwrite, retain)    NSDictionary *serviceStoreDictionary;

- (void)saveAccount:(id<iOSSocialLocalUserProtocol>)theAccount;

@end

@implementation iOSSocialServicesStore

@synthesize services;
@synthesize accounts;
@synthesize serviceStoreDictionary;

+ (iOSSocialServicesStore*)sharedServiceStore
{
    @synchronized(self) {
        if(serviceStore == nil)
            serviceStore = [[super allocWithZone:NULL] init];
    }
    return serviceStore;
}

- (NSDictionary *)ioss_serviceStoreUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@", iOSSDefaultsKeyServiceStoreDictionary]];
}

- (void)ioss_setServiceStoreUserDictionary:(NSDictionary *)theServiceStoreDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theServiceStoreDictionary forKey:[NSString stringWithFormat:@"%@", iOSSDefaultsKeyServiceStoreDictionary]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setServicesStoreDictionary:(NSDictionary*)theDictionary
{
    self.serviceStoreDictionary = theDictionary;
    
    [self ioss_setServiceStoreUserDictionary:theDictionary];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.services = [NSMutableArray array];
        self.accounts = [NSMutableArray array];
        
        NSDictionary *servicesDictionary = [self ioss_serviceStoreUserDictionary];
        if (servicesDictionary) {
            [self setServicesStoreDictionary:servicesDictionary];
        }
    }
    
    return self;
}

- (void)registerService:(id<iOSSocialServiceProtocol>)theService;
{
    [self.services addObject:theService];
    
    //need to initialize the accounts here
    //iterate over the dictionary and register an acccount for each
    NSDictionary *accountsDictionary = [self.serviceStoreDictionary objectForKey:@"accounts"];
    if (accountsDictionary) {
        NSEnumerator *enumerator = [accountsDictionary objectEnumerator];
        id value;
        
        while ((value = [enumerator nextObject])) {
            /* code that acts on the dictionary’s values */
            NSDictionary *theDictionary = (NSDictionary*)value;
            NSString *service_name = [theDictionary objectForKey:@"service_name"];
            
            //get the service with the give name and then create a local user using the guid
            for (id<iOSSocialServiceProtocol> service in self.services) {
                if (NSOrderedSame == [service_name compare:service.name]) {
                    id<iOSSocialLocalUserProtocol> account = [service localUserWithUUID:[theDictionary objectForKey:@"account_uuid"]];
                    [self saveAccount:account];
                }
            }
        }
    }
}

- (void)saveAccount:(id<iOSSocialLocalUserProtocol>)theAccount
{
    BOOL bFound = NO;
    
    for (id<iOSSocialLocalUserProtocol> account in self.accounts) {
        if ((NSOrderedSame == [theAccount.servicename compare:account.servicename])
            && (NSOrderedSame == [theAccount.uuidString compare:account.uuidString])) {
            bFound = YES;
            break;
        }
    }
    
    //only add an account once. what to check for? have service name.
    if (!bFound) {
        [self.accounts addObject:theAccount];
    }
}

- (void)registerAccount:(id<iOSSocialLocalUserProtocol>)theAccount
{
    //only add an account once. what to check for? have service name.
    if (![self.accounts containsObject:theAccount]) {
        [self.accounts addObject:theAccount];
        
        //build the array of account dictionaries and then set the accounts dictionary
        NSMutableArray *theAccounts = [NSMutableArray array];
        for (id<iOSSocialLocalUserProtocol> account in self.accounts) {
            NSDictionary *accountDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:account.uuidString, account.servicename, nil] forKeys:[NSArray arrayWithObjects:@"account_uuid", @"service_name", nil]];
            [theAccounts addObject:accountDictionary];
        }
        
        NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:theAccounts forKey:@"accounts"];
        [self setServicesStoreDictionary:servicesDictionary];
    }
}

/*
- (NSArray*)accounts
{
    if (nil == _accounts) {
        _accounts = [NSMutableArray array];
    }
    
    return _accounts;
}
*/
@end

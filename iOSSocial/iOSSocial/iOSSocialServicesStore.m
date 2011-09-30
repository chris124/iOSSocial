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
    id<iOSSocialLocalUserProtocol> _defaultAccount;
}

@property(nonatomic, readwrite, retain)     NSMutableArray *services;
@property(nonatomic, readwrite, retain)     NSMutableArray *accounts;
@property(nonatomic, readwrite, retain)     NSDictionary *serviceStoreDictionary;
@property(nonatomic, readwrite, retain)     id<iOSSocialLocalUserProtocol> defaultAccount;

- (void)saveAccount:(id<iOSSocialLocalUserProtocol>)theAccount;

@end

@implementation iOSSocialServicesStore

@synthesize services;
@synthesize accounts;
@synthesize serviceStoreDictionary;
@synthesize defaultAccount=_defaultAccount;

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

- (id<iOSSocialServiceProtocol>)primaryService
{
    id<iOSSocialServiceProtocol> theService = nil;
    for (id<iOSSocialServiceProtocol> service in self.services) {
        if (YES == service.primary) {
            theService = service;
        }
    }
    return theService;
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

            NSDictionary *theDictionary = (NSDictionary*)value;
            NSString *service_name = [theDictionary objectForKey:@"service_name"];
            
            //get the service with the give name and then create a local user using the guid
            for (id<iOSSocialServiceProtocol> service in self.services) {
                if (NSOrderedSame == [service_name compare:service.name]) {
                    id<iOSSocialLocalUserProtocol> account = [service localUserWithUUID:[theDictionary objectForKey:@"account_uuid"]];
                    [self saveAccount:account];
                    
                    BOOL isPrimary = [(NSNumber*)[theDictionary objectForKey:@"primary"] boolValue];
                    if (isPrimary) {
                        self.defaultAccount = account;
                    }
                }
            }
        }
    }
}

- (id<iOSSocialServiceProtocol>)serviceWithType:(NSString*)serviceName
{
    id<iOSSocialServiceProtocol> theService = nil;
    for (id<iOSSocialServiceProtocol> service in self.services) {
        if (NSOrderedSame == [serviceName compare:service.name]) {
            theService = service;
            break;
        }
    }
    return theService;
}

- (id<iOSSocialLocalUserProtocol>)accountWithType:(NSString*)accountName
{
    id<iOSSocialLocalUserProtocol> theAccount = nil;
    for (id<iOSSocialLocalUserProtocol> account in self.accounts) {
        if (NSOrderedSame == [accountName compare:account.servicename]) {
            theAccount = account;
            break;
        }
    }
    return theAccount;
}

- (id<iOSSocialLocalUserProtocol>)accountWithDictionary:(NSDictionary*)accountDictionary
{
    //get the service for the type then create a local user with the dictionary info
    NSString *serviceName = [accountDictionary objectForKey:@"service"];
    id<iOSSocialServiceProtocol> theService = [self serviceWithType:serviceName];
    return [theService localUserWithDictionary:accountDictionary];
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
    if (theAccount && ![self.accounts containsObject:theAccount]) {
        
        if (nil == self.defaultAccount) {
            //when we register an account and there is no default account, see if there is a primary service. 
            //if there is a primary service, and this account is from that service, set it as the default
            id<iOSSocialServiceProtocol> primaryService = [self primaryService];
            if (NSOrderedSame == [theAccount.servicename compare:primaryService.name]) {
                self.defaultAccount = theAccount;
            }
        }
        
        [self.accounts addObject:theAccount];
        
        //build the array of account dictionaries and then set the accounts dictionary
        NSMutableArray *theAccounts = [NSMutableArray array];
        for (id<iOSSocialLocalUserProtocol> account in self.accounts) {
            BOOL isPrimary = (account == self.defaultAccount);
            NSDictionary *accountDictionary = [NSDictionary 
                                               dictionaryWithObjects:[NSArray arrayWithObjects:account.servicename, [NSNumber numberWithBool:isPrimary], account.uuidString, nil] 
                                               forKeys:[NSArray arrayWithObjects:@"service_name", @"primary", @"account_uuid", nil]];
            [theAccounts addObject:accountDictionary];
        }
        
        NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:theAccounts forKey:@"accounts"];
        [self setServicesStoreDictionary:servicesDictionary];
    }
}

- (id<iOSSocialLocalUserProtocol>)defaultAccount
{
    if (nil == _defaultAccount) {
        //
        id<iOSSocialServiceProtocol> primaryService = [self primaryService];
     
        _defaultAccount = [primaryService localUser];
    }
    
    return _defaultAccount;
}

@end
rKey:@"accounts"];
        [self setServicesStoreDictionary:servicesDictionary];
    }
}

- (id<iOSSocialLocalUserProtocol>)defaultAccount
{
    if (nil == _defaultAccount) {
        //
        id<iOSSocialServiceProtocol> primaryService = [self primaryService];
     
        _defaultAccount = [primaryService localUser];
    }
    
    return _defaultAccount;
}

@end

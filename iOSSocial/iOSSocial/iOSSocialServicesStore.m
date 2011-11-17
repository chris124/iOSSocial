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
                    id<iOSSocialLocalUserProtocol> account = [service localUserWithIdentifier:[theDictionary objectForKey:@"account_uuid"]];
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
            && (NSOrderedSame == [theAccount.identifier compare:account.identifier])) {
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
            
            NSArray *keys = [NSArray arrayWithObjects:@"service_name", @"primary", @"account_uuid", nil];
            if (!account.identifier) {
                keys = [NSArray arrayWithObjects:@"service_name", @"primary", nil];
            }
            NSDictionary *accountDictionary = [NSDictionary 
                                               dictionaryWithObjects:[NSArray arrayWithObjects:account.servicename, [NSNumber numberWithBool:isPrimary], account.identifier, nil] 
                                               forKeys:keys];
            [theAccounts addObject:accountDictionary];
        }
        
        NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:theAccounts forKey:@"accounts"];
        [self setServicesStoreDictionary:servicesDictionary];
    }
}

- (void)unregisterAccounts
{
    for (id<iOSSocialLocalUserProtocol> account in self.accounts) {
        [account logout];
    }
    
    [self.accounts removeAllObjects];
    
    self.defaultAccount = nil;
    
    NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:self.accounts forKey:@"accounts"];
    [self setServicesStoreDictionary:servicesDictionary];
}

- (void)unregisterAccount:(id<iOSSocialLocalUserProtocol>)theAccount
{
    if (nil != self.defaultAccount) {
        //when we register an account and there is no default account, see if there is a primary service. 
        //if there is a primary service, and this account is from that service, set it as the default
        id<iOSSocialServiceProtocol> primaryService = [self primaryService];
        if (NSOrderedSame == [theAccount.servicename compare:primaryService.name]) {
            self.defaultAccount = nil;
        }
    }
    
    [self.accounts removeObject:theAccount];
    
    //build the array of account dictionaries and then set the accounts dictionary
    NSMutableArray *theAccounts = [NSMutableArray array];
    for (id<iOSSocialLocalUserProtocol> account in self.accounts) {
        BOOL isPrimary = (account == self.defaultAccount);
        NSDictionary *accountDictionary = [NSDictionary 
                                           dictionaryWithObjects:[NSArray arrayWithObjects:account.servicename, [NSNumber numberWithBool:isPrimary], account.identifier, nil] 
                                           forKeys:[NSArray arrayWithObjects:@"service_name", @"primary", @"account_uuid", nil]];
        [theAccounts addObject:accountDictionary];
    }
    
    NSDictionary *servicesDictionary = [NSDictionary dictionaryWithObject:theAccounts forKey:@"accounts"];
    [self setServicesStoreDictionary:servicesDictionary];
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


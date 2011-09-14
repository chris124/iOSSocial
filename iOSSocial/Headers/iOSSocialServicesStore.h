//
//  iOSSocialServicesStore.h
//  iOSSocial
//
//  Created by Christopher White on 8/28/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialOAuth.h"

@class GTMOAuthAuthenticationWithAdditions;
@class GTMOAuth2Authentication;
@protocol iOSSocialLocalUserProtocol;

@protocol iOSSocialServiceProtocol <NSObject>

@required

@property(nonatomic, readonly, retain)  NSString *name;
@property(nonatomic, readonly, retain)  UIImage *logoImage;
@property(nonatomic, readonly, assign)  BOOL primary;

+ (id<iOSSocialServiceProtocol>)sharedService;

// This must be called before calling any of the non-class methods on a service otherwise it will cause an assertion.
// See iOSSocialServiceOAuth2ProviderConstants.h or iOSSocialServiceOAuthProviderConstants.h for the Keys for this dictionary.
- (void)assignOAuthParams:(NSDictionary*)params asPrimary:(BOOL)isPrimary;

- (id)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(id)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain
              withCompletionHandler:(AuthorizationHandler)completionHandler;

- (id<iOSSocialLocalUserProtocol>)localUser;

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid;

- (void)logout:(id)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

- (NSString*)apiKey;

- (NSString*)apiSecret;

- (NSString*)authorizationHeaderForRequest:(NSURLRequest *)request withAuth:(GTMOAuthAuthenticationWithAdditions*)auth;

@end

@interface iOSSocialServicesStore : NSObject

@property(nonatomic, readonly, retain)  NSMutableArray *services;
@property(nonatomic, readonly, retain)  NSMutableArray *accounts;
@property(nonatomic, readonly, retain)  id<iOSSocialLocalUserProtocol> defaultAccount;

+ (iOSSocialServicesStore*)sharedServiceStore;

- (id<iOSSocialServiceProtocol>)serviceWithType:(NSString*)serviceName;

- (id<iOSSocialLocalUserProtocol>)accountWithType:(NSString*)accountName;

- (void)registerService:(id<iOSSocialServiceProtocol>)theService;

- (void)registerAccount:(id<iOSSocialLocalUserProtocol>)theAccount;

@end

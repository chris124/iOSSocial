//
//  SocialManager.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Instagram;
@interface SocialManager : NSObject

@property (nonatomic, readonly, retain)   Instagram *instagram;

+ (SocialManager *)socialManager;

@end

#define kSMInstagramClientID            @"CHANGE ME"
#define kSMInstagramClientSecret        @"CHANGE ME"
//cwnote: this has to match the callback URL you setup on the instagram site for your app
//or you will get an OAuth error!
// We'll make up an arbitrary redirectURI.  The controller will watch for
// the server to redirect the web view to this URI, but this URI will not be
// loaded, so it need not be for any actual web page.
#define kSMInstagramRedirectURI         @"CHANGE ME"
//cwnote: maybe just use the app name for this?
#define kSMInstagramKeychainItemName    @"CHANGE ME"

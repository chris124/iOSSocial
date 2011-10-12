//
//  iOSSocialServiceOAuth2ProviderConstants.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#ifndef iOSSocial_iOSSocialServiceOAuth2ProviderConstants_h
#define iOSSocial_iOSSocialServiceOAuth2ProviderConstants_h

// OAuth Params Dictionary Keys
static NSString *const kSMOAuth2ClientID             = @"clientID";
static NSString *const kSMOAuth2ClientSecret         = @"clientSecret";
// This has to match the callback URL you setup on the provider's site for your app
// or you will get an OAuth error!
// You can make up an arbitrary redirectURI.  The controller will watch for
// the server to redirect the web view to this URI, but this URI will not be
// loaded, so it need not be for any actual web page.
static NSString *const kSMOAuth2RedirectURI          = @"redirectURI";
// Make this a unique name. Incorporate the name of your app.
// Note: this should perhaps be internalized.
static NSString *const kSMOAuth2KeychainItemName     = @"keychainItemName";

static NSString *const kSMOAuth2AuthorizeURL         = @"authorizeURL";

static NSString *const kSMOAuth2AccessTokenURL       = @"accessTokenURL";

static NSString *const kSMOAuth2ServiceProviderName  = @"serviceProviderName";

static NSString *const kSMOAuth2Scope  = @"scope";

static NSString *const kSMOAuth2URLSchemeSuffix = @"urlSchemeSuffix";

#endif

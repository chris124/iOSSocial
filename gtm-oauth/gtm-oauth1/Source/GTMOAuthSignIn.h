/* Copyright (c) 2010 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
// This sign-in object handles the sequence of fetches and displays and closes
// the web view window window as needed for users to sign in.
//
// Typically, this will be managed for the application by
// GTMOAuthWindowController, so it's interesting only if
// you are creating your own window controller for sign-in.
//
//
// Window controller delegate methods
//
// The window controller implements two methods for use by the sign-in object,
// the webRequestSelector and the finishedSelector:
//
// webRequestSelector has a signature matching
//   - (void)signIn:(GTMOAuthSignIn *)signIn displayRequest:(NSURLRequest *)request
//
// The web request selector will be invoked with a request to be displayed, or
// nil to close the window when the final callback request has been encountered.
//
//
// finishedSelector has a signature matching
//  - (void)signin:(GTMOAuthSignIn *)signin finishedWithAuth:(GTMOAuthAuthentication *)auth error:(NSError *)error
//
// The finished selector will be invoked when sign-in has completed, except
// when explicitly canceled by calling cancelSigningIn
//

#if !GTL_REQUIRE_SERVICE_INCLUDES || GTL_INCLUDE_OAUTH

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#ifdef GTL_TARGET_NAMESPACE
  #import "GTLDefines.h"
#endif

#import "GTMOAuthAuthentication.h"
#import "GTMHTTPFetcher.h"

enum {
  // error code indicating that the window was prematurely closed
  kGTMOAuthErrorWindowClosed = -1000
};

@interface GTMOAuthSignIn : NSObject {
 @private
  GTMOAuthAuthentication *auth_;

  NSURL *requestURL_;
  NSURL *authorizeURL_;
  NSURL *accessURL_;

  id delegate_;
  SEL webRequestSelector_;
  SEL finishedSelector_;

  id <GTMHTTPFetcherServiceProtocol> fetcherService_;

  GTMHTTPFetcher *pendingFetcher_;

  BOOL shouldFetchGoogleUserInfo_;

  SCNetworkReachabilityRef reachabilityRef_;
  NSTimer *networkLossTimer_;
  NSTimeInterval networkLossTimeoutInterval_;
  BOOL hasNotifiedNetworkLoss_;

  id userData_;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) GTMOAuthAuthentication *authentication;
@property (nonatomic, retain) id userData;

@property (nonatomic, retain, readonly) NSURL *requestTokenURL;
@property (nonatomic, retain, readonly) NSURL *authorizeTokenURL;
@property (nonatomic, retain, readonly) NSURL *accessTokenURL;

@property (nonatomic, assign) BOOL shouldFetchGoogleUserInfo;

// Property for the optional fetcher service instance to be used to create
// fetchers
@property (nonatomic, retain) id <GTMHTTPFetcherServiceProtocol> fetcherService;

// The default timeout for an unreachable network during display of the
// sign-in page is 30 seconds; set this to 0 to have no timeout
@property (nonatomic, assign) NSTimeInterval networkLossTimeoutInterval;

// Convenience entry point for accessing Google APIs; this creates the
// authentication object, and uses standard URL endpoints for OAuth to
// Google services
//
// The delegate is retained until sign-in has completed or been canceled
- (id)initWithGoogleAuthenticationForScope:(NSString *)scope
                                  language:(NSString *)language
                                  delegate:(id)delegate
                        webRequestSelector:(SEL)webRequestSelector
                          finishedSelector:(SEL)finishedSelector;

// Entry point for accessing non-Google APIs
//
// designated initializer
- (id)initWithAuthentication:(GTMOAuthAuthentication *)auth
             requestTokenURL:(NSURL *)requestURL
           authorizeTokenURL:(NSURL *)authorizeURL
              accessTokenURL:(NSURL *)accessURL
                    delegate:(id)delegate
          webRequestSelector:(SEL)webRequestSelector
            finishedSelector:(SEL)finishedSelector;

#pragma mark Methods used by the Window Controller

// Start the sequence of fetches and sign-in window display for sign-in
- (BOOL)startSigningIn;

// Stop any pending fetches, and close the window (but don't call the
// delegate's finishedSelector)
- (void)cancelSigningIn;

// Window controllers must tell the sign-in object about any redirect
// requested by the web view; if this returns YES then the redirect
// was handled by the sign-in object (typically by closing the window)
// and the request should be ignored by the window controller's web view
- (BOOL)requestRedirectedToRequest:(NSURLRequest *)redirectedRequest;

// Window controllers must tell the sign-in object if the window was closed
// prematurely by the user (but not by the sign-in object); this calls the
// delegate's finishedSelector
- (void)windowWasClosed;

// Revocation of an authorized token from Google
+ (void)revokeTokenForGoogleAuthentication:(GTMOAuthAuthentication *)auth;

@end

#endif // #if !GTL_REQUIRE_SERVICE_INCLUDES || GTL_INCLUDE_OAUTH

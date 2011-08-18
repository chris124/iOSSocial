//
//  IGRequest.m
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "IGRequest.h"
//#import "Instagram.h"

@implementation IGRequest

#import "LocalInstagramUser.h"
- (NSURL *)authorizedURL
{
    NSString *access_token = [NSString stringWithFormat:@"?access_token=%@", [[LocalInstagramUser localInstagramUser] oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:self.URL];
    
    return url;
    
    //return [Instagram authorizeURL:self.URL];
}

@end

/*
//#import "UIApplication+iOSSNetworkActivity.h"
#import "iOSSConnection.h"

@interface IGRequest () {
    NSDictionary *_parameters;
    IGRequestMethod _requestMethod;
    NSURL *_URL;
}

@property(nonatomic, readwrite, retain) NSDictionary *parameters;
@property(nonatomic, readwrite, assign) IGRequestMethod requestMethod;
@property(nonatomic, readwrite, retain) NSURL *URL;
@property(nonatomic, copy)      IGRequestHandler requestHandler;
@property(nonatomic, retain) iOSSConnection *connection;

@end

@implementation IGRequest

@synthesize parameters=_parameters;
@synthesize requestMethod=_requestMethod;
@synthesize URL=_URL;
@synthesize requestHandler;
@synthesize connection;
@synthesize requiresAuthentication;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        requiresAuthentication = YES;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url 
       parameters:(NSDictionary *)parameters 
    requestMethod:(IGRequestMethod)requestMethod
{
    self = [self init];
    if (self) {
        // Initialization code here.
        _URL = url;
        _parameters = parameters;
        _requestMethod = requestMethod;
    }
    
    return self;
}

- (void)addMultiPartData:(NSData *)data 
                withName:(NSString *)name 
                    type:(NSString *)type
{
    
}
#import "LocalInstagramUser.h"
- (NSURL *)authorizedURL
{
    NSString *access_token = [NSString stringWithFormat:@"?access_token=%@", [[LocalInstagramUser localInstagramUser] oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:self.URL];
    
    return url;
    
    //return [Instagram authorizeURL:self.URL];
}

- (void)performRequestWithHandler:(IGRequestHandler)handler
{
    self.requestHandler = handler;
    
    if (self.requiresAuthentication) {
        self.URL = [self authorizedURL];
    }

    switch (self.requestMethod) {
        case IGRequestMethodGET:
        {
            self.connection = [iOSSConnection connectionWithURL:self.URL progressBlock:^(iOSSConnection *theConnection) {
                if (theConnection) {
                    //
                    int i = 0;
                    i = 1;
                }
            } authorizationBlock:^(iOSSConnection *theConnection) {
                //
            } completionBlock:^(iOSSConnection *theConnection, NSError *error) {
                if (self.requestHandler) {
                    self.requestHandler(theConnection.downloadData, theConnection.httpResponse, error);
                }
            }];
        }
            break;
            
        case IGRequestMethodPOST:
        {
            
        }
            break;
            
        case IGRequestMethodDELETE:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    //cwnote: make sure we POP!
    //[[UIApplication sharedApplication] ioss_pushNetworkActivity];
    
    //now start the connection
    [self.connection start];
}

@end
*/
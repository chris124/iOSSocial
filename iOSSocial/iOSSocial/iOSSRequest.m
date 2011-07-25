//
//  iOSSRequest.m
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSRequest.h"
//#import "UIApplication+iOSSNetworkActivity.h"
#import "iOSSConnection.h"

@interface iOSSRequest () {
    NSDictionary *_parameters;
    iOSSRequestMethod _requestMethod;
    NSURL *_URL;
}

@property(nonatomic, readwrite, retain) NSDictionary *parameters;
@property(nonatomic, readwrite, assign) iOSSRequestMethod requestMethod;
@property(nonatomic, readwrite, retain) NSURL *URL;
@property(nonatomic, copy)      iOSSRequestHandler requestHandler;
@property(nonatomic, retain) iOSSConnection *connection;

@end

@implementation iOSSRequest

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
    requestMethod:(iOSSRequestMethod)requestMethod
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

- (NSURL *)authorizedURL
{
    return nil;
    //return [Instagram authorizeURL:self.URL];
}

- (void)performRequestWithHandler:(iOSSRequestHandler)handler
{
    self.requestHandler = handler;
    
    if (self.requiresAuthentication) {
        self.URL = [self authorizedURL];
    }
    
    switch (self.requestMethod) {
        case iOSSRequestMethodGET:
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
            
        case iOSSRequestMethodPOST:
        {
            
        }
            break;
            
        case iOSSRequestMethodDELETE:
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

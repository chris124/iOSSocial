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
#import "ASIFormDataRequest.h"

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
@property(nonatomic, retain) ASIFormDataRequest *request;

@end

@implementation iOSSRequest

@synthesize parameters=_parameters;
@synthesize requestMethod=_requestMethod;
@synthesize URL=_URL;
@synthesize requestHandler;
@synthesize connection;
@synthesize request;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
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

/*
- (void)requestFinished:(ASIHTTPRequest *)req
{    
    NSError *error = nil;
    self.response = [NSDictionary dictionaryWithJSONString:[req responseString] error:&error];
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            error = [[[NSError alloc] initWithDomain:@"JSONparseError" 
                                                code:[req responseStatusCode] 
                                            userInfo: [NSDictionary dictionaryWithObject:[req responseString] forKey:@"responseString"]] autorelease];
            [self.delegate request:self didFailWithError:[req error]];
        }
    } else if ( ! ([[response objectForKey:@"status"] isEqualToString:@"ok"]) ) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            error = [[[NSError alloc] initWithDomain:@"serverError" code:[req responseStatusCode] userInfo:self.response ] autorelease];
            [self.delegate request:self didFailWithError:[req error]];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
            [self.delegate requestDidFinishLoading:self];
            
        }
    }
    [self release];
}
*/
- (void)performRequestWithHandler:(iOSSRequestHandler)handler
{
    self.requestHandler = handler;
    
    iOSSRequest *theRequest = self;
    
    switch (self.requestMethod) {
        case iOSSRequestMethodGET:
        {
            self.request = [ASIHTTPRequest requestWithURL:self.URL];
            self.request.completionBlock = ^(void) {
                if (theRequest.requestHandler) {
                    //NSError *error = nil;
                    //NSDictionary *response = [NSDictionary dictionaryWithJSONString:[self.request responseString] error:&error];
                   // NSString *response = [theRequest.request responseString];
                    theRequest.requestHandler([theRequest.request responseData], nil, theRequest.request.error);
                }
            };
            
            [self.request setFailedBlock:^(void) {
                NSLog(@"failed");
                if (theRequest.requestHandler) {
                    //self.requestHandler(nil, self.request.error);
                    theRequest.requestHandler(nil, nil, theRequest.request.error);
                }
            } ];
            /*
            ASIDataBlock dataBlock = ^(NSData *data) {
                if (self.requestHandler) {
                    self.requestHandler(theConnection.downloadData, theConnection.httpResponse, error);
                }
            };
            [request setDataReceivedBlock:dataBlock];
            */
            [self.request startAsynchronous];
            
            /*
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
             */
        }
            break;
            
        case iOSSRequestMethodPOST:
        {
            self.request = [ASIFormDataRequest requestWithURL:self.URL];
            
            NSArray *keys = [self.parameters allKeys];
            for (NSString *key in keys) {
                [self.request addPostValue:[self.parameters objectForKey:key] forKey:key];
            }
            
            self.request.completionBlock = ^(void) {
                if (theRequest.requestHandler) {
                    //NSError *error = nil;
                    //NSDictionary *response = [NSDictionary dictionaryWithJSONString:[self.request responseString] error:&error];
                    //NSString *response = [theRequest.request responseString];
                    theRequest.requestHandler([theRequest.request responseData], nil, theRequest.request.error);
                }
                
                /*
                NSData *data = theRequest.request.responseData;
                data = nil;
                //if (self.requestHandler) {
                //self.requestHandler(self.request.responseData, self.request.error);
                //}
                */
            };
            
            [self.request setFailedBlock:^(void) {
                NSLog(@"failed");
                if (theRequest.requestHandler) {
                    //self.requestHandler(nil, self.request.error);
                    theRequest.requestHandler(nil, nil, theRequest.request.error);
                }
            } ];
            
            //self.request.delegate = self;
            [self.request startAsynchronous];
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

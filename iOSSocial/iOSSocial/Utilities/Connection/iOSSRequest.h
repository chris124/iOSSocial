//
//  iOSSRequest.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


enum iOSSRequestMethod {
    iOSSRequestMethodGET,
    iOSSRequestMethodPOST,
    iOSSRequestMethodDELETE
};
typedef enum iOSSRequestMethod iOSSRequestMethod;

typedef void(^iOSSRequestHandler)(NSString *responseString, NSError *error);

@interface iOSSRequest : NSObject {
    BOOL    requiresAuthentication;
}

- (id)initWithURL:(NSURL *)url 
       parameters:(NSDictionary *)parameters 
    requestMethod:(iOSSRequestMethod)requestMethod;

@property(nonatomic, readonly, retain) NSDictionary *parameters;
@property(nonatomic, readonly, assign) iOSSRequestMethod requestMethod;
@property(nonatomic, readonly, retain) NSURL *URL;
@property(nonatomic, assign)    BOOL requiresAuthentication;

- (void)addMultiPartData:(NSData *)data 
                withName:(NSString *)name 
                    type:(NSString *)type;

- (NSURL *)authorizedURL;

- (void)performRequestWithHandler:(iOSSRequestHandler)handler;

@end
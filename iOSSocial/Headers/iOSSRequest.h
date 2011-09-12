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

//typedef void(^iOSSRequestHandler)(NSString *responseString, NSError *error);
typedef void(^iOSSRequestHandler)(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error);

@interface iOSSRequest : NSObject {
}

- (id)initWithURL:(NSURL *)url 
       parameters:(NSDictionary *)parameters 
    requestMethod:(iOSSRequestMethod)requestMethod;

@property(nonatomic, readonly, retain) NSDictionary *parameters;
@property(nonatomic, readonly, assign) iOSSRequestMethod requestMethod;
@property(nonatomic, readonly, retain) NSURL *URL;

- (void)addMultiPartData:(NSData *)data 
                withName:(NSString *)name 
                    type:(NSString *)type;

- (void)performRequestWithHandler:(iOSSRequestHandler)handler;

@end
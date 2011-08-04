//
//  iOSSConnection.h
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iOSSConnection;

typedef void (^iOSSConnectionProgressBlock)(iOSSConnection *connection);
typedef void (^iOSSAuthorizationProgressBlock)(iOSSConnection *connection); 
typedef void (^iOSSConnectionCompletionBlock)(iOSSConnection *connection, NSError *error);

@interface iOSSConnection : NSObject

@property (nonatomic, copy, readonly) NSURL *url; 
@property (nonatomic, copy) NSMutableURLRequest *urlRequest; 
@property (nonatomic, assign, readonly) NSInteger contentLength; 
@property (nonatomic, retain, readonly) NSMutableData *downloadData; 
@property (nonatomic, retain, readonly) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign, readonly) float percentComplete; 
@property (nonatomic, assign) NSUInteger progressThreshold;

+ (id)connectionWithURL:(NSURL *)requestURL 
          progressBlock:(iOSSConnectionProgressBlock)progress 
     authorizationBlock:(iOSSAuthorizationProgressBlock)authorization
        completionBlock:(iOSSConnectionCompletionBlock)completion;

+ (id)connectionWithRequest:(NSMutableURLRequest *)request 
              progressBlock:(iOSSConnectionProgressBlock)authorization 
         authorizationBlock:(iOSSAuthorizationProgressBlock)progress
            completionBlock:(iOSSConnectionCompletionBlock)completion;

- (void)start;
- (void)stop;

@end

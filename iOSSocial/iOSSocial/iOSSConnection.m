//
//  iOSSConnection.m
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSConnection.h"

@interface iOSSConnection ()

@property (nonatomic, copy, readwrite) NSURL *url; 
//@property (nonatomic, copy, readwrite) NSURLRequest *urlRequest;
@property (nonatomic, assign, readwrite) NSInteger contentLength;
@property (nonatomic, retain, readwrite) NSMutableData *downloadData;
@property (nonatomic, retain, readwrite) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign, readwrite) float percentComplete;
@property (nonatomic, retain) NSURLConnection *urlConnection;
@property(nonatomic, copy)      iOSSConnectionProgressBlock progressHandler;
@property(nonatomic, copy)      iOSSConnectionCompletionBlock completionHandler;
@property(nonatomic, copy)      iOSSAuthorizationProgressBlock authorizationHandler;

@property (nonatomic, assign, readwrite) float previousMilestone;

@end

@implementation iOSSConnection

@synthesize url;
@synthesize urlRequest;
@synthesize contentLength;
@synthesize downloadData;
@synthesize httpResponse;
@synthesize percentComplete;
@synthesize progressThreshold;
@synthesize previousMilestone;
@synthesize urlConnection;
@synthesize progressHandler;
@synthesize completionHandler;
@synthesize authorizationHandler;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (id)connectionWithRequest:(NSMutableURLRequest *)request 
              progressBlock:(iOSSConnectionProgressBlock)progress 
         authorizationBlock:(iOSSAuthorizationProgressBlock)authorization
            completionBlock:(iOSSConnectionCompletionBlock)completion
{
    iOSSConnection *connection = [[iOSSConnection alloc] init];
    connection.urlRequest = request;
    connection.progressHandler = progress;
    connection.completionHandler = completion;
    connection.authorizationHandler = authorization;
    connection.url = [request URL];
    
    //let the requester sign it themselves
    if (connection.authorizationHandler) {
        connection.authorizationHandler(connection);
    }
    
    connection.urlConnection = [NSURLConnection connectionWithRequest:request 
                                                             delegate:connection];
    return connection;
}

+ (id)connectionWithURL:(NSURL *)requestURL 
          progressBlock:(iOSSConnectionProgressBlock)progress 
     authorizationBlock:(iOSSAuthorizationProgressBlock)authorization
        completionBlock:(iOSSConnectionCompletionBlock)completion
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    return [iOSSConnection connectionWithRequest:request 
                                   progressBlock:progress 
                              authorizationBlock:authorization
                                 completionBlock:completion];
}

- (float)percentComplete 
{ 
    if (self.contentLength <= 0) 
        return 0; 
    return (([self.downloadData length] * 1.0f) / self.contentLength) * 100;
}

- (void)start 
{
    [self.urlConnection start];
}

- (void)stop
{
    [self.urlConnection cancel];
}

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
    if (self.completionHandler) 
        self.completionHandler(self, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.completionHandler) 
        self.completionHandler(self, nil);
}

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response 
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) { 
        self.httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = [self.httpResponse statusCode];
        if (statusCode == 200) {
            NSDictionary *header = [self.httpResponse allHeaderFields]; 
            NSString *contentLen = [header valueForKey:@"Content-Length"]; 
            NSInteger length = self.contentLength = [contentLen integerValue]; 
            self.downloadData = [NSMutableData dataWithCapacity:length];
        }
    }
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data 
{ 
    [self.downloadData appendData:data]; 
    float pctComplete = floor([self percentComplete]); 
    if ((pctComplete - self.previousMilestone) >= self.progressThreshold) {
        self.previousMilestone = pctComplete; 
        if (self.progressHandler) 
            self.progressHandler(self);
    }
}

@end

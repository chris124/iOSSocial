//
//  iOSSMultipartPOSTRequest.h
//  iOSSocial
//
//  Created by Christopher White on 7/20/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class iOSSMultipartPOSTRequest;

typedef void(^iOSSBodyCompletionBlock)(iOSSMultipartPOSTRequest *request);
typedef void(^iOSSBodyErrorBlock)(iOSSMultipartPOSTRequest *request, NSError *error);

@interface iOSSMultipartPOSTRequest : NSMutableURLRequest <NSStreamDelegate>

@property (nonatomic, copy) NSString *HTTPBoundary; 
@property (nonatomic, retain) NSDictionary *formParameters;

- (void)setUploadFile:(NSString *)path 
          contentType:(NSString *)type
            nameParam:(NSString *)nameParam 
             filename:(NSString *)fileName;

- (void)prepareForUploadWithCompletionBlock:(iOSSBodyCompletionBlock)completion 
                                 errorBlock:(iOSSBodyErrorBlock)error;

@end

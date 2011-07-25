//
//  FacebookUser.m
//  MadRaces
//
//  Created by Christopher White on 7/5/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import "FacebookUser.h"
#import "SocialManager.h"
#import "FBConnect.h"

@interface FacebookUser () <FBRequestDelegate>

@property(nonatomic, readwrite, retain) NSString *userID;
@property(nonatomic, readwrite, retain) NSString *alias;
@property(nonatomic, readwrite, retain) NSString *firstName;
@property(nonatomic, readwrite, retain) NSString *lastName;
@property(nonatomic, readwrite, retain) NSString *email;
@property (nonatomic, retain)           NSMutableDictionary *requestDictionary;
@property (nonatomic, copy)             LoadPhotoHandler loadPhotoHandler;

typedef enum _FBRequestType {
	FBUserRequestType = 0,
    FBUserPictureRequestType = 1,
    FBUserFriendsRequestType = 2,
    FBUsersRequestType = 3,
    FBCreatePhotoAlbumRequestType = 4,
    FBUserPhotoAlbumsRequestType
} FBRequestType;

- (void)recordRequest:(FBRequest*)request withType:(FBRequestType)type;

@end

@implementation FacebookUser

@synthesize userID;
@synthesize alias;
@synthesize isFriend;
@synthesize firstName;
@synthesize lastName;
@synthesize email;
@synthesize requestDictionary;
@synthesize loadPhotoHandler;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)userDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.firstName = [userDictionary objectForKey:@"first_name"];
        self.lastName = [userDictionary objectForKey:@"last_name"];
        self.userID = [userDictionary objectForKey:@"id"];
        self.alias = [userDictionary objectForKey:@"username"];
        self.email = [userDictionary objectForKey:@"email"];
    }
    
    return self;
}

- (void)dealloc
{
    //null out the delegates on any outstanding requests?
    
    [loadPhotoHandler release];
    [requestDictionary release];
    [lastName release];
    [firstName release];
    [email release];
    [alias release];
    [userID release];
    [super dealloc];
}

- (BOOL)isFriend
{
    //need logic to determine if user is friend of local user
    return NO;
}

- (void)recordRequest:(FBRequest*)request withType:(FBRequestType)type
{
    //put the url in a dictionary as the key and the response type as the value?
    //put the url of the request in a set
    //need a mutable dictionary to store these in.
    if (nil == self.requestDictionary) {
        self.requestDictionary = [NSMutableDictionary dictionary];
    }
    
    [self.requestDictionary setObject:[NSNumber numberWithInt:type] forKey:request.url];
}

- (FBRequestType)requestTypeForRequest:(FBRequest*)request
{
    return [(NSNumber*)[self.requestDictionary objectForKey:request.url] intValue];
}

- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler
{
    self.loadPhotoHandler = completionHandler;
    
    NSString *path = [NSString stringWithFormat:@"%@/picture", self.userID];
    FBRequest *request = [[SocialManager socialManager].facebook requestWithGraphPath:path andDelegate:self];
    [self recordRequest:request withType:FBUserPictureRequestType];
}

#pragma mark -
#pragma mark FBRequestDelegate

/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request
{
    NSLog(@"requestLoading");
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");

    FBRequestType requestType = [self requestTypeForRequest:request];
    switch (requestType) {
            
        case FBUserRequestType:
        {
            
        }
            break;
            
        case FBUserPictureRequestType:
        {
            if (self.loadPhotoHandler) {
                self.loadPhotoHandler(nil, nil);
                self.loadPhotoHandler = nil;
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.requestDictionary removeObjectForKey:request.url];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result
{
    NSLog(@"didLoad");

    FBRequestType requestType = [self requestTypeForRequest:request];
    switch (requestType) {
            
        case FBUserRequestType:
        {
            NSDictionary *dictionary = (NSDictionary*)result;
            self.firstName = [dictionary objectForKey:@"first_name"];
            self.lastName = [dictionary objectForKey:@"last_name"];
            self.userID = [dictionary objectForKey:@"id"];
            self.alias = [dictionary objectForKey:@"username"];
            self.email = [dictionary objectForKey:@"email"];
        }
            break;
            
        case FBUserPictureRequestType:
        {
            UIImage *image = [UIImage imageWithData:result];
            if (self.loadPhotoHandler) {
                self.loadPhotoHandler(image, nil);
                self.loadPhotoHandler = nil;
            }
        }
            break;
            
        default:
            break;
    }
    
    [self.requestDictionary removeObjectForKey:request.url];
}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data
{
    NSLog(@"didLoadRawResponse");
}

@end

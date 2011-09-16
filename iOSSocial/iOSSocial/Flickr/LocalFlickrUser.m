//
//  LocalFlickrUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalFlickrUser.h"
#import "Flickr.h"
#import "FlickrUser+Private.h"
#import "iOSSRequest.h"
#import "GTMOAuthAuthentication+Additions.h"
#import "iOSSLog.h"

NSString *const iOSSDefaultsKeyFlickrUserDictionary    = @"ioss_FlickrUserDictionary";

static LocalFlickrUser *localFlickrUser = nil;

@interface LocalFlickrUser () 

@property(nonatomic, copy)      FlickrAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    GTMOAuthAuthenticationWithAdditions *auth;
@property(nonatomic, retain)    NSString *keychainItemName;
@property(nonatomic, retain)    NSString *uuidString;
@property(nonatomic, retain)    NSMutableString *currentElementData;
@property(nonatomic, copy)      PostPhotoDataHandler postPhotoDataHandler;
@property(nonatomic, copy)      PhotoInfoDataHandler photoInfoDataHandler;
@property(nonatomic, copy)      PhotoSizesDataHandler photoSizesDataHandler;
@property(nonatomic, copy)      UserPhotosDataHandler userPhotosDataHandler;

@end

@implementation LocalFlickrUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize auth;
@synthesize keychainItemName;
@synthesize uuidString;
@synthesize currentElementData;
@synthesize postPhotoDataHandler;
@synthesize photoInfoDataHandler;
@synthesize photoSizesDataHandler;
@synthesize userPhotosDataHandler;

+ (LocalFlickrUser *)localFlickrUser
{
    @synchronized(self) {
        if(localFlickrUser == nil)
            localFlickrUser = [[super allocWithZone:NULL] init];
    }
    return localFlickrUser;
}

+ (id<iOSSocialLocalUserProtocol>)localUser
{
    @synchronized(self) {
        if(localFlickrUser == nil)
            localFlickrUser = [[super allocWithZone:NULL] init];
    }
    return localFlickrUser;
}

- (NSDictionary *)ioss_FlickrUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyFlickrUserDictionary, self.uuidString]];
}

- (void)ioss_setFlickrUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyFlickrUserDictionary, self.uuidString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    self = [super init];
    if (self) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        self.uuidString = (__bridge NSString *)uuidStr;
        CFRelease(uuidStr);
        CFRelease(uuid); 
        
        self.keychainItemName = [NSString stringWithFormat:@"InstaBeta_Flickr_Service-%@", self.uuidString];
        self.auth = [[Flickr sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_FlickrUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (id)initWithUUID:(NSString*)uuid
{
    self = [super init];
    if (self) {
        self.uuidString = uuid;
        
        self.keychainItemName = [NSString stringWithFormat:@"InstaBeta_Flickr_Service-%@", self.uuidString];
        self.auth = [[Flickr sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_FlickrUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    if (theUserDictionary) {
        [super setUserDictionary:theUserDictionary];
        
        [self ioss_setFlickrUserDictionary:theUserDictionary];
    } else {
        iOSSLog(@"meh: no user dictionary");
    }
}

- (BOOL)isAuthenticated
{
    if (NO == self.auth.canAuthorize)
        return NO;
    return YES;
}

- (NSURL*)authorizedURL:(NSURL*)theURL
{
    return nil;
}

- (void)getUserPhotosWithCompletionHandler:(UserPhotosDataHandler)completionHandler;
{
    self.userPhotosDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.activity.userPhotos&format=json&nojsoncallback=1"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Flickr sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Flickr sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:self.auth.tokenSecret forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.userPhotosDataHandler) {
                self.userPhotosDataHandler(nil, error);
                self.userPhotosDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Flickr JSONFromData:responseData];
            
            if (self.userPhotosDataHandler) {
                self.userPhotosDataHandler(dictionary, nil);
                self.userPhotosDataHandler = nil;
            }
        }
    }];
}

- (void)getPhotoSizesForPhotoWithId:(NSString*)photoID andCompletionHandler:(PhotoSizesDataHandler)completionHandler
{
    self.photoSizesDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&photo_id=%@&format=json&nojsoncallback=1", photoID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Flickr sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Flickr sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:self.auth.tokenSecret forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.photoSizesDataHandler) {
                self.photoSizesDataHandler(nil, error);
                self.photoSizesDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Flickr JSONFromData:responseData];
            
            if (self.photoSizesDataHandler) {
                self.photoSizesDataHandler(dictionary, nil);
                self.photoSizesDataHandler = nil;
            }
        }
    }];
}

- (void)getInfoForPhotoWithId:(NSString*)photoID andCompletionHandler:(PhotoInfoDataHandler)completionHandler
{
    self.photoInfoDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&photo_id=%@&format=json&nojsoncallback=1", photoID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Flickr sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Flickr sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:self.auth.tokenSecret forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.photoInfoDataHandler) {
                self.photoInfoDataHandler(nil, error);
                self.photoInfoDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Flickr JSONFromData:responseData];
            
            if (self.photoInfoDataHandler) {
                self.photoInfoDataHandler(dictionary, nil);
                self.photoInfoDataHandler = nil;
            }
        }
    }];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict 
{
    
    if ( [elementName isEqualToString:@"photoid"]) {
        return;
    }
    
    // .... continued for remaining elements ....
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string 
{	
    if (self.currentElementData == nil) {
        self.currentElementData = [[NSMutableString alloc] init];
    }
	
    [self.currentElementData appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {

    if ( [elementName isEqualToString:@"photoid"]) {
        if (self.postPhotoDataHandler) {
            NSString *photoID = [self.currentElementData stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            self.postPhotoDataHandler(photoID, nil);
            self.postPhotoDataHandler = nil;
        }
    }

    self.currentElementData = nil;
}

- (void)postPhotoData:(NSData*)imageData 
         withFileName:(NSString *)fileName 
 andCompletionHandler:(PostPhotoDataHandler)completionHandler
{
    self.postPhotoDataHandler = completionHandler;

    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/upload/"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"bananas" forKey:@"title"];
    [params setObject:@"this is too cool for school" forKey:@"description"];
    [params setObject:@"swirlapp vans" forKey:@"tags"];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:params 
                                              requestMethod:iOSSRequestMethodPOST];
    
    [request addData:imageData withFileName:fileName andContentType:@"image/jpeg" forKey:@"photo"];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Flickr sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Flickr sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:self.auth.tokenSecret forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.postPhotoDataHandler) {
                self.postPhotoDataHandler(nil, error);
                self.postPhotoDataHandler = nil;
            }
        } else {
            
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
            parser.delegate = self;
            if (NO == [parser parse]) {
                //report error here
                if (self.postPhotoDataHandler) {
                    self.postPhotoDataHandler(nil, nil);
                    self.postPhotoDataHandler = nil;
                }
            }
        }
    }];
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;

    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.people.getInfo&user_id=%@&format=json&nojsoncallback=1", self.userID];
    
    NSURL *url = [NSURL URLWithString:urlString];

    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Flickr sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Flickr sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:self.auth.tokenSecret forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Flickr JSONFromData:responseData];
            self.userDictionary = dictionary;
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

        [[Flickr sharedService] authorizeFromViewController:vc 
                                                     forAuth:self.auth 
                                         andKeychainItemName:self.keychainItemName 
                                             andCookieDomain:@"flickr.com" 
                                       withCompletionHandler:^(GTMOAuthAuthentication *theAuth, NSDictionary *userInfo, NSError *error) {
            self.auth = (GTMOAuthAuthenticationWithAdditions*)theAuth;
            if (error) {
                if (self.authenticationHandler) {
                    self.authenticationHandler(error);
                    self.authenticationHandler = nil;
                }
            } else {
                if (userInfo) {
                    NSDictionary *user = [userInfo objectForKey:@"user"];
                    self.userDictionary = user;
                }

                [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
                    if (!error) {
                        [[iOSSocialServicesStore sharedServiceStore] registerAccount:self];
                    }
                    
                    if (self.authenticationHandler) {
                        self.authenticationHandler(error);
                        self.authenticationHandler = nil;
                    }
                }];
            }
        }];
    } else {
        [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
            if (!error) {
                //
            }
            
            if (self.authenticationHandler) {
                self.authenticationHandler(error);
                self.authenticationHandler = nil;
            }
        }];
    }
}

- (NSString*)oAuthAccessToken
{
    return self.auth.accessToken;
}

- (NSString*)oAuthAccessTokenSecret
{
    return self.auth.accessToken;
}

- (void)logout
{
    [[Flickr sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
    self.auth = nil;
}

- (NSString*)userId
{
    return self.userID;
}

- (NSString*)username
{
    return self.alias;
}

- (NSString*)servicename
{
    return [Flickr sharedService].name;
}

@end

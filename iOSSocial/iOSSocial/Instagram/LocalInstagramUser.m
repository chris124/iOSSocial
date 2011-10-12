//
//  LocalInstagramUser.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalInstagramUser.h"
#import "iOSSLog.h"
#import "Instagram.h"
#import "iOSSRequest.h"
#import "InstagramUser+Private.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "iOSSocialServiceOAuth2Provider.h"


NSString *const iOSSDefaultsKeyInstagramUserDictionary  = @"ioss_instagramUserDictionary";

static LocalInstagramUser *localInstagramUser = nil;

@interface LocalInstagramUser () 

@property(nonatomic, copy)              InstagramAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)            GTMOAuth2Authentication *auth;
@property(nonatomic, retain)            NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *uuidString;
@property(nonatomic, copy)              FetchUserDataHandler fetchUserDataHandler;
@property(nonatomic, copy)              FetchMediaHandler fetchMediaHandler;
@property(nonatomic, copy)              FetchUsersHandler   fetchUsersHandler;

@end

@implementation LocalInstagramUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize auth;
@synthesize keychainItemName;
@synthesize uuidString;
@synthesize fetchUserDataHandler;
@synthesize fetchMediaHandler;
@synthesize fetchUsersHandler;

+ (LocalInstagramUser *)localInstagramUser
{
    @synchronized(self) {
        if(localInstagramUser == nil)
            localInstagramUser = [[super allocWithZone:NULL] init];
    }
    return localInstagramUser;
}

- (NSDictionary *)ioss_instagramUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyInstagramUserDictionary, self.uuidString]];
}

- (void)ioss_setInstagramUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyInstagramUserDictionary, self.uuidString]];
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

        self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[Instagram sharedService] serviceKeychainItemName], self.uuidString];
        self.auth = [[Instagram sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_instagramUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        //set the local user dictionary based on params that have been sent in
        self.auth.accessToken = [dictionary objectForKey:@"access_token"];
        NSMutableDictionary *localUserDictionary = [NSMutableDictionary dictionary];
        [localUserDictionary setObject:[dictionary objectForKey:@"userId"] forKey:@"id"];
        [localUserDictionary setObject:[dictionary objectForKey:@"username"] forKey:@"username"];
        self.userDictionary = localUserDictionary;
    }
    return self;
}

- (id)initWithUUID:(NSString*)uuid
{
    self = [super init];
    if (self) {
        self.uuidString = uuid;
        
        self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[Instagram sharedService] serviceKeychainItemName], self.uuidString];
        self.auth = [[Instagram sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_instagramUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (BOOL)isAuthenticated
{
    if (NO == self.auth.canAuthorize)
        return NO;
    return YES;
}

- (NSURL *)authorizedURL:(NSURL*)theURL
{
    NSString *access_token = [NSString stringWithFormat:@"?access_token=%@", [self oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:theURL];
    
    return url;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = @"https://api.instagram.com/v1/users/self/";
    NSURL *url = [self authorizedURL:[NSURL URLWithString:urlString]];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Instagram JSONFromData:responseData];
            self.userDictionary = [dictionary objectForKey:@"data"];
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)fetchRelationshipToUser:(InstagramUser*)user
{
    //pass in user object. return relationship
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/relationship", user.userID];
    NSURL *url = [self authorizedURL:[NSURL URLWithString:urlString]];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
        } else {
            //NSDictionary *dictionary = [Instagram JSONFromData:responseData];
            
            //outgoing_status: Your relationship to the user. Can be "follows", "requested", "none". 
            //incoming_status: A user's relationship to you. Can be "followed_by", "requested_by", "blocked_by_you", "none"
        }
    }];
}

- (void)fetchRelationshipToUser
{
    
}

- (void)fetchRequestedBy
{    
    //return InstagramUserCollection
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/requested-by"];
    NSURL *url = [self authorizedURL:[NSURL URLWithString:urlString]];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
        } else {
            //id obj = [Instagram JSONFromData:responseData];
        }
    }];
}

- (void)modifyRelationshipToUser
{
    //POST /users/{user-id}/relationship
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    if (theUserDictionary) {
        [super setUserDictionary:theUserDictionary];
        
        [self ioss_setInstagramUserDictionary:theUserDictionary];
    } else {
        iOSSLog(@"meh: no user dictionary");
    }
}

- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

        if (nil == self.auth) {
            self.auth = [[Instagram sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        }
        
        [[Instagram sharedService] authorizeFromViewController:vc 
                                                       forAuth:self.auth 
                                           andKeychainItemName:self.keychainItemName 
                                               andCookieDomain:@"instagram.com" 
                                         withCompletionHandler:^(GTMOAuth2Authentication *theAuth, NSDictionary *userInfo, NSError *error) {
            self.auth = theAuth;
            if (error) {
                if (self.authenticationHandler) {
                    self.authenticationHandler(error);
                    self.authenticationHandler = nil;
                }
            } else {
                NSDictionary *user = [userInfo objectForKey:@"user"];
                self.userDictionary = user;
                
                [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
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

- (void)fetchUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/", self.userID];
    NSURL *url = [self authorizedURL:[NSURL URLWithString:urlString]];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Instagram JSONFromData:responseData];
            self.userDictionary = dictionary;
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)fetchRecentMediaWithCompletionHandler:(FetchMediaHandler)completionHandler
{
    self.fetchMediaHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent", self.userID];
    NSURL *url = [self authorizedURL:[NSURL URLWithString:urlString]];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchMediaHandler) {
                self.fetchMediaHandler(nil, error);
                self.fetchMediaHandler = nil;
            }
        } else {
            if (responseData) {
                NSDictionary *dictionary = [Instagram JSONFromData:responseData];
                
                //call completion handler with error
                if (self.fetchMediaHandler) {
                    self.fetchMediaHandler(dictionary, nil);
                    self.fetchMediaHandler = nil;
                }
                
            }
        }
    }];
}

- (NSString*)oAuthAccessToken
{
    return self.auth.accessToken;
}

- (NSString*)oAuthAccessTokenSecret
{
    return nil;
}

- (NSTimeInterval)oAuthAccessTokenExpirationDate
{
    return 0.0;
}

- (void)logout
{
    [[Instagram sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
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
    return [Instagram sharedService].name;
}

+ (void)instagram
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

+ (void)camera 
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://camera"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

+ (void)tagWithName:(NSString*)name 
{
    NSString *urlString = [NSString stringWithFormat:@"instagram://tag?name=%@", name];
    NSURL *instagramURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

+ (void)userWithName:(NSString*)name 
{
    NSString *urlString = [NSString stringWithFormat:@"instagram://user?username=%@", name];
    NSURL *instagramURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

+ (void)locationWithID:(NSString*)locationID
{
    NSString *urlString = [NSString stringWithFormat:@"instagram://location?id=%@", locationID];
    NSURL *instagramURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

+ (void)mediaWithID:(NSString*)mediaID
{
    NSString *urlString = [NSString stringWithFormat:@"instagram://media?id=%@", mediaID];
    NSURL *instagramURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

/*
 If your application creates photos and you'd like your users to share these photos using Instagram, you can use the Document Interaction API to open your photo in Instagram's sharing flow.
 
 You must first save your file in PNG or JPEG (preferred) format and use the filename extension ".ig". Using the iOS Document Interaction APIs you can trigger the photo to be opened by Instagram. The Identifier for our Document Interaction UTI is com.instagram.photo, and it conforms to the public/jpeg and public/png UTIs. See the Apple documentation articles: Previewing and Opening Files and the UIDocumentInteractionController Class Reference for more information.
 
 When triggered, Instagram will immediately present the user with our filter screen. The image is preloaded and sized appropriately for Instagram. Other than using the appropriate image format, described above, our only requirement is that the image is at least 612px tall and/or wide. For best results, Instagram prefers opening a JPEG that is 612px by 612px square. If the image is larger, it will be resized dynamically.
 
 An important note: If either dimension of the image is less than 612 pixels, Instagram will present an alert to the user saying we were unable to open the file. It's our current policy not to upscale or stretch images to our minimum dimension.
 */
+ (void)editPhotoWithURL:(NSURL*)url 
         andMenuFromView:(UIView*)view
{
    static UIDocumentInteractionController *interactionController = nil;
    if (nil == interactionController) {
        interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        //<UIDocumentInteractionControllerDelegate>
        //interactionController.delegate = self;
        interactionController.UTI = @"com.instagram.photo";
    }
    
    BOOL didOpen = [interactionController presentOpenInMenuFromRect:CGRectMake(50.0f, 50.0f, 20.0f, 20.0f) 
                                                             inView:view 
                                                           animated:YES];
    if (didOpen) {
        iOSSLog(@"presentOpenInMenuFromRect");
    }
}

#pragma
#pragma mark UIDocumentInteractionControllerDelegate
/*
 - (void) documentInteractionController: (UIDocumentInteractionController *) controller willBeginSendingToApplication: (NSString *) application
 {
 iOSSLog(@"willBeginSendingToApplication");
 }
 
 - (void) documentInteractionController: (UIDocumentInteractionController *) controller didEndSendingToApplication: (NSString *) application
 {
 iOSSLog(@"didEndSendingToApplication");
 }
 
 - (void) documentInteractionControllerWillPresentOpenInMenu: (UIDocumentInteractionController *) controller
 {
 iOSSLog(@"documentInteractionControllerWillPresentOpenInMenu");
 }
 
 - (void) documentInteractionControllerDidDismissOpenInMenu: (UIDocumentInteractionController *) controller
 {
 iOSSLog(@"documentInteractionControllerDidDismissOpenInMenu");
 }
 */

@end

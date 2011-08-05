//
//  LocalInstagramUser.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalInstagramUser.h"
#import "Instagram.h"
#import "iOSSocial.h"
#import "IGRequest.h"
#import "InstagramUser+Private.h"
#import "NSUserDefaults+iOSSAdditions.h"
#import "InstagramMediaCollection.h"

static LocalInstagramUser *localInstagramUser = nil;

@interface LocalInstagramUser () 

@property(nonatomic, copy)      InstagramAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    Instagram *instagram;
@property(nonatomic, readwrite, retain)  NSString *scope;

@end

@implementation LocalInstagramUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize instagram;
@synthesize scope;

+ (LocalInstagramUser *)localInstagramUser
{
    @synchronized(self) {
        if(localInstagramUser == nil)
            localInstagramUser = [[super allocWithZone:NULL] init];
    }
    return localInstagramUser;
}

+ (id<iOSSocialLocalUserProtocol>)localUser
{
    @synchronized(self) {
        if(localInstagramUser == nil)
            localInstagramUser = [[super allocWithZone:NULL] init];
    }
    return localInstagramUser;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        NSDictionary *localUserDictionary = [[NSUserDefaults standardUserDefaults] ioss_instagramUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params
{
    self.instagram = [[Instagram alloc] initWithDictionary:params];
    
    self.scope = [params objectForKey:@"scope"];
}

- (BOOL)isAuthenticated
{
    //assert if instagram is nil. params have not been set!
    
    if (NO == [self.instagram isSessionValid])
        return NO;
    return YES;
}

- (void)fetchFeedWithCompletionHandler:(FetchMediaHandler)completionHandler
{
    self.fetchMediaHandler = completionHandler;
    
    NSString *urlString = @"https://api.instagram.com/v1/users/self/feed";
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchMediaHandler) {
                self.fetchMediaHandler(nil, error);
                self.fetchMediaHandler = nil;
            }
        } else {
            if (responseData) {
                NSDictionary *dictionary = [Instagram JSONFromData:responseData];
                
                InstagramMediaCollection *collection = [[InstagramMediaCollection alloc] initWithDictionary:dictionary];
                collection.name = [NSString stringWithFormat:@"%@ Likes", self.alias];
                
                //call completion handler with error
                if (self.fetchMediaHandler) {
                    self.fetchMediaHandler(collection, nil);
                    self.fetchMediaHandler = nil;
                }
                
            }
        }
    }];
}

- (void)fetchLikedMediaWithCompletionHandler:(FetchMediaHandler)completionHandler
{
    self.fetchMediaHandler = completionHandler;
    
    NSString *urlString = @"https://api.instagram.com/v1/users/self/media/liked";
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchMediaHandler) {
                self.fetchMediaHandler(nil, error);
                self.fetchMediaHandler = nil;
            }
        } else {
            if (responseData) {
                NSDictionary *dictionary = [Instagram JSONFromData:responseData];
                
                InstagramMediaCollection *collection = [[InstagramMediaCollection alloc] initWithDictionary:dictionary];
                collection.name = [NSString stringWithFormat:@"%@ Likes", self.alias];
                
                //call completion handler with error
                if (self.fetchMediaHandler) {
                    self.fetchMediaHandler(collection, nil);
                    self.fetchMediaHandler = nil;
                }
                
            }
        }
    }];
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = @"https://api.instagram.com/v1/users/self/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
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
    NSURL *url = [NSURL URLWithString:urlString];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
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
    
    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/v1/users/self/requested-by"];
    
    IGRequest *request = [[IGRequest alloc] initWithURL:url  
                                             parameters:nil 
                                          requestMethod:IGRequestMethodGET];
    
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
    [super setUserDictionary:theUserDictionary];
    
    [[NSUserDefaults standardUserDefaults] ioss_setInstagramUserDictionary:theUserDictionary];
}

- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    //assert if instagram is nil. params have not been set!
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        self.authenticationHandler = completionHandler;
        
        [self.instagram authorizeWithScope:self.scope 
                                        fromViewController:vc withCompletionHandler:^(NSDictionary *userInfo, NSError *error) {
                                            if (error) {
                                                
                                            } else {
                                                NSDictionary *user = [userInfo objectForKey:@"user"];
                                                self.userDictionary = user;
                                            }
                                            
                                            if (self.authenticationHandler) {
                                                self.authenticationHandler(error);
                                                self.authenticationHandler = nil;
                                            }
                                        }];
    } else {
        [self fetchLocalUserDataWithCompletionHandler:nil];
    }
}

- (NSString*)oAuthAccessToken
{
    return [self.instagram oAuthAccessToken];
}

- (void)logout
{
    //assert if instagram is nil. params have not been set!
    
    [self.instagram logout];
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

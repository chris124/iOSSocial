//
//  Instagram.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Instagram.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"
#import "iOSSocial.h"

@interface Instagram ()

@property(nonatomic, readwrite, retain) NSString *clientID;
@property(nonatomic, readwrite, retain) NSString *clientSecret;
@property(nonatomic, readwrite, retain) NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *redirectURI;
@property(nonatomic, readwrite, retain) GTMOAuth2Authentication *auth;

- (void)checkAuthentication;
- (GTMOAuth2Authentication *)authForCustomService;

@end

@implementation Instagram

@synthesize clientID;
@synthesize clientSecret;
@synthesize keychainItemName;
@synthesize redirectURI;
@synthesize auth;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithClientID:(NSString*)ID 
          clientSecret:(NSString*)cs 
           redirectURI:(NSString*)uri
   andKeyChainItemName:(NSString*)kcin
{
    iOSSLog(@"initWithClientID");
    self = [self init];
    if (self) {
        // Initialization code here.
        self.clientID = ID;
        self.clientSecret = cs;
        self.redirectURI = uri;
        self.keychainItemName = kcin;
        [self checkAuthentication];
    }
    
    return self;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)newAuth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        iOSSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
            iOSSLog(@"%@", str);
        }
        
        self.auth = nil;
        
        //[self dismissModalViewControllerAnimated:YES];
        
        //notify error
    } else {
        // Authentication succeeded
        
        //get the local user and initialize it with the dictionary? or let it init itself?
        
        //cwnote: need to save these goodes. NSUserDefaults?
        /*
        NSDictionary *dictionary = auth.parameters;
        NSDictionary *user = [dictionary objectForKey:@"user"];
        if (user) {
            NSString *bio = [user objectForKey:@"bio"];
            NSString *fullName = [user objectForKey:@"full_name"];
            //id id = 4885060;
            NSString *profilePictureURLString = [user objectForKey:@"profile_picture"];
            NSURL *imageURL = [NSURL URLWithString:profilePictureURLString];
            UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]];
            //self.imageView.image = image;
            NSString *username = [user objectForKey:@"username"];
            NSString *website = [user objectForKey:@"website"];
        }
        */
        self.auth = newAuth;
        //[self dismissModalViewControllerAnimated:YES];
        
        //notify success
    }
}


- (void)authorize:(NSArray *)permissions fromViewController:(UIViewController*)vc
{
    
    self.auth = [self authForCustomService];
    
    //cwnote: set scope from array of permissions
    // Specify the appropriate scope string, if any, according to the service's API documentation
    NSString *newScope = @"";
    for (NSString *permission in permissions) {
        newScope = [newScope stringByAppendingString:permission];
        //dont' add one on at the end. ugh.
        newScope = [newScope stringByAppendingString:@" "];
    }
    self.auth.scope = @"basic comments relationships likes";
    //self.auth.scope = newScope;
    
    NSURL *authURL = [NSURL URLWithString:@"https://api.instagram.com/oauth/authorize"];
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                 authorizationURL:authURL
                                                                 keychainItemName:self.keychainItemName
                                                                         delegate:self
                                                                 finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"touch" forKey:@"display"];
    viewController.signIn.additionalAuthorizationParameters = params;
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    viewController.initialHTMLString = html;
    
    [vc presentModalViewController:viewController animated:YES];
}

- (BOOL)isSessionValid
{
    BOOL isSignedIn = self.auth.canAuthorize;;
    return isSignedIn;
}

- (GTMOAuth2Authentication *)authForCustomService {
    
    NSURL *tokenURL = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"];
    
    GTMOAuth2Authentication *newAuth;
    newAuth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Instagram Service"
                                                                tokenURL:tokenURL
                                                             redirectURI:self.redirectURI
                                                                clientID:self.clientID
                                                            clientSecret:self.clientSecret];
    return newAuth;
}

- (void)checkAuthentication {
    // Listen for network change notifications
    /*
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
     [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuth2FetchStarted object:nil];
     [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuth2FetchStopped object:nil];
     [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkLost  object:nil];
     [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkFound object:nil];
     */
    
    GTMOAuth2Authentication *newAuth = [self authForCustomService];
    if (newAuth) {
        [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:self.keychainItemName 
                                                    authentication:newAuth];
    }

    self.auth = newAuth;
}

- (void)logout
{
    if ([self.auth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.keychainItemName];
    
    // Discard our retained authentication object.
    self.auth = nil;
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
+ (void)editPhotoWithURL:(NSURL*)url andMenuFromView:(UIView*)view
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

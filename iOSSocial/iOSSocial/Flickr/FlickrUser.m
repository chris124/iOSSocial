//
//  FlickrUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "FlickrUser.h"
#import "FlickrUser+Private.h"
#import "iOSSRequest.h"

@interface FlickrUser ()

@property(nonatomic, copy)      LoadPhotoHandler loadPhotoHandler;

@end

@implementation FlickrUser

@synthesize userDictionary;
@synthesize userID;
@synthesize alias;
@synthesize fetchUserDataHandler;
@synthesize index;
@synthesize dataSource;
@synthesize loadPhotoHandler;
@synthesize profilePictureURL;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)theUserDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.userDictionary = theUserDictionary;
    }
    
    return self;
}
/*
{
    person =     {
        iconfarm = 4;
        iconserver = 3177;
        id = "63861496@N06";
        ispro = 0;
        location =         {
            "_content" = "";
        };
        "mbox_sha1sum" =         {
            "_content" = b0c8100522a747b3687987433f273259ded03771;
        };
        mobileurl =         {
            "_content" = "http://m.flickr.com/photostream.gne?id=63816174";
        };
        nsid = "63861496@N06";
        "path_alias" = mrchristopher124;
        photos =         {
            count =             {
                "_content" = 2;
            };
            firstdate =             {
                "_content" = 1308681322;
            };
            firstdatetaken =             {
                "_content" = "2011-06-21 14:35:22";
            };
            views =             {
                "_content" = 0;
            };
        };
        photosurl =         {
            "_content" = "http://www.flickr.com/photos/mrchristopher124/";
        };
        profileurl =         {
            "_content" = "http://www.flickr.com/people/mrchristopher124/";
        };
        realname =         {
            "_content" = "";
        };
        username =         {
            "_content" = mrchristopher124;
        };
    };
    stat = ok;
}
*/
- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    userDictionary = theUserDictionary;
    
    self.userID = [theUserDictionary objectForKey:@"id"];
    self.profilePictureURL = [theUserDictionary objectForKey:@"profile_image_url_https"];
    NSString *username = [theUserDictionary objectForKey:@"username"];
    if (username) {
        self.alias = username;
    } else {
        self.alias = [theUserDictionary objectForKey:@"screen_name"];
    }
}

- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler
{
    self.loadPhotoHandler = completionHandler;

    NSString *urlString = self.profilePictureURL;
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.loadPhotoHandler) {
                self.loadPhotoHandler(nil, error);
                self.loadPhotoHandler = nil;
            }
        } else {
            UIImage *image = [UIImage imageWithData:responseData];
            
            if (self.loadPhotoHandler) {
                self.loadPhotoHandler(image, nil);
                self.loadPhotoHandler = nil;
            }
        }
    }];
}

@end

//
//  FacebookPhoto.m
//  MadRaces
//
//  Created by Christopher White on 7/8/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import "FacebookPhoto.h"

@interface FacebookPhoto ()

//@property(nonatomic, retain)    NSString *picture;
@property(nonatomic, retain)    NSArray *images;

@end

@implementation FacebookPhoto

@synthesize photoSource;
@synthesize size;
@synthesize index;
@synthesize caption;
//@synthesize picture;
@synthesize images;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)photoDictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        //self.photoID = [albumDictionary objectForKey:@"id"];
        self.caption = [photoDictionary objectForKey:@"name"];
        //self.picture = [photoDictionary objectForKey:@"picture"];
        self.images = [photoDictionary objectForKey:@"images"];
    }
    
    return self;
}

- (void)dealloc
{
    [images release];
    //[picture release];
    [caption release];
    [super dealloc];
}

- (NSString*)URLForVersion:(TTPhotoVersion)version
{
    //cwnote: do a better implentation of this. use photo sizes. don't rely on indexes into and size of array of images.
    
    NSString *url = nil;
    switch (version) {
        case TTPhotoVersionNone:
            break;
            
        case TTPhotoVersionLarge:
        {
            NSDictionary *imageDictionary = [self.images objectAtIndex:0];
            url = [imageDictionary objectForKey:@"source"];
        }
            break;
        
        case TTPhotoVersionMedium:
            break;
            
        case TTPhotoVersionSmall:
            break;
            
        case TTPhotoVersionThumbnail:
        {
            NSDictionary *imageDictionary = [self.images objectAtIndex:3];
            url = [imageDictionary objectForKey:@"source"];
        }
            break;
            
        default:
            break;
    }
    NSLog(@"%@", url);
    return url;
}

@end

/*
{
    data =     (
                {
                    "created_time" = "2011-03-16T03:52:13+0000";
                    from =             {
                        id = 623441509;
                        name = "Christopher White";
                    };
                    height = 538;
                    icon = "https://s-static.ak.facebook.com/rsrc.php/v1/yz/r/StEh3RhPvjk.gif";
                    id = 10150106153301510;
                    images =             (
                                          {
                                              height = 538;
                                              source = "https://fbcdn-sphotos-a.akamaihd.net/hphotos-ak-snc6/197085_10150106153301510_623441509_6924034_3639106_n.jpg";
                                              width = 720;
                                          },
                                          {
                                              height = 134;
                                              source = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/197085_10150106153301510_623441509_6924034_3639106_a.jpg";
                                              width = 180;
                                          },
                                          {
                                              height = 97;
                                              source = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/197085_10150106153301510_623441509_6924034_3639106_s.jpg";
                                              width = 130;
                                          },
                                          {
                                              height = 56;
                                              source = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/197085_10150106153301510_623441509_6924034_3639106_t.jpg";
                                              width = 75;
                                          }
                                          );
                    link = "http://www.facebook.com/photo.php?pid=6924034&id=623441509";
                    name = "Gavin and Adam gettin' their dance on!";
                    picture = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/197085_10150106153301510_623441509_6924034_3639106_s.jpg";
                    position = 1;
                    source = "https://fbcdn-sphotos-a.akamaihd.net/hphotos-ak-snc6/197085_10150106153301510_623441509_6924034_3639106_n.jpg";
                    tags =             {
                        data =                 (
                                                {
                                                    "created_time" = "2011-03-16T03:52:44+0000";
                                                    id = 773614539;
                                                    name = "Gavin Bernard";
                                                    x = "30.9028";
                                                    y = "47.6766";
                                                },
                                                {
                                                    "created_time" = "2011-03-16T03:53:36+0000";
                                                    id = 582941553;
                                                    name = "Adam Darby";
                                                    x = "36.6667";
                                                    y = "42.9104";
                                                }
                                                );
                    };
                    "updated_time" = "2011-03-21T03:23:44+0000";
                    width = 720;
                },
 */

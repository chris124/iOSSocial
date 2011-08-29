//
//  InstagramMedia.m
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstagramMedia.h"
#import "iOSSLog.h"

@interface InstagramMedia ()

@property(nonatomic, retain)    NSDictionary *images;

@end

@implementation InstagramMedia

@synthesize photoSource;
@synthesize size;
@synthesize index;
@synthesize caption;
@synthesize images;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)mediaDictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        if (mediaDictionary) {
            //the caption can be <null>
            NSDictionary *captionDictionary = [mediaDictionary objectForKey:@"caption"];
            if (captionDictionary && ![captionDictionary isKindOfClass:[NSNull class]]) {
                self.caption = [captionDictionary objectForKey:@"text"];
            }
            self.images = [mediaDictionary objectForKey:@"images"];
        }
    }
    
    return self;
}

- (NSString*)URLForVersion:(TTPhotoVersion)version
{
    NSString *url = nil;
    switch (version) {
        case TTPhotoVersionNone:
            break;
            
        case TTPhotoVersionLarge:
        {
            NSDictionary *imageDictionary = [self.images objectForKey:@"standard_resolution"];
            url = [imageDictionary objectForKey:@"url"];
        }
            break;
            
        case TTPhotoVersionMedium:
            break;
            
        case TTPhotoVersionSmall:
            break;
            
        case TTPhotoVersionThumbnail:
        {
            NSDictionary *imageDictionary = [self.images objectForKey:@"thumbnail"];
            url = [imageDictionary objectForKey:@"url"];
        }
            break;
            
        default:
            break;
    }
    iOSSLog(@"%@", url);
    return url;
}

/*
{
    caption =     {
        "created_time" = 1310646288;
        from =         {
            "full_name" = "";
            id = 4885060;
            "profile_picture" = "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg";
            username = mrchristopher124;
        };
        id = 157801416;
        text = "Sunflowers in BK";
    };
    comments =     {
        count = 1;
        data =         (
                        {
                            "created_time" = 1310646309;
                            from =                 {
                                "full_name" = "";
                                id = 4885060;
                                "profile_picture" = "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg";
                                username = mrchristopher124;
                            };
                            id = 157801719;
                            text = "#flowers #brooklyn";
                        }
                        );
    };
    "created_time" = 1310646263;
    filter = "Lomo-fi";
    id = 128029620;
    images =     {
        "low_resolution" =         {
            height = 306;
            url = "http://distillery.s3.amazonaws.com/media/2011/07/14/5752bfdd4c774de9b5b382bce93573c1_6.jpg";
            width = 306;
        };
        "standard_resolution" =         {
            height = 612;
            url = "http://distillery.s3.amazonaws.com/media/2011/07/14/5752bfdd4c774de9b5b382bce93573c1_7.jpg";
            width = 612;
        };
        thumbnail =         {
            height = 150;
            url = "http://distillery.s3.amazonaws.com/media/2011/07/14/5752bfdd4c774de9b5b382bce93573c1_5.jpg";
            width = 150;
        };
    };
    likes =     {
        count = 6;
        data =         (
                        {
                            "full_name" = "Melike Alsenaid";
                            id = 823127;
                            "profile_picture" = "http://images.instagram.com/profiles/profile_823127_75sq_1307358757.jpg";
                            username = melikealsenaid;
                        },
                        {
                            "full_name" = "Ciara \Ue314";
                            id = 1114522;
                            "profile_picture" = "http://images.instagram.com/profiles/profile_1114522_75sq_1309337567.jpg";
                            username = ceeairuhh;
                        },
                        {
                            "full_name" = "Samantha Farr";
                            id = 1826565;
                            "profile_picture" = "http://images.instagram.com/profiles/profile_1826565_75sq_1308637508.jpg";
                            username = samanthafarr;
                        },
                        {
                            "full_name" = "Murat (istanbul-riyad)";
                            id = 2650098;
                            "profile_picture" = "http://images.instagram.com/profiles/profile_2650098_75sq_1306747692.jpg";
                            username = doganm;
                        },
                        {
                            "full_name" = "Ray Rachelkok";
                            id = 2970007;
                            "profile_picture" = "http://images.instagram.com/profiles/profile_2970007_75sq_1310747535.jpg";
                            username = "rachelkok_ray_gf";
                        },
                        {
                            "full_name" = Jessica;
                            id = 5043151;
                            "profile_picture" = "http://images.instagram.com/profiles/profile_5043151_75sq_1310995595.jpg";
                            username = jessisue17;
                        }
                        );
    };
    link = "http://instagr.am/p/HoZO0/";
    location = "<null>";
    tags =     (
                brooklyn,
                flowers
                );
    type = image;
    user =     {
        bio = "";
        "full_name" = "";
        id = 4885060;
        "profile_picture" = "http://images.instagram.com/profiles/profile_4885060_75sq_1308681839.jpg";
        username = mrchristopher124;
        website = "";
    };
    "user_has_liked" = 0;
}
*/

@end

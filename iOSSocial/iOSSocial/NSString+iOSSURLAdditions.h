//
//  NSString+iOSSURLAdditions.h
//  iOSSocial
//
//  Created by Christopher White on 7/20/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (iOSSURLAdditions)

- (NSString *)ioss_URLEncodedFormStringUsingEncoding:(NSStringEncoding)enc;
- (NSString *)ioss_percentEscapedStringWithEncoding:(NSStringEncoding)enc 
                               additionalCharacters:(NSString *)add
                                  ignoredCharacters:(NSString *)ignore;

@end

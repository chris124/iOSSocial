//
//  UIView+iOSSSubviewTraversal.h
//  iOSSocial
//
//  Created by Christopher White on 7/15/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
 ***/
//
//  UIView+PRPSubviewTraversal.h
//  PrintSubviews
//
//  Created by Matt Drance on 1/25/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (iOSSSubviewTraversal)

- (void)ioss_printSubviews;
- (void)ioss_printSubviewsWithIndentString:(NSString *)indentString;

- (NSArray *)ioss_subviewsMatchingClass:(Class)aClass;
- (NSArray *)ioss_subviewsMatchingOrInheritingClass:(Class)aClass;
- (void)ioss_populateSubviewsOfClass:(Class)aClass 
                             inArray:(NSMutableArray *)array 
                          exactMatch:(BOOL)exactMatch;
@end

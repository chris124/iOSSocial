//
//  UIView+iOSSSubviewTraversal.m
//  iOSSocial
//
//  Created by Christopher White on 7/15/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "UIView+iOSSSubviewTraversal.h"

@implementation UIView (iOSSSubviewTraversal)

- (void)ioss_printSubviews
{
    [self ioss_printSubviewsWithIndentString:nil];
}

- (void)ioss_printSubviewsWithIndentString:(NSString *)indentString
{
    if (indentString == nil) 
        indentString = @"";
    
    NSString *viewDescription = NSStringFromClass([self class]);
    printf("%s+-%s\n", [indentString UTF8String], [viewDescription UTF8String]);
    
    if (self.subviews) { 
        NSArray *siblings = self.superview.subviews; 
        if ([siblings count] > 1 && ([siblings indexOfObject:self] < [siblings count]-1)) {
            indentString = [indentString stringByAppendingString:@"| "]; 
        } else {
            indentString = [indentString stringByAppendingString:@" "];
        }
    }
}

- (NSArray *)ioss_subviewsMatchingClass:(Class)aClass
{
    NSMutableArray *array = [NSMutableArray array]; 
    [self ioss_populateSubviewsOfClass:aClass 
                               inArray:array 
                            exactMatch:YES];
    return array;
}

- (NSArray *)ioss_subviewsMatchingOrInheritingClass:(Class)aClass
{
    NSMutableArray *array = [NSMutableArray array]; 
    [self ioss_populateSubviewsOfClass:aClass 
                               inArray:array 
                            exactMatch:NO];
    return array;
}

- (void)ioss_populateSubviewsOfClass:(Class)aClass 
                             inArray:(NSMutableArray *)array 
                          exactMatch:(BOOL)exactMatch
{
    if (exactMatch) { 
        if ([self isMemberOfClass:aClass]) {
            [array addObject:self];
        } 
    } else {
        if ([self isKindOfClass:aClass]) { 
            [array addObject:self];
        }
    } 
    
    for (UIView *subview in self.subviews) {
        [subview ioss_populateSubviewsOfClass:aClass 
                                      inArray:array
                                   exactMatch:exactMatch];
    }
}

@end

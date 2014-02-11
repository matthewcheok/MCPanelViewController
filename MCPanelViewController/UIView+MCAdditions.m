//
//  UIView+MCAdditions.m
//  MCPanelViewController
//
//  Created by Matthew Cheok on 5/12/13.
//  Copyright (c) 2013 Matthew Cheok. All rights reserved.
//

#import "UIView+MCAdditions.h"

@implementation UIView (MCAdditions)

- (NSArray *)subviewsOfKindOfClass:(Class)class
{
    NSMutableArray *subviews = [@[] mutableCopy];
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:class]) {
            [subviews addObject:view];
        }
        
        // Traverse further down in subviews
        NSArray *subviewsOfView = [view subviewsOfKindOfClass:class];
        [subviews addObjectsFromArray:subviewsOfView];
    }
    
    return subviews;
}

@end

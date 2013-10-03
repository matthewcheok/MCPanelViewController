//
//  MCPanGestureRecognizer.m
//  GSX
//
//  Created by Matthew Cheok on 2/10/13.
//  Copyright (c) 2013 Matthew Cheok. All rights reserved.
//

#import "MCPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

const static CGFloat MCPanGestureRecognizerThreshold = 4;

@implementation MCPanGestureRecognizer {
    CGFloat _translationX;
    CGFloat _translationY;
    BOOL _isDragging;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _translationX += prevPoint.x - nowPoint.x;
    _translationY += prevPoint.y - nowPoint.y;
    if (!_isDragging) {
        if (_direction == MCPanGestureRecognizerDirectionHorizontal &&
            abs(_translationY) > MCPanGestureRecognizerThreshold) {
            self.state = UIGestureRecognizerStateFailed;
        }
        if (_direction == MCPanGestureRecognizerDirectionVertical &&
                 abs(_translationX) > MCPanGestureRecognizerThreshold) {
            self.state = UIGestureRecognizerStateFailed;
        }
        _isDragging = YES;
    }
}

- (void)reset {
    [super reset];
    _isDragging = NO;
    _translationX = 0;
    _translationY = 0;
}

@end

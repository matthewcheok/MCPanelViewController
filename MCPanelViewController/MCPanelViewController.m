//
//  MCPanelViewController.m
//  GSX
//
//  Created by Matthew Cheok on 2/10/13.
//  Copyright (c) 2013 Matthew Cheok. All rights reserved.
//

#import "MCPanelViewController.h"
#import "MCPanGestureRecognizer.h"

#import "UIImage+ImageEffects.h"

#import <objc/runtime.h>

// constants
const static CGFloat MCPanelViewAnimationDuration = 0.3;
const static CGFloat MCPanelViewGestureThreshold = 0.6;

// associative references on UIScreenEdgePanGestureRecognizer to remember some information we need later
const static NSString *MCPanelViewGesturePresentingViewControllerKey = @"MCPanelViewGesturePresentingViewControllerKey";
const static NSString *MCPanelViewGesturePresentedViewControllerKey = @"MCPanelViewGesturePresentedViewControllerKey";
const static NSString *MCPanelViewGestureAnimationDirectionKey = @"MCPanelViewGestureAnimationDirectionKey";

@interface UIViewController (MCPanelViewControllerInternal)

- (void)addToParentViewController:(UIViewController *)parentViewController inView:(UIView *)view callingAppearanceMethods:(BOOL)callAppearanceMethods;
- (void)removeFromParentViewControllerCallingAppearanceMethods:(BOOL)callAppearanceMethods;

@end

@implementation UIViewController (MCPanelViewControllerInternal)

- (void)addToParentViewController:(UIViewController *)parentViewController inView:(UIView *)view callingAppearanceMethods:(BOOL)callAppearanceMethods
{
    if (self.parentViewController != nil) {
        [self removeFromParentViewControllerCallingAppearanceMethods:callAppearanceMethods];
    }
    
    if (callAppearanceMethods)
        [self beginAppearanceTransition:YES animated:NO];
    [parentViewController addChildViewController:self];
    [view addSubview:self.view];
    [self didMoveToParentViewController:self];
    if (callAppearanceMethods)
        [self endAppearanceTransition];
}

- (void)removeFromParentViewControllerCallingAppearanceMethods:(BOOL)callAppearanceMethods
{
    if (callAppearanceMethods)
        [self beginAppearanceTransition:NO animated:NO];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (callAppearanceMethods)
        [self endAppearanceTransition];
}

@end


@interface MCPanelViewController () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) MCPanelAnimationDirection direction;
@property (assign, nonatomic) CGFloat maxWidth;
@property (assign, nonatomic) CGFloat maxHeight;

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *backgroundButton;
@property (strong, nonatomic) MCPanGestureRecognizer *panGestureRecognizer;

// presentedViewController
@property (strong, nonatomic, readwrite) UIViewController *rootViewController;

@end


@implementation MCPanelViewController

- (id)initWithRootViewController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        self.tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        self.rootViewController = controller;
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *) controller;
            navController.topViewController.view.backgroundColor = [UIColor clearColor];
        }
        else {
            controller.view.backgroundColor = [UIColor clearColor];
        }

        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIViewAutoresizing fullScreenMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizingMask = fullScreenMask;
    
    self.backgroundButton = [[UIButton alloc] init];
    self.backgroundButton.autoresizingMask = fullScreenMask;
    [self.backgroundButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.masking = YES;    

    [self.view addSubview:self.backgroundButton];

    self.shadowView = [[UIView alloc] init];
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOpacity = 0.3;
    self.shadowView.layer.shadowRadius = 5;
    self.shadowView.layer.shadowOffset = CGSizeZero;

    self.imageView = [[UIImageView alloc] init];
    self.imageView.clipsToBounds = YES;
    
    [self.view addSubview:self.shadowView];
    [self.view addSubview:self.imageView];
  
    [self setPanningEnabled:YES];
}

- (void)setMasking:(BOOL)masking {
    if (_masking == masking) {
        return;
    }
    _masking = masking;
    
    if (masking) {
        self.backgroundButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    else {
        self.backgroundButton.backgroundColor = [UIColor clearColor];
    }
}

- (void)setPanningEnabled:(BOOL)panningEnabled {
    if (panningEnabled == _panningEnabled) {
        return;
    }
    
    _panningEnabled = panningEnabled;
    
    if( panningEnabled && !self.panGestureRecognizer ) {
        self.panGestureRecognizer = [[MCPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGestureRecognizer.direction = MCPanGestureRecognizerDirectionHorizontal;
        [self.rootViewController.view addGestureRecognizer:self.panGestureRecognizer];
    } else if( !panningEnabled && self.panGestureRecognizer ) {
        [self.rootViewController.view removeGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
}

- (void)layoutSubviewsToWidth:(CGFloat)width {
    CGRect bounds = self.parentViewController.view.bounds;
    if (width > self.maxWidth) {
        CGFloat offset = 0;
        CGFloat shadowOffset = width - self.maxWidth;

        if (self.direction == MCPanelAnimationDirectionLeft) {
        }
        else {
            offset = CGRectGetWidth(bounds)-width;
            shadowOffset = offset;
        }

        self.backgroundButton.alpha = 1;
        self.imageView.frame = CGRectMake(offset, 0, width, self.maxHeight);
        self.shadowView.frame = CGRectMake(shadowOffset, 0, width, self.maxHeight);
        self.rootViewController.view.frame = CGRectMake(offset, 0, width, self.maxHeight);
    }
    else {
        CGFloat offset = 0;
        CGRect frame = CGRectZero;
        if (self.direction == MCPanelAnimationDirectionLeft) {
            frame = CGRectMake(width-self.maxWidth, 0, self.maxWidth, self.maxHeight);
        }
        else {
            offset = CGRectGetWidth(bounds)-width;
            frame = CGRectMake(CGRectGetWidth(bounds)-width, 0, self.maxWidth, self.maxHeight);
        }

        self.backgroundButton.alpha = width / self.maxWidth;
        self.imageView.frame = CGRectMake(offset, 0, width, self.maxHeight);
        self.shadowView.frame = frame;
        self.rootViewController.view.frame = frame;
    }
}

- (void)setupController:(UIViewController *)controller withDirection:(MCPanelAnimationDirection)direction {
    self.direction = direction;

    CGRect bounds = controller.view.bounds;
    self.maxHeight = CGRectGetHeight(bounds);
    self.maxWidth = self.rootViewController.preferredContentSize.width;
    if (self.maxWidth == 0) {
        self.maxWidth = 320;
    }

    [self.rootViewController addToParentViewController:self inView:self.view callingAppearanceMethods:YES];

    self.view.frame = bounds;
    self.backgroundButton.frame = bounds;
    
    // support rotation
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight;
    switch (direction) {
        case MCPanelAnimationDirectionLeft:
            mask |= UIViewAutoresizingFlexibleRightMargin;
            break;
        
        case MCPanelAnimationDirectionRight:
            mask |= UIViewAutoresizingFlexibleLeftMargin;
            break;
            
        default:
            break;
    }
    
    self.rootViewController.view.autoresizingMask = mask;
    self.imageView.autoresizingMask = mask;
    self.shadowView.autoresizingMask = mask;
    [self addToParentViewController:controller inView:controller.view callingAppearanceMethods:YES];

    [self refreshBackgroundAnimated:NO];
    self.imageView.contentMode = direction;
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.maxWidth, self.maxHeight)].CGPath;
}

- (void)presentInViewController:(UIViewController *)controller withDirection:(MCPanelAnimationDirection)direction {
    [self setupController:controller withDirection:direction];
    [self layoutSubviewsToWidth:0];

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:MCPanelViewAnimationDuration delay:0 options:0 animations:^{
        typeof(self) strongSelf = weakSelf;
        [strongSelf layoutSubviewsToWidth:strongSelf.maxWidth];
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss {
    CGRect bounds = self.parentViewController.view.bounds;

    CGFloat currentWidth = CGRectGetMinX(self.rootViewController.view.frame);
    if (self.direction == MCPanelAnimationDirectionLeft) {
        currentWidth += self.maxWidth;
    }
    else {
        currentWidth = CGRectGetWidth(bounds) - currentWidth;
    }
    CGFloat ratio = currentWidth / self.maxWidth;

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:MCPanelViewAnimationDuration*ratio delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        typeof(self) strongSelf = weakSelf;
        [strongSelf layoutSubviewsToWidth:0];
    } completion:^(BOOL finished) {
        typeof(self) strongSelf = weakSelf;
        [self.rootViewController removeFromParentViewControllerCallingAppearanceMethods:YES];
        [strongSelf removeFromParentViewControllerCallingAppearanceMethods:YES];
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGRect bounds = self.parentViewController.view.bounds;
    self.maxHeight = CGRectGetHeight(bounds);
    
    [self refreshBackgroundAnimated:YES];
}

- (void)refreshBackgroundAnimated:(BOOL)animated {
    UIView *view = self.parentViewController.view;
    
    BOOL wasViewAttached = (self.view.superview != nil);
    if (wasViewAttached) {
        [self.view removeFromSuperview];
    }
    
    // extend background image height to the longer of the dimensions
    // so that when rotating the background is seamless
    CGFloat width = CGRectGetWidth(view.bounds);
    CGFloat height = CGRectGetHeight(view.bounds);
    CGFloat dimension = MAX(width, height);
    CGRect rect = CGRectMake(0, 0, width, dimension);

    // get snapshot image
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    // try to extend image by reflecting
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, 2*height);
    CGContextScaleCTM(ctx, 1, -1);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    switch (self.backgroundStyle) {
        case MCPanelBackgroundStyleExtraLight:
            image = [image applyExtraLightEffect];
            break;

        case MCPanelBackgroundStyleDark:
            image = [image applyDarkEffect];
            break;

        case MCPanelBackgroundStyleTinted:
            image = [image applyTintEffectWithColor:self.tintColor];
            break;

        default:
            image = [image applyLightEffect];
            break;
    }
    
    if (wasViewAttached) {
        [view addSubview:self.view];
    }

    if (animated) {
        __weak typeof(self) weakSelf = self;
        [UIView transitionWithView:self.imageView
                          duration:MCPanelViewAnimationDuration
                           options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            typeof(self) strongSelf = weakSelf;
                            strongSelf.imageView.image = image;
                        } completion:nil];
    }
    else {
        self.imageView.image = image;
    }
}

#pragma mark - Gestures

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    // initialization for screen edge pan gesture
    if ([pan isKindOfClass:[UIScreenEdgePanGestureRecognizer class]] &&
        pan.state == UIGestureRecognizerStateBegan) {
        __weak UIViewController *controller = objc_getAssociatedObject(pan, &MCPanelViewGesturePresentingViewControllerKey);
        
        if (!controller) {
            return;
        }

        MCPanelAnimationDirection direction = [objc_getAssociatedObject(pan, &MCPanelViewGestureAnimationDirectionKey) integerValue];
        [self setupController:controller withDirection:direction];

        CGPoint translation = [pan translationInView:pan.view];
        CGFloat width = direction == MCPanelAnimationDirectionLeft ? translation.x : -1 * translation.x;

        [self layoutSubviewsToWidth:0];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:MCPanelViewAnimationDuration delay:0 options:0 animations:^{
            typeof(self) strongSelf = weakSelf;
            [strongSelf layoutSubviewsToWidth:width];
        } completion:^(BOOL finished) {
        }];

        CGFloat offset = self.maxWidth - width;
        if (direction == MCPanelAnimationDirectionLeft) {
            offset *= -1;
        }
        [pan setTranslation:CGPointMake(offset, translation.y) inView:pan.view];
    }

    if (!self.parentViewController) {
        return;
    }

    CGFloat newWidth = [pan translationInView:pan.view].x;
    if (self.direction == MCPanelAnimationDirectionRight) {
        newWidth *= -1;
    }
    newWidth += self.maxWidth;
    CGFloat ratio = newWidth / self.maxWidth;

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            [self layoutSubviewsToWidth:newWidth];
            break;
        }

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGFloat threshold = MCPanelViewGestureThreshold;

            // invert threshold if we started a screen edge pan gesture
            if ([pan isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                threshold = 1 - threshold;
            }

            if (ratio < threshold) {
                [self dismiss];
            }
            else {
                __weak typeof(self) weakSelf = self;
                [UIView animateWithDuration:MCPanelViewAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    typeof(self) strongSelf = weakSelf;
                    [strongSelf layoutSubviewsToWidth:strongSelf.maxWidth];
                } completion:^(BOOL finished) {
                }];
            }
            break;
        }
            
        default:
            break;
    }
}

- (UIScreenEdgePanGestureRecognizer *)gestureRecognizerForScreenEdgeGestureInViewController:(UIViewController *)controller withDirection:(MCPanelAnimationDirection)direction {
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges = direction == MCPanelAnimationDirectionLeft ? UIRectEdgeLeft : UIRectEdgeRight;

    objc_setAssociatedObject(pan, &MCPanelViewGesturePresentingViewControllerKey,
                             controller, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(pan, &MCPanelViewGesturePresentedViewControllerKey,
                             self, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(pan, &MCPanelViewGestureAnimationDirectionKey,
                             @(direction), OBJC_ASSOCIATION_RETAIN);

    return pan;
}

- (void)removeGestureRecognizersForScreenEdgeGestureFromView:(UIView *)view {
    for (UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
            __weak UIViewController *controller = objc_getAssociatedObject(recognizer, &MCPanelViewGesturePresentedViewControllerKey);
            if (controller == self) {
                [view removeGestureRecognizer:recognizer];
            }
        }
    }
}

@end

@implementation UIViewController (MCPanelViewController)

- (MCPanelViewController *)viewControllerInPanelViewController {
    return [[MCPanelViewController alloc] initWithRootViewController:self];
}

- (void)presentPanelViewController:(MCPanelViewController *)controller withDirection:(MCPanelAnimationDirection)direction {
    [controller presentInViewController:self withDirection:direction];
}

- (void)addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:(MCPanelViewController *)controller withDirection:(MCPanelAnimationDirection)direction {
    [self.view addGestureRecognizer:[controller gestureRecognizerForScreenEdgeGestureInViewController:self withDirection:direction]];
}

- (void)removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController:(MCPanelViewController *)controller {
    [controller removeGestureRecognizersForScreenEdgeGestureFromView:self.view];
}

@end

//
//  MCPanelViewController.h
//  MCPanelViewController
//
//  Created by Matthew Cheok on 2/10/13.
//  Copyright (c) 2013 Matthew Cheok. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MCPanelAnimationDirection) {
    MCPanelAnimationDirectionLeft = UIViewContentModeTopLeft,
    MCPanelAnimationDirectionRight = UIViewContentModeTopRight
};

typedef NS_ENUM(NSInteger, MCPanelBackgroundStyle) {
    MCPanelBackgroundStyleLight = 0,
    MCPanelBackgroundStyleExtraLight,
    MCPanelBackgroundStyleDark,
    MCPanelBackgroundStyleTinted
};

@class MCPanelViewController;
@protocol MCPanelViewControllerDelegate <NSObject>
@optional
- (void)willPresentPanelViewController:(MCPanelViewController *)controller;
- (void)didPresentPanelViewController:(MCPanelViewController *)controller;
- (void)willDismissPanelViewController:(MCPanelViewController *)controller;
- (void)didDismissPanelViewController:(MCPanelViewController *)controller;
@end

@interface MCPanelViewController : UIViewController

@property (strong, nonatomic, readonly) UIViewController *rootViewController;
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIColor *maskColor;
@property (strong, nonatomic) UIColor *shadowColor;
@property (assign, nonatomic) CGFloat shadowOpacity;
@property (assign, nonatomic) CGFloat shadowRadius;
@property (assign, nonatomic) MCPanelBackgroundStyle backgroundStyle;
@property (assign, nonatomic, getter = isMasking) BOOL masking;
@property (assign, nonatomic, getter = isPanningEnabled) BOOL panningEnabled;
@property (weak, nonatomic) id<MCPanelViewControllerDelegate> delegate;

- (id)initWithRootViewController:(UIViewController *)controller;
- (void)presentInViewController:(UIViewController *)controller withDirection:(MCPanelAnimationDirection)direction;
- (void)dismiss;

- (UIScreenEdgePanGestureRecognizer *)gestureRecognizerForScreenEdgeGestureInViewController:(UIViewController *)controller withDirection:(MCPanelAnimationDirection)direction;
- (void)removeGestureRecognizersForScreenEdgeGestureFromView:(UIView *)view;

@end

@interface UIViewController (MCPanelViewController)

@property (nonatomic, strong, readonly) MCPanelViewController *panelViewController;

- (MCPanelViewController *)viewControllerInPanelViewController;
- (void)presentPanelViewController:(MCPanelViewController *)controller withDirection:(MCPanelAnimationDirection)direction;
- (void)addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:(MCPanelViewController *)controller withDirection:(MCPanelAnimationDirection)direction;
- (void)removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController:(MCPanelViewController *)controller;

@end

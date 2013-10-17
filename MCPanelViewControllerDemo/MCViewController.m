//
//  MCViewController.m
//  MCPanelViewController
//
//  Created by Matthew Cheok on 3/10/13.
//  Copyright (c) 2013 Matthew Cheok. All rights reserved.
//

#import "MCViewController.h"
#import "MCPanelViewController.h"

@interface MCViewController ()

@end

@implementation MCViewController {
    MCPanelViewController *_lightPanelViewController;
    MCPanelViewController *_tintedPanelViewController;
}

- (IBAction)leftButton:(id)sender {
    [self.navigationController presentPanelViewController:_lightPanelViewController withDirection:MCPanelAnimationDirectionLeft];
}

- (IBAction)rightButton:(id)sender {
    [self.navigationController presentPanelViewController:_tintedPanelViewController withDirection:MCPanelAnimationDirectionRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LightPanelViewControllerInNavigationController"];
    controller.preferredContentSize = CGSizeMake(420, 0);
    _lightPanelViewController = [controller viewControllerInPanelViewController];



    controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TintedPanelViewController"];
    _tintedPanelViewController = [controller viewControllerInPanelViewController];
    _tintedPanelViewController.backgroundStyle = MCPanelBackgroundStyleTinted;
    _tintedPanelViewController.tintColor = [UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:_lightPanelViewController withDirection:MCPanelAnimationDirectionLeft];
    [self.navigationController addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:_tintedPanelViewController withDirection:MCPanelAnimationDirectionRight];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController:_lightPanelViewController];
    [self.navigationController removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController:_tintedPanelViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

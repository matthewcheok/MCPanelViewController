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
    [_lightPanelViewController presentInViewController:self.navigationController withDirection:MCPanelAnimationDirectionLeft];
}

- (IBAction)rightButton:(id)sender {
    [_tintedPanelViewController presentInViewController:self.navigationController withDirection:MCPanelAnimationDirectionRight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LightPanelViewControllerInNavigationController"];
    controller.preferredContentSize = CGSizeMake(440, 0);
    _lightPanelViewController = [[MCPanelViewController alloc] initWithRootViewController:controller];

    [self.navigationController.view addGestureRecognizer:[_lightPanelViewController gestureRecognizerForScreenEdgeGestureInViewController:self.navigationController withDirection:MCPanelAnimationDirectionLeft]];

    controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TintedPanelViewController"];
    _tintedPanelViewController = [[MCPanelViewController alloc] initWithRootViewController:controller];
    _tintedPanelViewController.masking = NO;
    _tintedPanelViewController.backgroundStyle = MCPanelBackgroundStyleTinted;
    _tintedPanelViewController.tintColor = [UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1];

    [self.navigationController.view addGestureRecognizer:[_tintedPanelViewController gestureRecognizerForScreenEdgeGestureInViewController:self.navigationController withDirection:MCPanelAnimationDirectionRight]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

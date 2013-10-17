MCPanelViewController
=====================

Drop-in panel control for iOS with blurring background and screen-edge activation gestures.


##Screenshot
![Screenshot](https://raw.github.com/mehsome/MCPanelViewController/master/screenshot.png "Example of MCPanelViewController")

## Installation

Add the following to your [CocoaPods](http://cocoapods.org/) Podfile

    pod 'MCPanelViewController'

or clone as a git submodule,

or just copy files in the ```MCPanelViewController``` folder into your project.

## Using MCPanelViewController

First, setup your view controller to display within the panel view controller, then instantiate `MCPanelViewController` like this:

    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LightPanelViewControllerInNavigationController"];

    MCPanelViewController *panelController = [[MCPanelViewController alloc] initWithRootViewController:controller];

or using the convenience method on `UIViewController`:

    MCPanelViewController *panelController = [controller viewControllerInPanelViewController];

Adjust `preferredContentSize` on your view controller to set the desired width of the panel (default is 320 points). The height is ignored:

    controller.preferredContentSize = CGSizeMake(440, 0);

To open the panel programatically, such as from a button:

    [panelController presentInViewController:self.navigationController withDirection:MCPanelAnimationDirectionRight];

or using the convenience method on `UIViewController`:

    [self.navigationController presentPanelViewController:panelController withDirection:MCPanelAnimationDirectionRight];

You may also use `MCPanelAnimationDirectionLeft`. Present the controller in a full-screen view controller, such as a top-level navigation controller.

## Optional Configuration

Turn off the background masking effect:

    panelController.masking = NO;

Turn off pan gesture on the panel:

    panelController.panningEnabled = NO;

Adjust background style of the panel:

    panelController.backgroundStyle = MCPanelBackgroundStyleTinted;
    panelController.tintColor = [UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1];

You can also use background styles `MCPanelBackgroundStyleLight`, `MCPanelBackgroundStyleExtraLight` and `MCPanelBackgroundStyleDark` to match iOS 7 built-in styles. `tintColor` property is ignored if style is not `MCPanelBackgroundStyleTinted`.

## Screen Edge Gestures

To configure a screen-edge gesture on your top-level view controller, use the following convenience methods on `UIViewController`:

    - (void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];

        [self.navigationController addGestureRecognizerToViewForScreenEdgeGestureWithPanelViewController:panelController withDirection:MCPanelAnimationDirectionRight];
    }

    - (void)viewDidDisappear:(BOOL)animated {
        [super viewDidDisappear:animated];

        [self.navigationController removeGestureRecognizersFromViewForScreenEdgeGestureWithPanelViewController:panelController];
    }


## License

MCPanelViewController is under the MIT license.

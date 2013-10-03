MCPanelViewController
=====================

Drop-in panel control for iOS with blurring background and screen-edge activation gestures.


##Screenshot
![Screenshot](https://raw.github.com/mehsome/MCPanelViewController/master/screenshot.png "Example of MCPanelViewController")

## Using MCPanelViewController

Instantiate `MCPanelViewController` like this:

    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LightPanelViewControllerInNavigationController"];
    controller.preferredContentSize = CGSizeMake(440, 0);

    MCPanelViewController *panelController = [[MCPanelViewController alloc] initWithRootViewController:controller];

Adjust `preferredContentSize` to set the desired width of the panel. The height is ignored.

Additionally, configure the panel like this:

    panelController.masking = NO;
    panelController.backgroundStyle = MCPanelBackgroundStyleTinted;
    panelController.tintColor = [UIColor colorWithRed:0.7 green:0.7 blue:1 alpha:1];

You can also use background styles `MCPanelBackgroundStyleLight`, `MCPanelBackgroundStyleExtraLight` and `MCPanelBackgroundStyleDark` to match iOS 7 built-in styles. `tintColor` property is ignored if style is not `MCPanelBackgroundStyleTinted`.

To open the panel programatically, such as from a button:

    [panelController presentInViewController:self.navigationController withDirection:MCPanelAnimationDirectionRight];

You may also use `MCPanelAnimationDirectionLeft`. Present the controller in a full screen controller, such as the top-level navigation controller.

To configure a screen-edge gesture:

    [self.navigationController.view addGestureRecognizer:[panelController gestureRecognizerForScreenEdgeGestureInViewController:self.navigationController withDirection:MCPanelAnimationDirectionRight]];


## License

MCPanelViewController is under the MIT license.

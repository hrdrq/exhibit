//
//  WebViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/9/27.
//
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webView;
@synthesize url ;
@synthesize toolbar;
@synthesize forwardButton;
@synthesize backButton;
@synthesize stopButton;
@synthesize reloadButton;
@synthesize actionButton;

- (void)backButtonPressed:(id)sender
{
    if([self.webView canGoBack]) [self.webView goBack];
}


- (void)forwardButtonPressed:(id)sender
{
    if([self.webView canGoForward]) [self.webView goForward];
}


- (void)stopReloadButtonPressed:(id)sender
{
    if([activityIndicator isAnimating])
    {
        [self.webView stopLoading];
        [activityIndicator stopAnimating];
    }
    else
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }
    
    [self updateToolbar];
}


- (void)actionButtonPressed:(id)sender
{
    UIActionSheet *uias = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:ACTION_CANCEL
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:ACTION_OPEN_IN_SAFARI, nil];
    
    [uias showInView:self.view];
}

- (void)updateToolbar
{
    // toolbar
    self.forwardButton.enabled = [self.webView canGoForward];
    self.backButton.enabled = [self.webView canGoBack];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] initWithObjects:self.backButton, flexibleSpace, self.forwardButton,
                                      flexibleSpace, self.reloadButton, flexibleSpace, self.actionButton, nil];
    
    if([activityIndicator isAnimating]) [toolbarButtons replaceObjectAtIndex:4 withObject:self.stopButton];
    
    [self.toolbar setItems:toolbarButtons animated:YES];
    
    // page title
    NSString *pageTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if(pageTitle) [[self navigationItem] setTitle:pageTitle];
    
    
    // If there is a navigation controller, take up the same style for the toolbar.
    if (self.navigationController) {
        self.toolbar.barStyle = self.navigationController.navigationBar.barStyle;
        self.toolbar.tintColor = self.navigationController.navigationBar.tintColor;
        
        // iOS5 specific part
        if ([self.navigationController.navigationBar respondsToSelector:@selector(backgroundImageForBarMetrics:)]) {
            if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]) {
                [self.toolbar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]
                              forToolbarPosition:UIToolbarPositionAny
                                      barMetrics:UIBarMetricsDefault];
                
            }
            
            if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone]) {
                [self.toolbar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone]
                              forToolbarPosition:UIToolbarPositionAny
                                      barMetrics:UIBarMetricsLandscapePhone];
                
            }
            
        }
        
        
        
        
    }
}


/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSURL*)u
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 self.webView.delegate = self;
 self.url = u;
 
 activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
 
 self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:PNG_BUTTON_FORWARD]
 style:UIBarButtonItemStylePlain
 target:self
 action:@selector(forwardButtonPressed:)];
 
 
 self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:PNG_BUTTON_BACK]
 style:UIBarButtonItemStylePlain
 target:self
 action:@selector(backButtonPressed:)];
 
 self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
 target:self
 action:@selector(stopReloadButtonPressed:)];
 
 self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
 target:self
 action:@selector(stopReloadButtonPressed:)];
 
 self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
 target:self
 action:@selector(actionButtonPressed:)];
 
 // Hide tab bars / toolbars etc
 self.hidesBottomBarWhenPushed = YES;
 }
 return self;
 }*/


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:PNG_BUTTON_FORWARD]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(forwardButtonPressed:)];
    
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:PNG_BUTTON_BACK]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(backButtonPressed:)];
    
    self.stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                    target:self
                                                                    action:@selector(stopReloadButtonPressed:)];
    
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self
                                                                      action:@selector(stopReloadButtonPressed:)];
    
    self.actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(actionButtonPressed:)];
    
    // Hide tab bars / toolbars etc
    self.hidesBottomBarWhenPushed = YES;
    
    self.webView.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self updateToolbar];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setToolbar:nil];
    [self setUrl:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setStopButton:nil];
    [self setReloadButton:nil];
    [self setActionButton:nil];
    [[self navigationItem] setRightBarButtonItem:nil];
    [super viewDidUnload];
}

#pragma mark - WebView Delegate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [activityIndicator startAnimating];
    [self updateToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if(activityIndicator) [activityIndicator stopAnimating];
    [self updateToolbar];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)uias clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [uias cancelButtonIndex]) return;
    
    if([[uias buttonTitleAtIndex:buttonIndex] compare:ACTION_OPEN_IN_SAFARI] == NSOrderedSame)
    {
        [[UIApplication sharedApplication] openURL:self.url];
    }
    
}

@end

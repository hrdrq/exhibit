//
//  WebViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/9/27.
//
//

#import <UIKit/UIKit.h>

#define PNG_BUTTON_FORWARD @"right.png"
#define PNG_BUTTON_BACK @"left.png"

#define ACTION_CANCEL           @"取消"
#define ACTION_OPEN_IN_SAFARI   @"用Safari開啟"

@interface WebViewController : UIViewController<UIWebViewDelegate,
UIActionSheetDelegate>
{
    UIActivityIndicatorView *activityIndicator;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property(strong, nonatomic) UIBarButtonItem *backButton;
@property(strong, nonatomic) UIBarButtonItem *forwardButton;
@property(strong, nonatomic) UIBarButtonItem *stopButton;
@property(strong, nonatomic) UIBarButtonItem *reloadButton;
@property(strong, nonatomic) UIBarButtonItem *actionButton;

@end

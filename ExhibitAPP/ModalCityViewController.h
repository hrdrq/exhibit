//
//  ModalCityViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/10/7.
//
//

#import <UIKit/UIKit.h>
#import "Exhibit.h"

@interface ModalCityViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;

- (IBAction)barButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)selectAll;
- (IBAction)deselectAll;
@end

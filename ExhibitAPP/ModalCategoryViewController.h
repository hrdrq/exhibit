//
//  ModalCategoryViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/10/7.
//
//

#import <UIKit/UIKit.h>
#import "Exhibit.h"

@interface ModalCategoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic) int filteringType;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)barButtonItemPressed:(UIBarButtonItem *)sender;
- (IBAction)selectAll;
- (IBAction)deselectAll;

@end

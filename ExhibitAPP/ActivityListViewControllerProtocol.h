//
//  ActivityListViewControllerProtocol.h
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/18.
//
//

#import <Foundation/Foundation.h>
#import "SQLConstraintMaker.h"

/*
 * This protocol is for segue to other view controller from the activity
 * list view controller.
 *
 * The main reason is sometimes we will attach the activity list view controller
 * to the view controller. When the main view controller need to segue to
 * other view controller, it cannot segue from the attached VC directly.
 * When this situation occurs, please implement the protocol and attach it to the
 * activity view controller.
 */
@protocol ActivityListVCSegueFromOtherVCProtocol <NSObject>
-(void) SegueFromAttachVC2OtherVC:(NSIndexPath *)indexPath;
@end

/*
 * This protocol is for updating the activity list table when some action
 * is activated intermediatly.
 *
 * Because the MyFavorite view controller need to reload data when the
 * item is removed intermediately. So this protocol is needed to update
 * it.
 */
@protocol UpdateActivityListTableViewProtocol <NSObject>
- (void) UpdateActivityListTableFromOtherVC;
@end

/*
 * This protocol is for the assign the right data for activity list view
 * controller.
 *
 * The reason is activity list VC is the main VC we use. But there are
 * small differences between the normal ActivityListVC and MyFavoriteVC.
 * So the protocol is for setup the array table view controller need to
 * use when table data use to load.
 *
 */
@protocol ActivityListDataSetupProtocol <NSObject>
- (NSMutableArray*) dataSetup: (SQLConstraintMaker*) sqlHandler;
@end

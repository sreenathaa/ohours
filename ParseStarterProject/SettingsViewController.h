//
//  SettingsViewController.h
//  Ohours
//
//  Created by Clay Zug on 3/18/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UIViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UITableView *theTableView;

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@property (nonatomic,retain) UISwitch *availableToggleSwitch;
//@property (nonatomic,retain) UILabel *availableSwitchLabel;
@property (nonatomic,retain) UILabel *availableLabel;

@end

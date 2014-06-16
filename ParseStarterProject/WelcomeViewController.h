//
//  WelcomeViewController.h
//  Ohours
//
//  Created by Clay Zug on 3/20/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface WelcomeViewController : UIViewController


@property (nonatomic, strong) NSString *passedTwitterIdString;
@property (nonatomic, strong) NSString *passedTwitterSceenName;
@property (nonatomic, strong) NSString *passedTwitterDisplayName;
@property (nonatomic, strong) UIImage *passedTwitterProfileImage;

@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile; 
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

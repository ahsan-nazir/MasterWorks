//
//  SignINViewController.h
//  RSSreader
//
//  Created by Ahsan Nazir on 20/11/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPMasterViewController.h"

@interface SignINViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (weak, nonatomic) IBOutlet UITextField *passWordFiled;
- (IBAction)signInBtnClicked:(id)sender;
@end

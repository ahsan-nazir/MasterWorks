//
//  SignINViewController.m
//  RSSreader
//
//  Created by Ahsan Nazir on 20/11/2016.
//  Copyright © 2016 Appcoda. All rights reserved.
//

#import "SignINViewController.h"
#import "DBManager.h"

@interface SignINViewController ()

@end

@implementation SignINViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:FALSE];
    [[DBManager getSharedInstance] saveDataInLoginTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signInBtnClicked:(id)sender
{
    if ([_nameField.text isEqualToString:@"admin@admin.com"] && [_passWordFiled.text isEqualToString:@"asdf1234"])
    {
        
        NSString * storyboardName = @"MainStoryboard";
        NSString * viewControllerID = @"APPMasterViewController";
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        APPMasterViewController * controller = (APPMasterViewController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
        [self.navigationController pushViewController:controller animated:TRUE];
        
//        [self presentViewController:controller animated:YES completion:nil];
        
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Please enter valid data" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        //[self closeAlertview];
        }]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:alertController animated:YES completion:nil];
        });

    }
    
}
@end

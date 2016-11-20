//
//  APPDetailViewController.m
//  RSSreader
//
//  Created by AHSAN NAZIR RAJA on 20/11/2016.
//  Copyright (c) 2016 Ahsan. All rights reserved.
//

#import "APPDetailViewController.h"

@implementation APPDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:FALSE];

    
    NSURL *myURL = [NSURL URLWithString: [self.url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.webView loadRequest:request];
    
}

@end

//
//  APPDetailViewController.h
//  RSSreader
//
//  Created by AHSAN NAZIR RAJA on 20/11/2016.
//  Copyright (c) 2016 Ahsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPDetailViewController : UIViewController

@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

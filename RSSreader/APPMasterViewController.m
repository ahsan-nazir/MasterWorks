//
//  APPMasterViewController.m
//  RSSreader
//
//  Created by AHSAN NAZIR RAJA on 20/11/2016.
//  Copyright (c) 2016 Ahsan. All rights reserved.
//

#import "APPMasterViewController.h"
#import "APPDetailViewController.h"
#import "NewsItemCell_home.h"
#import "DBManager.h"


@interface APPMasterViewController () {
    NSXMLParser *parser;
    NSMutableArray *feeds;
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *description;
    NSMutableString *imgURL;
    NSMutableString *link;
    NSString *element;
}
@end

@implementation APPMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    feeds = [[NSMutableArray alloc] init];
    
    [self.navigationController setNavigationBarHidden:FALSE];

    
    NSMutableArray *arrRSSFeeds = [[DBManager getSharedInstance] getAllRSSFeeds];
    
    if ([arrRSSFeeds count]>0) {
        
        feeds = arrRSSFeeds;
        [self.tableView reloadData];
        
    }else{
        
        NSURL *url = [NSURL URLWithString:@"http://rss.cnn.com/rss/edition.rss"];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:YES];
        [parser parse];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    static NSString *customCellMustWatch = @"NewsItemCell_home";
    
    NewsItemCell_home *cellFoodItem = (NewsItemCell_home *)[tableView dequeueReusableCellWithIdentifier:customCellMustWatch];
    
    if (cellFoodItem == nil){
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewsItemCell_home" owner:self options:nil];
        
        cellFoodItem = [nib objectAtIndex:0];
    }

    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cellFoodItem.lblTitleNews.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
    cellFoodItem.lblDescriptionNews.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"description"];
    return cellFoodItem;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    
    
    NSString * storyboardName = @"MainStoryboard";
    NSString * viewControllerID = @"APPDetailViewController";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    APPDetailViewController * controller = (APPDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    
    NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
    controller.url = string;
    
    [self.navigationController pushViewController:controller animated:TRUE];

//    [self presentViewController:controller animated:YES completion:nil];

    
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    element = elementName;
//    NSLog(@"TEST elements are %@",element);
    if ([element isEqualToString:@"item"]) {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        description   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        
    }
//    else if ([element isEqualToString:@"media:group"]) {
//        
//        NSLog(@"media:group elements are %@",element);
//        imgURL   = [[NSMutableString alloc] init];
//        
//    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
//    NSLog(@"element = %@",element);
//    NSLog(@"string = %@",string);
//
//    if ([string isEqualToString:@"media:group"]) {
//        NSLog(@"media:group string = %@",string);
//    }
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    }else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    }else if ([element isEqualToString:@"media:group"]) {
        [imgURL appendString:string];
    }else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    NSLog(@"element = %@",elementName);
    NSLog(@"qName = %@",qName);

    if ([elementName isEqualToString:@"item"]) {
        
        NSLog(@"Ahsan Test = %@",elementName);

        [item setObject:title forKey:@"title"];
        [item setObject:description forKey:@"description"];
        [item setObject:link forKey:@"link"];
        [feeds addObject:[item copy]];
        
    }
//    else if ([elementName isEqualToString:@"media:group"]) {
//        
//        NSLog(@"Ahsan Test = %@",elementName);
//        
//        [item setObject:imgURL forKey:@"media:group"];
//        [feeds addObject:[item copy]];
//        
//    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    [self.tableView reloadData];
    
    BOOL isInserted = [[DBManager getSharedInstance] saveAllRSSFeeds:feeds];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
        [[segue destinationViewController] setUrl:string];
        
    }
}

@end

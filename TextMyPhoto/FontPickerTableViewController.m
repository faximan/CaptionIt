//
//  FontPickerTableViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "FontPickerTableViewController.h"
#import "GenericTableViewCell.h"

@implementation FontPickerTableViewController
{
    NSArray *fontArray;
}

#pragma mark - Table view data source

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set current fonts
    fontArray = FONT_ARRAY;
    [self.tableView reloadData];
}

- (GenericTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GenericTableViewCell *cell = (GenericTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Set the image
    cell.cellImage.image = self.curImage;
    
    // Set the string to be the font name if no string is set
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fontArray count];
}

#pragma mark - Table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // Should respond to this when subclassing
    if ([self.delegate respondsToSelector:@selector(fontPickerTableViewController:didFinishWithFont:)])
        [(id)self.delegate fontPickerTableViewController:self didFinishWithFont:fontArray[indexPath.row]];
}

@end

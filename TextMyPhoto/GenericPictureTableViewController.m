//
//  GenericPictureTableViewController.m
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-17.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericPictureTableViewController.h"
#import "GenericTableViewCell.h"
#import "StampedImage+Create.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utilities.h"

@interface GenericPictureTableViewController ()

@end

@implementation GenericPictureTableViewController

+(CGFloat)cellHeight
{
    return MAX_CELL_HEIGHT;
}

+(CGFloat)cellWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+(UIImage *)modifyImageToFillCell:(UIImage *)image
{
    CGFloat cellHeight = [self cellHeight];
    CGFloat cellWidth = [self cellWidth];
    
    // Do not scale image if it is already small
    if (image.size.height <= cellHeight || image.size.width <= cellWidth)
        return image;
    
    // Scale down image to be a good fit for the cell and do not store a bigger image than necessary
    CGFloat heightScale = cellHeight / image.size.height;
    CGFloat widthScale = cellWidth / image.size.width;
    
    CGFloat newWidth, newHeight;
    
    if (heightScale * image.size.width < cellWidth)
    {
        newWidth = cellWidth;
        newHeight = image.size.height * widthScale;
    }
    else
    {
        newWidth = image.size.width * heightScale;
        newHeight = cellHeight;
    }
    
    // Scale down the image to the calculated new size and crop out the center part to get an image as big as the thumb should be
    return [[UIImage imageWithImage:image scaledToSize:CGSizeMake(newWidth, newHeight)] getCenterOfImageWithWidth:cellWidth andHeight:cellHeight];
}

+(NSAttributedString *)makeAttributedStringForString:(NSString *)string andFont:(NSString *)font andColor:(UIColor *)color
{
    NSRange wholeString = NSMakeRange(0, [string length]);
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    
    // Null string equals empty string
    if (!string)
        string = @"";
    NSMutableAttributedString *fontString = [[NSMutableAttributedString alloc] initWithString:string];
    
    // TODO: Remove 30.0f
    [fontString addAttribute:NSFontAttributeName value:[UIFont fontWithName:font size:30.0f] range:wholeString];
    [fontString addAttribute:NSParagraphStyleAttributeName value:style range:wholeString];
    
    if (color)
        [fontString addAttribute:NSForegroundColorAttributeName value:color range:wholeString];
    return fontString;
}

-(IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate didCancelGenericPictureTableViewController:self];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Generic Cell";
    GenericTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Add drop shadow
    cell.layer.shadowOffset = CGSizeMake(1, 0);
    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.layer.shadowRadius = 5;
    cell.layer.shadowOpacity = .75;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    
    // Override and do your own customization
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return MAX_CELL_HEIGHT;
}

#pragma mark - Table view

// Override to do something else than dissmissing
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate didCancelGenericPictureTableViewController:self];
}

@end

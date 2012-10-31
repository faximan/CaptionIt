//
//  GenericCollectionViewController.h
//  Stamp it!
//
//  Created by Alexander Faxå on 2012-10-30.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "CoreDataCollectionViewController.h"

@protocol GenericCollectionViewControllerDelegate;

@interface GenericCollectionViewController : CoreDataCollectionViewController

@property (nonatomic, weak) id<GenericCollectionViewControllerDelegate> delegate;

-(IBAction)cancelButtonPressed:(id)sender;

@end

@protocol GenericCollectionViewControllerDelegate <NSObject>

- (void)didCancelGenericCollectionViewController:(GenericCollectionViewController *)genericCollectionViewController;

@end
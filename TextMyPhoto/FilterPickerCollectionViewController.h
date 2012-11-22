//
//  FilterPickerCollectionViewController.h
//  Caption it!
//
//  Created by Alexander Faxå on 2012-11-22.
//  Copyright (c) 2012 Alexander Faxå. All rights reserved.
//

#import "GenericCollectionViewController.h"

@protocol FilterPickerCollectionViewControllerDelegate;

@interface FilterPickerCollectionViewController : GenericCollectionViewController

typedef enum 
{
    FILTER_NORMAL,
    FILTER_BW,
    FILTER_SEPIA,
    FILTER_CONTRAST
}filterTypes;

@end

@protocol FilterPickerCollectionViewControllerDelegate <GenericCollectionViewControllerDelegate>

- (void)filterPickerCollectionViewController:(FilterPickerCollectionViewController *)filterPickerCollectionViewController didFinishWithFilter:(filterTypes)filter;

@end

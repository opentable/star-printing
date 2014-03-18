//
//  PrinterCell.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/15/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import <UIKit/UIKit.h>

// Delcared here so the VC can calc the proper height for it
#define kPrinterCellSubtextFont        [UIFont fontWithName:@"ProximaNova-Regular" size:15]

#define PrinterCellAccessibilityLabel(printer) WFStr(@"Printer %@", printer)

@class Printer;
@interface PrinterCell : UITableViewCell

@property (nonatomic, weak) Printer *printer;

@end

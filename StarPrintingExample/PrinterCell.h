//
//  PrinterCell.h
//  StarPrintingExample
//
//  Created by Matthew Newberry on 4/15/13.
//  OpenTable
//

#import <UIKit/UIKit.h>

@class Printer;
@interface PrinterCell : UITableViewCell

@property (nonatomic, weak) Printer *printer;

@end

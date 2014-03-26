//
//  ViewController.h
//  StarPrintingExample
//
//  Created by Will Loderhose on 3/18/14.
//  OpenTable
//

#import <UIKit/UIKit.h>
#import <StarPrinting/StarPrinting.h>
#import "PrinterCell.h"

@protocol PrinterConnectivityDelegate <NSObject>

- (void)connectedPrinterDidChangeTo:(Printer *)printer;

@end

@class Printer,GlobalNavigationViewController;
@interface ViewController : UIViewController <Printable, PrinterDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

- (void)addDelegate:(id<PrinterConnectivityDelegate>)delegate;
- (void)removeDelegate:(id<PrinterConnectivityDelegate>)delegate;

+ (NSString *)iconForPrinterStatus:(PrinterStatus)status;
+ (NSString *)statusMessageForPrinterStatus:(PrinterStatus)status;

@end

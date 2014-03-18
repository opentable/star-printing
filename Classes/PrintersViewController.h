//
//  PrintingViewController.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/10/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Printer.h"

@protocol PrinterConnectivityDelegate <NSObject>

- (void)connectedPrinterDidChangeTo:(Printer *)printer;

@end

@class Printer,GlobalNavigationViewController;
@interface PrintersViewController : UIViewController <PrinterDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) GlobalNavigationViewController *globalNav;
@property (weak, nonatomic) IBOutlet UITableView *printersTableView;
@property (weak, nonatomic) IBOutlet UILabel *printersLabel;

+ (NSString *)iconForPrinterStatus:(PrinterStatus)status;
+ (NSString *)statusMessageForPrinterStatus:(PrinterStatus)status;

- (void)addDelegate:(id<PrinterConnectivityDelegate>)delegate;
- (void)removeDelegate:(id<PrinterConnectivityDelegate>)delegate;

@end
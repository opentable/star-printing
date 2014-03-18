//
//  PrintingViewController.m
//  Quickcue
//
//  Created by Matthew Newberry on 4/10/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import "PrintersViewController.h"
#import "Printer.h"
#import "UIView+AlertView.h"
#import "GlobalNavigationViewController.h"
#import "PrinterCell.h"
#import "QCFont.h"
#import "QCButtonFactory.h"
#import <MZFormSheetController.h>
#import "TimelineStore.h"
#import "PrintParser.h"

#define kPadding                    10.f
#define kLoadingAnimationDuration   0.25f
#define kBtnSize                    CGSizeMake(80,30)
#define kPrinterLabelFont           [UIFont fontWithName:@"ProximaNova-Semibold" size:19.f]
#define kBtnFont                    [UIFont fontWithName:@"ProximaNova-Semibold" size:14.f];
#define kHelpFont                   [UIFont fontWithName:@"ProximaNova-Regular" size:12.f];

#define kPrinterCellHeight          44.f

@interface PrintersViewController ()

@property (nonatomic, strong) NSMutableArray *printers;
@property (nonatomic, strong) Printer *connectedPrinter;
@property (nonatomic, strong) AlertView *alertView;

@property (nonatomic, weak) IBOutlet QCButton *printTestBtn;
@property (nonatomic, weak) IBOutlet QCButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, weak) IBOutlet UILabel *emptyLabel;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;

@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL empty;
@property (nonatomic, assign) PrinterStatus printerStatus;

@property (nonatomic, strong) NSHashTable *delegates;

- (void)close;
- (void)notifyDelegates;
- (IBAction)printTest;
- (IBAction)search;

- (void)sendPrinterStatusNotification;
- (void)sendPrinterStatusNotification:(BOOL)condition withKey:(NSString *)key;

@end

@implementation PrintersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.printers = [NSMutableArray array];
        
        if ([Printer connectedPrinter]) {
            [self.printers addObject:[Printer connectedPrinter]];
        }
        
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        [self search];
        
        self.delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Printers", @"Printers");
    self.printersTableView.tableFooterView = [[UIView alloc] init];
    
    _spinner.color = [UIColor qcPlaceholderColor];
	
    _printersLabel.font = kPrinterLabelFont;
    _printersLabel.textColor = [UIColor qcTextColor];
    [_printersLabel sizeToFit];
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Close") style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
    _printTestBtn.titleLabel.font =
    _searchBtn.titleLabel.font = kBtnFont;
    
    _searchBtn.fillColor = [UIColor qcBlueColor];
    _printTestBtn.fillColor = [UIColor qcGrayColor];
    
    [self updatePrintTestBtn:_printerStatus];
    
    _searchBtn.roundedCorners =
    _printTestBtn.roundedCorners = UIRectCornerAllCorners;
    
    _searchBtn.font =
    _printTestBtn.font = kBtnFont;
    
    _searchBtn.titleColor =
    _printTestBtn.titleColor = [UIColor whiteColor];
    
    _emptyLabel.font = kPrinterCellSubtextFont;
    _emptyLabel.textColor = [UIColor qcTextColor];
    _emptyLabel.alpha = _empty;
    
    _helpLabel.font = kHelpFont;
    _helpLabel.textColor = [UIColor qcTextColor];
    _helpLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _helpLabel.numberOfLines = 0;
    [self updateHelpLabel:_printerStatus];
    
    // Update UI
    if(_searching) {
        self.searching = YES;
    }
    
    self.printersTableView.accessibilityIdentifier = self.printersTableView.accessibilityLabel = kAccessPrintersTableView;
    self.view.accessibilityLabel = kAccessPrintersView;
    _searchBtn.accessibilityLabel = kAccessPrintersSearch;
    _printTestBtn.accessibilityLabel = kAccessPrintTest;
    closeBtn.accessibilityLabel = kAccessPrintersViewClose;
    _spinner.accessibilityLabel = kAccessPrinterSearchSpinner;
    _emptyLabel.accessibilityLabel = kAccessPrinterNoneAvailable;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close
{
    [self dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (void)printTest
{
    Printer *printer = [Printer connectedPrinter];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"print_test" ofType:@"xml"];
    NSData *contents = [[NSFileManager defaultManager] contentsAtPath:filePath];
    NSMutableString *s = [[NSMutableString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
    
    NSDateFormatter *dateFormat = dateFormatterFromFormatString(@"MMMM d, yyyy h:mm a");
    NSString *date = [dateFormat stringFromDate:[NSDate date]];
    
    NSDictionary *data = @{
                           @"{{locationName}}" : [[TimelineStore defaultStore].location name],
                           @"{{printerStatus}}" : [Printer stringForStatus:printer.status],
                           @"{{printerName}}" : printer.name,
                           @"{{date}}" : date
                           };
    
    [data enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [s replaceOccurrencesOfString:key withString:value options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    }];
    
    PrintParser *parser = [[PrintParser alloc] init];
    NSData *formatted = [parser parse:[s dataUsingEncoding:NSUTF8StringEncoding]];
    [printer print:formatted];
}

- (void)setConnectedPrinter:(Printer *)connectedPrinter
{        
    if(connectedPrinter == nil && _connectedPrinter) {
        if([_connectedPrinter isReadyToPrint]) {
            [_connectedPrinter disconnect];
        }
        _connectedPrinter = nil;
        [self notifyDelegates];
        
    } else if(connectedPrinter) {
        _connectedPrinter = connectedPrinter;
        _connectedPrinter.delegate = self;
        [_connectedPrinter connect:^(BOOL success) {
            if(!success){
                self.connectedPrinter = nil;
            }
            
            [self notifyDelegates];
        }];
    }
}

- (void)setSearching:(BOOL)searching
{
    _searching = searching;
    
    if(searching) {
        self.empty = NO;
        [self sendPrinterStatusNotification:YES withKey:@"searching"];
        _helpLabel.text = kPrinterSearchingMessage;
    } else {
        [self updateHelpLabel:_printerStatus];
    }
    
    _searchBtn.enabled = !searching;
    searching ? [_spinner startAnimating] : [_spinner stopAnimating];
    [UIView animateWithDuration:kLoadingAnimationDuration animations:^{
        _printersTableView.alpha = !searching;
    }];
}

- (void)setEmpty:(BOOL)empty
{
    _empty = empty;
    
    [UIView animateWithDuration:kLoadingAnimationDuration animations:^{
        _emptyLabel.alpha = _empty;
        _printersTableView.alpha = !_empty;
        
        if(_empty && [_spinner isAnimating]) {
            [_spinner stopAnimating];
        }
    }];
    
}

- (void)search
{
    if(_searching) return;
    
    [_printers removeAllObjects];
    
    self.searching = YES;
    self.connectedPrinter = nil;
    
    [Printer search:^(NSArray *found) {
        if([found count] > 0) {
            [self sendPrinterStatusNotification:YES withKey:@"found"];
            [_printers addObjectsFromArray:found];
                        
            if(!_connectedPrinter) {
                Printer *lastKnownPrinter = [Printer connectedPrinter];
                for(Printer *p in found) {
                    if([p.macAddress isEqualToString:lastKnownPrinter.macAddress]) {
                        
                        self.connectedPrinter = p;
                        break;
                    }
                }
            }
        } else {
            [self sendPrinterStatusNotification:NO withKey:@"found"];
        }
        
        self.empty = [found count] == 0;
        
        [self.printersTableView reloadData];
        self.searching = NO;
    }];
}

#pragma mark - Notifications
- (void)sendPrinterStatusNotification:(BOOL)condition withKey:(NSString *)key
{
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:condition]                                                 forKey:key];
    [[NSNotificationCenter defaultCenter] postNotificationName:QCPrinterStatusDidChange object:nil userInfo:dict];
}

- (void)sendPrinterStatusNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:QCPrinterStatusDidChange object:nil userInfo:nil];
}

#pragma mark - Printer Delegate
- (void)printer:(Printer *)printer didChangeStatus:(PrinterStatus)status
{
    NSLog(@"Printer %@ did change status - %@", printer, [Printer stringForStatus:status]);

    if([_printers containsObject:printer]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_printers indexOfObject:printer] inSection:0];
        [self.printersTableView beginUpdates];
        [self.printersTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.printersTableView endUpdates];
        
        [self updatePrintTestBtn:status];
        [self updateHelpLabel:status];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self.connectedPrinter];
        [defaults setObject:encoded forKey:kConnectedPrinterKey];
        [defaults synchronize];
        
        [self sendPrinterStatusNotification];
        
        _printerStatus = status;
    }
}

- (void)updateHelpLabel:(PrinterStatus)status
{
    if([_printers count] == 0) {
        _helpLabel.text = @"";
    } else if(status == PrinterStatusConnecting) {
        _helpLabel.text = kPrinterConnectingMessage;
    } else if(status == PrinterStatusConnected || status == PrinterStatusLowPaper) {
        _helpLabel.text = kPrinterConnectedMessage;
    } else {
        NSString *pluralChar = @"s";
        if([_printers count] == 1) {
            pluralChar = @"";
        }
        _helpLabel.text = [NSString stringWithFormat:@"%d printer%@ found. Select the printer to connect.", [_printers count], pluralChar];
    }
}

-(void)updatePrintTestBtn:(PrinterStatus)status
{
    _printTestBtn.enabled = status == PrinterStatusConnected || status == PrinterStatusLowPaper;
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_printers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Printer *printer = [_printers objectAtIndex:indexPath.row];
    NSString *message = [PrintersViewController statusMessageForPrinterStatus:printer.status];
    CGSize size = [message sizeWithFont:kPrinterCellSubtextFont constrainedToSize:CGSizeMake(_printersTableView.width - 35.f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    return printer.hasError ? kPrinterCellHeight + size.height : kPrinterCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    if (!cellIdentifier) {
        cellIdentifier = @"PrinterCell";
    }
    
    PrinterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[PrinterCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIdentifier];
    }
    
    Printer *printer = [_printers objectAtIndex:indexPath.row];
    cell.printer = printer;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Printer *printer = [_printers objectAtIndex:indexPath.row];
    if(_connectedPrinter.status == PrinterStatusConnecting) {
        [printer disconnect];
    }
    self.connectedPrinter = _connectedPrinter == printer ? nil : printer;
    [self updatePrintTestBtn:_connectedPrinter.status];
}

#pragma mark - Delegates
- (void)addDelegate:(id<PrinterConnectivityDelegate>)delegate
{
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<PrinterConnectivityDelegate>)delegate
{
    [_delegates removeObject:delegate];
}

- (void)notifyDelegates
{
    for (id <PrinterConnectivityDelegate> d in _delegates) {
        [d connectedPrinterDidChangeTo:self.connectedPrinter];
    }
}


#pragma mark - Status Helpers
+ (NSString *)iconForPrinterStatus:(PrinterStatus)status
{
    switch (status) {
        case PrinterStatusConnected:
            return kIconCheckmark;
            break;
            
        case PrinterStatusConnectionError:
        case PrinterStatusLostConnectionError:
        case PrinterStatusUnknownError:
        case PrinterStatusPrintError:
        case PrinterStatusCoverOpen:
        case PrinterStatusLowPaper:
        case PrinterStatusOutOfPaper:
            return kIconAlert;
            break;
            
        default:
            break;
    }
    
    return nil;
}

+ (NSString *)statusMessageForPrinterStatus:(PrinterStatus)status
{    
    switch (status) {
        case PrinterStatusUnknownError:
            return NSLocalizedString(@"The printer has just encountered an known error. Try turning the power to the printer off for 10 seconds and then turning it back on before attempting to reconnect.", @"Printer unkown error");
            break;
        case PrinterStatusConnectionError:
            return NSLocalizedString(@"Unable to connect to printer. Please try again. If you continue to see this error message, try turning the power to the printer off for 10 seconds and then turning it back on before attempting to reconnect.", @"Printer connection error");
            break;
        case PrinterStatusLostConnectionError:
            return NSLocalizedString(@"Connection to printer has been lost. Please make sure the printer is turned on and plugged in." , @"Lost Connection");
            break;
        default:
            return [Printer stringForStatus:status];
            break;
    }
}

@end

//
//  ViewController.m
//  StarPrintingExample
//
//  Created by Will Loderhose on 3/18/14.
//  Copyright (c) 2014 OpenTable. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

#define kPadding                    10.f
#define kLoadingAnimationDuration   0.25f
#define kBtnSize                    CGSizeMake(80,30)
#define kPrinterLabelFont           [UIFont fontWithName:@"ProximaNova-Semibold" size:19.f]
#define kBtnFont                    [UIFont fontWithName:@"ProximaNova-Semibold" size:14.f];
#define kHelpFont                   [UIFont fontWithName:@"ProximaNova-Regular" size:12.f];
#define kPrinterCellHeight          44.f
#define kPrinterCellSubtextFont     [UIFont fontWithName:@"ProximaNova-Regular" size:15]

#define kPrinterNotAvailableMessage     @"No printers found"
#define kPrinterConnectedMessage        @"Connected Printer"
#define kPrinterConnectingMessage       @"Connecting"
#define kPrinterSearchingMessage        @"Searching"
#define kPrinterAvailableMessage        @"Printers Available"

@property (nonatomic, weak) UITextField *activeField;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *searchBtn;
@property (nonatomic, weak) IBOutlet UIButton *printTestBtn;
@property (nonatomic, weak) IBOutlet UITableView *printersTableView;
@property (nonatomic, strong) IBOutlet UITextField *printableTextField;
@property (nonatomic, weak) IBOutlet UIButton *printBtn;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;

@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL empty;

@property (nonatomic, strong) NSMutableArray *printers;
@property (nonatomic, strong) Printer *connectedPrinter;
@property (nonatomic, assign) PrinterStatus printerStatus;

@property (nonatomic, strong) NSHashTable *delegates;

- (IBAction)search;
- (IBAction)printTest;
- (IBAction)print;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.printers = [NSMutableArray array];
        if ([Printer connectedPrinter]) {
            [self.printers addObject:[Printer connectedPrinter]];
        }
        self.delegates = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.printersTableView.tableFooterView = [[UIView alloc] init];
    
    _spinner.color = [UIColor lightGrayColor];
	
    _titleLabel.font = kPrinterLabelFont;
    _titleLabel.textColor = [UIColor blackColor];
    [_titleLabel sizeToFit];
    
    _searchBtn.backgroundColor =
    _printTestBtn.backgroundColor =
    _printBtn.backgroundColor = [UIColor darkGrayColor];
    
//    [self updatePrintTestBtn:_printerStatus];
    
    _searchBtn.titleLabel.font =
    _printTestBtn.titleLabel.font = kBtnFont;
    
    _searchBtn.titleLabel.textColor =
    _printTestBtn.titleLabel.textColor =
    _printBtn.titleLabel.textColor = [UIColor whiteColor];
    
    _helpLabel.font = kHelpFont;
    _helpLabel.textColor = [UIColor blackColor];
    _helpLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _helpLabel.numberOfLines = 0;
    [self updateHelpLabel:_printerStatus];
    
    _printableTextField.delegate = self;
    
    // Update UI
    if(_searching) {
        self.searching = YES;
    } else {
        self.searching = NO;
    }
    
    [self setSearching:self.searching];
    
    _activeField = nil;
    [self registerForKeyboardNotifications];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:_activeField.frame animated:YES];
    }
    
    CGRect bkgndRect = _activeField.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [_activeField.superview setFrame:bkgndRect];
    [_scrollView setContentOffset:CGPointMake(0.0, _activeField.frame.origin.y-kbSize.height) animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        _helpLabel.text = kPrinterSearchingMessage;
    } else {
        [self updateHelpLabel:_printerStatus];
    }
    
    _searchBtn.enabled = !searching;
    searching ? [_spinner setHidden:NO] : [_spinner setHidden:YES];
    searching ? [_spinner startAnimating] : [_spinner stopAnimating];
    [UIView animateWithDuration:kLoadingAnimationDuration animations:^{
        _printersTableView.alpha = !searching;
    }];
}

- (void)setEmpty:(BOOL)empty
{
    _empty = empty;
    
    [UIView animateWithDuration:kLoadingAnimationDuration animations:^{
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
        }
        self.empty = [found count] == 0;
        [self.printersTableView reloadData];
        self.searching = NO;
    }];
}

- (void)printTest
{
    Printer *printer = [Printer connectedPrinter];
    if(printer) {
        [printer printTest];
    }
}

- (void)print
{
    
}

- (void)printer:(Printer *)printer didChangeStatus:(PrinterStatus)status
{
    NSLog(@"Printer %@ did change status - %@", printer, [Printer stringForStatus:status]);
    
    if([_printers containsObject:printer]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_printers indexOfObject:printer] inSection:0];
        [self.printersTableView beginUpdates];
        [self.printersTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.printersTableView endUpdates];
        
//        [self updatePrintTestBtn:status];
        [self updateHelpLabel:status];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self.connectedPrinter];
        [defaults setObject:encoded forKey:kConnectedPrinterKey];
        [defaults synchronize];
        
        _printerStatus = status;
    }
}

- (void)updatePrintTestBtn:(PrinterStatus)status
{
    _printTestBtn.enabled = status == PrinterStatusConnected || status == PrinterStatusLowPaper;
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
    NSLog(@"Help label says -> %@", _helpLabel.text);
}

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
    NSString *message = [[self class] statusMessageForPrinterStatus:printer.status];
    CGSize size = [message sizeWithFont:kPrinterCellSubtextFont constrainedToSize:CGSizeMake(_printersTableView.frame.size.width - 35.f, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
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

+ (NSString *)iconForPrinterStatus:(PrinterStatus)status
{
    switch (status) {
        case PrinterStatusConnected:
            return @"";
            break;
            
        case PrinterStatusConnectionError:
        case PrinterStatusLostConnectionError:
        case PrinterStatusUnknownError:
        case PrinterStatusPrintError:
        case PrinterStatusCoverOpen:
        case PrinterStatusLowPaper:
        case PrinterStatusOutOfPaper:
            return @"";
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

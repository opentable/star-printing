//
//  PrinterCell.m
//  StarPrintingExample
//
//  Created by Matthew Newberry on 4/15/13.
//  OpenTable
//

#import "PrinterCell.h"
#import "Printer.h"
#import "ViewController.h"

#define kTitleFont                     [UIFont fontWithName:@"Arial" size:12]
#define kPrinterCellSubtextFont        [UIFont fontWithName:@"Arial" size:10]
#define kSpinnerWidth       30.f
#define kDefaultLabelHeight 36.f

@interface PrinterCell ()

@property (nonatomic, strong) UILabel *portName;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation PrinterCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        self.portName = [[UILabel alloc] init];
        
        _portName.font = kPrinterCellSubtextFont;
        self.textLabel.font = kTitleFont;
        
        _portName.textColor =
        self.textLabel.textColor = [UIColor blackColor];
        
        self.errorLabel = [[UILabel alloc] init];
        _errorLabel.font = kPrinterCellSubtextFont;
        _errorLabel.numberOfLines = 0;
        _errorLabel.textColor = [UIColor darkGrayColor];
        
        [self.contentView addSubview:_spinner];
        [self.contentView addSubview:_errorLabel];
        [self.contentView addSubview:_portName];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat labelWidth = ceilf((self.contentView.frame.size.width) / 2);
    
    [self setWidth:labelWidth forView:self.textLabel];
    [self setWidth:labelWidth forView:_portName];
    
    [self setHeight:kDefaultLabelHeight forView:self.textLabel];
    [self setHeight:kDefaultLabelHeight forView:_portName];
    
    [self setLeft:kSpinnerWidth forView:self.textLabel];
    [self setLeft:[self rightOfView:self.textLabel] forView:_portName];
    
    CGSize size = [_errorLabel.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - [self leftOfView:_errorLabel], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;

    [self setWidth:size.width forView:_errorLabel];
    [self setHeight:size.height forView:_errorLabel];
    [self setTop:[self bottomOfView:self.textLabel] forView:_errorLabel];
    [self setLeft:kSpinnerWidth forView:_errorLabel];
    
    [self setWidth:kSpinnerWidth forView:_spinner];
    [self setHeight:[self heightOfView:self.textLabel] forView:_spinner];
}

#pragma mark - Printer

- (void)setPrinter:(Printer *)printer
{
    _printer = printer;
    
    self.textLabel.text = printer.name;
    self.portName.text = printer.portName;
    
    if(printer.status == PrinterStatusConnecting) {
        [_spinner startAnimating];
    } else {
        [_spinner stopAnimating];
    }
    
    if(printer.status == PrinterStatusConnected) {
        [self setColorScheme:[UIColor colorWithRed:0.2f green:0.6f blue:0.2f alpha:1.0f]];
    } else if(printer.status == PrinterStatusLowPaper) {
        [self setColorScheme:[UIColor colorWithRed:0.4f green:0.4f blue:0.2f alpha:1.0f]];
    } else if(printer.hasError) {
        [self setColorScheme:[UIColor colorWithRed:0.6f green:0.2f blue:0.2f alpha:1.0f]];
    } else {
        [self setColorScheme:[UIColor colorWithRed:0.f green:0.f blue:0.f alpha:1.0f]];
    }
    
    NSLog(@"%i => %@", printer.hasError, printer);
    _errorLabel.text = [ViewController statusMessageForPrinterStatus:printer.status];
}

#pragma mark - Helpers

- (CGFloat)widthOfView:(UIView *)view
{
    return view.frame.size.width;
}

- (CGFloat)heightOfView:(UIView *)view
{
    return view.frame.size.height;
}

- (CGFloat)leftOfView:(UIView *)view
{
    return view.frame.origin.x;
}

- (CGFloat)rightOfView:(UIView *)view
{
    return [self leftOfView:view] + [self widthOfView:view];
}

- (CGFloat)topOfView:(UIView *)view
{
    return view.frame.origin.y;
}

- (CGFloat)bottomOfView:(UIView *)view
{
    return [self topOfView:view] + [self heightOfView:view];
}

- (void)setWidth:(CGFloat)width forView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, width, view.frame.size.height);
}

- (void)setHeight:(CGFloat)height forView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, height);
}

- (void)setLeft:(CGFloat)left forView:(UIView *)view
{
    view.frame = CGRectMake(left, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

- (void)setTop:(CGFloat)top forView:(UIView *)view
{
    view.frame = CGRectMake(view.frame.origin.x, top, view.frame.size.width, view.frame.size.height);
}

- (void)setColorScheme:(UIColor *)color
{
    self.textLabel.textColor =
    _portName.textColor = color;
}

@end

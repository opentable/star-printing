//
//  PrinterCell.m
//  Quickcue
//
//  Created by Matthew Newberry on 4/15/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import "PrinterCell.h"
#import "Printer.h"
#import "ViewController.h"

#define kTitleFont          [UIFont fontWithName:@"ProximaNova-Semibold" size:15]
#define kIconLabelFont      [UIFont fontWithName:@"Quickcue-Regular" size:15]
#define kIconLabelWidth     30.f
#define kDefaultLabelHeight 36.f

@interface PrinterCell ()

@property (nonatomic, strong) UILabel *portName;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation PrinterCell

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
        
        self.iconLabel = [[UILabel alloc] init];
        _iconLabel.font = kIconLabelFont;
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        
        self.errorLabel = [[UILabel alloc] init];
        _errorLabel.font = kPrinterCellSubtextFont;
        _errorLabel.numberOfLines = 0;
        _errorLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:_spinner];
        [self.contentView addSubview:_errorLabel];
        [self.contentView addSubview:_iconLabel];
        [self.contentView addSubview:_portName];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat labelWidth = ceilf((self.contentView.frame.size.width - kIconLabelWidth) / 2);
    
//    self.textLabel.width =
//    _portName.width = labelWidth;
//    
//    self.textLabel.height =
//    _portName.height = kDefaultLabelHeight;
//    
//    self.textLabel.left = kIconLabelWidth;
//    _portName.left = self.textLabel.right;
//    
//    _iconLabel.size = CGSizeMake(kIconLabelWidth, self.textLabel.height);
    
//    CGSize size = [_errorLabel.text sizeWithFont:_errorLabel.font constrainedToSize:CGSizeMake(self.contentView.width - _errorLabel.left, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    
//    _errorLabel.size = size;
//    _errorLabel.top = self.textLabel.bottom;
//    _errorLabel.left = self.textLabel.left;
    
    _spinner.frame = _iconLabel.frame;
}

- (void)setPrinter:(Printer *)printer
{
    _printer = printer;
    
    self.textLabel.text = printer.name;
    self.portName.text = printer.portName;
    
    _iconLabel.text = [ViewController iconForPrinterStatus:printer.status];
    
    if(printer.status == PrinterStatusConnecting) {
        _iconLabel.hidden = YES;
        [_spinner startAnimating];
    } else {
        _iconLabel.hidden = NO;
        [_spinner stopAnimating];
    }
    
    if(printer.status == PrinterStatusConnected) {
        _iconLabel.textColor = [UIColor blueColor];
    } else if(printer.status == PrinterStatusConnectionError ||
              printer.status == PrinterStatusLostConnectionError ||
              printer.status == PrinterStatusUnknownError ||
              printer.status == PrinterStatusPrintError ||
              printer.status == PrinterStatusOutOfPaper ||
              printer.status == PrinterStatusCoverOpen) {
        _iconLabel.textColor = [UIColor redColor];
    } else if(printer.status == PrinterStatusLowPaper) {
        _iconLabel.textColor = [UIColor orangeColor];
    }
    
    NSLog(@"%i => %@", printer.hasError, printer);
    _errorLabel.text = printer.hasError ? [ViewController statusMessageForPrinterStatus:printer.status] : @"";
}

@end

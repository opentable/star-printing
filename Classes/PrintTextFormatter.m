//
//  PrintTextFormatter.m
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import "PrintTextFormatter.h"

@interface PrintTextFormatter ()

@property (nonatomic, strong) NSMutableData *commands;

@end

@implementation PrintTextFormatter

+ (PrintTextFormatter *)formatter
{
    PrintTextFormatter *formatter = [[PrintTextFormatter alloc] init];
    return formatter;
}

- (id)init
{
    self = [super init];
    if(self) {
        self.commands = [NSMutableData data];
        [self add:kPrinterCMD_HorizTab];
    }
    return self;
}

- (NSData *)formattedData
{
    return _commands;
}

- (void)add:(NSString *)text
{
    [_commands appendData:[text dataUsingEncoding:NSASCIIStringEncoding]];
}

#pragma mark - Commands
- (void)tab
{
    [self add:kPrinterCMD_Tab];
}

- (void)newline
{
    [self add:kPrinterCMD_Newline];
}

- (void)dashedNewLine
{
    [self add:@"\r\n------------------------------------------------\r\n"];
}

#pragma mark - Text Formatting
- (void)bold:(NSString *)text next:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_StartBold];
    [self add:text];
    [self add:kPrinterCMD_EndBold];
    
    if(block) {
        block(text);
    }
}

- (void)underline:(NSString *)text next:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_StartUnderline];
    [self add:text];
    [self add:kPrinterCMD_EndUnderline];
    
    if(block) {
        block(text);
    }
}

- (void)upperline:(NSString *)text next:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_StartUpperline];
    [self add:text];
    [self add:kPrinterCMD_EndUpperline];
    
    if(block) {
        block(text);
    }
}

- (void)large:(NSString *)text next:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_StartDoubleHW];
    [self add:text];
    [self add:kPrinterCMD_EndDoubleHW];
    
    if(block) {
        block(text);
    }
}

- (void)invertColor:(NSString *)text next:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_StartInvertColor];
    [self add:text];
    [self add:kPrinterCMD_EndInvertColor];
    
    if(block) {
        block(text);
    }
}


#pragma mark - Text Alignment
- (void)alignLeft:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_AlignLeft];
}

- (void)alignRight:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_AlignRight];
}

- (void)alignCenter:(PrintTextFormatterBlock)block
{
    [self add:kPrinterCMD_AlignCenter];
}


#pragma mark - Barcodes
- (void)barcode:(NSString *)text type:(PrinterBarcodeType)type
{
    [self add:kPrinterCMD_StartBarcode];
    //[self add:text];
    //[self add:kPrinterCMD_EndBarcode];
}

@end


/*
 
 [formatter bold:text next:^{
    [formatter italicize:text next:nil];
 }];
 
 [formatter bold:(text, ^{
    [formatter italicize:(text, nil);
 }];
 
 
 */

//
//  PrintTextFormatter.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintCommands.h"

typedef NSString *(^PrintTextFormatterBlock)(NSString *text);

@interface PrintTextFormatter : NSObject

@property (nonatomic, readonly) NSData *formattedData;

+ (PrintTextFormatter *)formatter;

// Add a manual command
- (void)add:(NSString *)command;

// Commands
- (void)tab;
- (void)newline;
- (void)dashedNewLine;

// Text Formatting
- (void)bold:(NSString *)text next:(PrintTextFormatterBlock)block;
- (void)underline:(NSString *)text next:(PrintTextFormatterBlock)block;
- (void)upperline:(NSString *)text next:(PrintTextFormatterBlock)block;
- (void)large:(NSString *)text next:(PrintTextFormatterBlock)block;
- (void)invertColor:(NSString *)text next:(PrintTextFormatterBlock)block;

// Text alignment
- (void)alignLeft:(PrintTextFormatterBlock)block;
- (void)alignRight:(PrintTextFormatterBlock)block;
- (void)alignCenter:(PrintTextFormatterBlock)block;

// Barcode
- (void)barcode:(NSString *)text type:(PrinterBarcodeType)type;

@end

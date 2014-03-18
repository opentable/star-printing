//
//  PrintParser.m
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import "PrintParser.h"
#import "PrintTextFormatter.h"
#import "PrintCommands.h"

typedef enum PrintFormatElementType
{
    PrintFormatElementTypeText,
    PrintFormatElementTypeBold,
    PrintFormatElementTypeUnderline,
    PrintFormatElementTypeUpperline,
    PrintFormatElementTypeDashedline,
    PrintFormatElementTypeNewline,
    PrintFormatElementTypeTab,
    PrintFormatElementTypeLarge,
    PrintFormatElementTypeInvertColor,
    PrintFormatElementTypeUnknown,
    PrintFormatElementTypeAlignCenter,
    PrintFormatElementTypeAlignLeft,
    PrintFormatElementTypeAlignRight,
    PrintFormatElementTypeBarcode
} PrintFormatElementType;

@interface PrintParser ()

@property (nonatomic, strong) PrintTextFormatter *formatter;
@property (nonatomic, assign) PrintFormatElementType currentElementType;

- (NSArray *)elementNamesForFormatterType:(PrintFormatElementType)type;
- (PrintFormatElementType)elementTypeForName:(NSString *)name;

@end

@implementation PrintParser

- (NSData *)parse:(NSData *)data
{
    self.formatter = [PrintTextFormatter formatter];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    
    return _formatter.formattedData;
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    PrintFormatElementType elementType =
    self.currentElementType = [self elementTypeForName:elementName];
        
    switch (elementType) {
        case PrintFormatElementTypeNewline:
            [_formatter newline];
            break;
        case PrintFormatElementTypeDashedline:
            [_formatter dashedNewLine];
            break;
        case PrintFormatElementTypeTab:
            [_formatter tab];
            break;
        case PrintFormatElementTypeBold:
            [_formatter add:kPrinterCMD_StartBold];
            break;
        case PrintFormatElementTypeInvertColor:
            [_formatter add:kPrinterCMD_StartInvertColor];
            break;
        case PrintFormatElementTypeLarge:
            [_formatter add:kPrinterCMD_StartDoubleHW];
            break;
        case PrintFormatElementTypeUnderline:
            [_formatter add:kPrinterCMD_StartUnderline];
            break;
        case PrintFormatElementTypeUpperline:
            [_formatter add:kPrinterCMD_StartUpperline];
            break;
        case PrintFormatElementTypeAlignCenter:
            [_formatter add:kPrinterCMD_AlignCenter];
            break;
        case PrintFormatElementTypeAlignLeft:
            [_formatter add:kPrinterCMD_AlignLeft];
            break;
        case PrintFormatElementTypeAlignRight:
            [_formatter add:kPrinterCMD_AlignRight];
            break;
        case PrintFormatElementTypeBarcode:
            [_formatter add:kPrinterCMD_StartBarcode];
            break;
        default:
            break;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    PrintFormatElementType elementType = [self elementTypeForName:elementName];
    
    switch (elementType) {
        case PrintFormatElementTypeBold:
            [_formatter add:kPrinterCMD_EndBold];
            break;
        case PrintFormatElementTypeInvertColor:
            [_formatter add:kPrinterCMD_EndInvertColor];
            break;
        case PrintFormatElementTypeLarge:
            [_formatter add:kPrinterCMD_EndDoubleHW];
            break;
        case PrintFormatElementTypeUnderline:
            [_formatter add:kPrinterCMD_EndUnderline];
            break;
        case PrintFormatElementTypeUpperline:
            [_formatter add:kPrinterCMD_EndUpperline];
            break;            
        default:
            break;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
        
        NSMutableString *text = [NSMutableString stringWithString:string];
        [text replaceOccurrencesOfString:@"\\t" withString:kPrinterCMD_Tab options:0 range:NSMakeRange(0, [string length])];
        [text replaceOccurrencesOfString:@"\\n" withString:kPrinterCMD_Newline options:0 range:NSMakeRange(0, [text length])];
        
        if(_currentElementType == PrintFormatElementTypeBarcode) {
            [_formatter barcode:text type:PrinterBarcodeTypeCode128];
        } else {
            [_formatter add:text];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Parser Error: %@",parseError);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"Parser Validation Error: %@",validationError);
}

#pragma mark - Helpers

- (NSArray *)elementNamesForFormatterType:(PrintFormatElementType)type
{
    switch (type) {
        case PrintFormatElementTypeText:
            return @[@"text", @"t"];
            break;
        case PrintFormatElementTypeBold:
            return @[@"bold", @"b"];
            break;
        case PrintFormatElementTypeUnderline:
            return @[@"underline", @"ul"];
            break;
        case PrintFormatElementTypeUpperline:
            return @[@"upperline", @"upl"];;
            break;
        case PrintFormatElementTypeDashedline:
            return @[@"dashednewline", @"dnl", @"dl"];
            break;
        case PrintFormatElementTypeTab:
            return @[@"tab", @"tb"];
            break;
        case PrintFormatElementTypeNewline:
            return @[@"newline", @"nl"];
            break;
        case PrintFormatElementTypeLarge:
            return @[@"large", @"l"];
            break;
        case PrintFormatElementTypeInvertColor:
            return @[@"invertcolor", @"ic"];
            break;
        case PrintFormatElementTypeAlignCenter:
            return @[@"center", @"c"];
            break;
        case PrintFormatElementTypeAlignLeft:
            return @[@"left", @"l"];
            break;
        case PrintFormatElementTypeAlignRight:
            return @[@"right", @"r"];
            break;
        case PrintFormatElementTypeBarcode:
            return @[@"barcode", @"bc"];
            break;
        default:
            return nil;
            break;
    }
}

- (PrintFormatElementType)elementTypeForName:(NSString *)name
{
    int elements[12] = { PrintFormatElementTypeBold,
                        PrintFormatElementTypeTab,
                        PrintFormatElementTypeNewline,
                        PrintFormatElementTypeAlignCenter,
                        PrintFormatElementTypeAlignLeft,
                        PrintFormatElementTypeAlignRight,
                        PrintFormatElementTypeUnderline,
                        PrintFormatElementTypeUpperline,
                        PrintFormatElementTypeDashedline,
                        PrintFormatElementTypeLarge,
                        PrintFormatElementTypeInvertColor,
                        PrintFormatElementTypeBarcode
    };
    
    PrintFormatElementType type = PrintFormatElementTypeUnknown;
    
    for(int x = 0; x < sizeof(elements) / sizeof(int); x++) {
        PrintFormatElementType et = elements[x];
        NSArray *strings = [self elementNamesForFormatterType:et];
        
        if([strings containsObject:[name lowercaseString]]) {
            type = et;
            break;
        }
    }
    
    return type;
}

@end

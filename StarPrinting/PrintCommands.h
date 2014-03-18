//
//  PrinterCommands.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.

// TODO
typedef enum PrinterBarcodeType
{
    PrinterBarcodeTypeUPCE,
    PrinterBarcodeTypeUPCA,
    PrinterBarcodeTypeEAN8,
    PrinterBarcodeTypeEAN13,
    PrinterBarcodeTypeCode39,
    PrinterBarcodeTypeITF,
    PrinterBarcodeTypeCode128,
    PrinterBarcodeTypeCode93,
    PrinterBarcodeTypeNW7
} PrinterBarcodeType;

#define kPrinterCMD_Tab                 @"\x09"
#define kPrinterCMD_Newline             @"\x0A"

// Alignment
#define kPrinterCMD_AlignCenter         @"\x1b\x1d\x61\x01"
#define kPrinterCMD_AlignLeft           @"\x1b\x1d\x61\x00"
#define kPrinterCMD_AlignRight          @"\x1b\x1d\x61\x02"
#define kPrinterCMD_HorizTab            @"\x1b\x44\x02\x10\x22\x00"


// Text Formatting
#define kPrinterCMD_StartBold           @"\x1b\x45"
#define kPrinterCMD_EndBold             @"\x1b\x46"
#define kPrinterCMD_StartUnderline      @"\x1b\x2d\x01"
#define kPrinterCMD_EndUnderline        @"\x1b\x2d\x00"
#define kPrinterCMD_StartUpperline      @"\x1b\x5f\x01"
#define kPrinterCMD_EndUpperline        @"\x1b\x5f\x00"

#define kPrinterCMD_StartDoubleHW       @"\x1b\x69\x01\x01"
#define kPrinterCMD_EndDoubleHW         @"\x1b\x69\x00\x00"

#define kPrinterCMD_StartInvertColor    @"\x1b\x34"
#define kPrinterCMD_EndInvertColor      @"\x1b\x35"


// Cutting
#define kPrinterCMD_CutFull             @"\x1b\x64\x02"
#define kPrinterCMD_CutPartial          @"\x1b\x64\x03"


// Barcode
#define kPrinterCMD_StartBarcode        @"\x1b\x62\x06\x02\x02\x20" "12ab34cd56\x1e\r\n"
#define kPrinterCMD_EndBarcode          @"\x1e"
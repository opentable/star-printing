//
//  FakeSMPort.m
//  StarPrintingExample
//
//  Created by Matthew Newberry on 2/19/14.
//  OpenTable
//

#import "FakeSMPort.h"
#import "FakePrinterManager.h"
#import <objc/runtime.h>

static inline void SwizzleClassMethod(Class c, SEL orig, SEL new) {
    
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    
    c = object_getClass((id)c);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

#define kWaitTimeout    10.f

@interface Printer (Fake)

@end

@implementation Printer (Fake)

+ (Class)portClassMine
{
    return [FakeSMPort class];
}

@end

@interface FakeSMPort ()

@property (nonatomic, assign) BOOL isOffline;

@end

@implementation FakeSMPort

static int printerCount = 1;

+ (void)setup
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SwizzleClassMethod([Printer class], @selector(portClass), @selector(portClassMine));
    });
}

#pragma mark - Fake Printer Count
+ (void)addSecondPrinter
{
    printerCount = 2;
}

+ (void)removeSecondPrinter
{
    printerCount = 1;
}

+ (void)removeAllPrinters
{
    printerCount = 0;
}

+ (void)addFirstPrinter
{
    printerCount = 1;
}

#pragma mark - Methods

+ (PortInfo *)fakePortInfo
{
    PortInfo *info = [[PortInfo alloc] initWithPortName:@"**TEST PRINTER**" macAddress:@" 01:11:11:11:11:aa" modelName:@"Test Printer Co."];
    
    return info;
}

+ (PortInfo *)fakePortInfo2
{
    PortInfo *info = [[PortInfo alloc] initWithPortName:@"**TEST PRINTER 2**" macAddress:@" 02:22:22:22:22:aa" modelName:@"Test Printer Co. 2"];
    
    return info;
}

+ (NSArray *)searchPrinter
{
    NSArray *results;
    
    if(printerCount == 0) {
        results = @[];
    }
    
    if(printerCount == 1) {
        PortInfo *info = [self fakePortInfo];
        results = @[info];
    }
    
    if(printerCount == 2) {
        results = @[[self fakePortInfo], [self fakePortInfo2]];
    }
    
    return results;
}

+ (FakeSMPort *)getPort:(NSString *)portName :(NSString *)portSettings :(u_int32_t)ioTimeoutMillis
{
    FakeSMPort *port = [[FakeSMPort alloc] init];
    port->m_portName = portName;
    port->m_portSettings = portSettings;
    port->m_ioTimeoutMillis = ioTimeoutMillis;
    port.status = [[FakePrinterManager sharedInstance] statusForPortName:portName];
    
    if (port.status != PrinterStatusConnected && port.status != PrinterStatusConnecting && port.status != PrinterStatusDisconnected) {
        port.isOffline = YES;
    } else {
        port.isOffline = NO;
    }
    
    return port;
}

+ (void)releasePort: (FakeSMPort *) port
{
    
}

- (u_int32_t)writePort:(u_int8_t const *)writeBuffer :(u_int32_t)offSet :(u_int32_t)size
{
    u_int32_t result = size;
    return result;
}

- (void)getParsedStatus:(void *)starPrinterStatus :(u_int32_t)level
{
    StarPrinterStatus_2 *status = starPrinterStatus;
    [self fakeStatusWithStatus:status];
    
    if(_isOffline) {
        status->offline = SM_TRUE;
    } else {
        status->offline = SM_FALSE;
    }
    
    if(_status == PrinterStatusConnectionError || _status == PrinterStatusLostConnectionError || _status == PrinterStatusPrintError || _status == PrinterStatusUnknownError) {
        status->coverOpen = SM_FALSE;
        status->receiptPaperEmpty = SM_FALSE;
        status->receiptPaperNearEmptyInner = SM_FALSE;
    }
    
    if(_status == PrinterStatusCoverOpen) {
        status->coverOpen = SM_TRUE;
    } else {
        status->coverOpen = SM_FALSE;
    }
    
    if(_status == PrinterStatusOutOfPaper) {
        status->receiptPaperEmpty = SM_TRUE;
    } else {
        status->receiptPaperEmpty = SM_FALSE;
    }
    
    if(_status == PrinterStatusLowPaper) {
        status->receiptPaperNearEmptyInner = SM_TRUE;
    } else {
        status->receiptPaperNearEmptyInner = SM_FALSE;
    }
}

- (void)fakeStatusWithStatus:(StarPrinterStatus_2 *)status
{
    status->offline =
    status->coverOpen =
    status->compulsionSwitch =
    status->overTemp =
    status->unrecoverableError =
    status->cutterError =
    status->mechError =
    status->headThermistorError =
    status->receiveBufferOverflow =
    status->pageModeCmdError =
    status->blackMarkError =
    status->presenterPaperJamError =
    status->headUpError =
    status->voltageError =
    status->receiptBlackMarkDetection =
    status->receiptPaperEmpty =
    status->receiptPaperNearEmptyInner =
    status->receiptPaperNearEmptyOuter =
    status->presenterPaperPresent =
    status->peelerPaperPresent =
    status->stackerFull =
    status->slipTOF =
    status->slipCOF =
    status->slipBOF =
    status->validationPaperPresent =
    status->slipPaperPresent =
    status->etbAvailable = SM_FALSE;
}

@end

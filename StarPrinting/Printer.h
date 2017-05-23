//
//  Printer.h
//  StarPrinting
//
//  Created by Matthew Newberry on 4/10/13.
//  OpenTable

#import <Foundation/Foundation.h>
#import <StarIO/SMPort.h>
#import "PrintData.h"

#define kConnectedPrinterKey    @"ConnectedPrinterKey"

typedef enum PrinterStatus {
    PrinterStatusDisconnected,
    PrinterStatusConnecting,
    PrinterStatusConnected,
    PrinterStatusLowPaper,
    PrinterStatusCoverOpen,
    PrinterStatusOutOfPaper,
    PrinterStatusConnectionError,
    PrinterStatusLostConnectionError,
    PrinterStatusPrintError,
    PrinterStatusUnknownError,
    PrinterStatusIncompatible,
    PrinterStatusNoStatus
} PrinterStatus;

typedef void(^PrinterResultBlock)(BOOL success);
typedef void(^PrinterSearchBlock)(NSArray *found);

@class Printer;
@protocol PrinterDelegate <NSObject>

@required
- (void)printer:(Printer *)printer didChangeStatus:(PrinterStatus)status previousStatus:(PrinterStatus)previousStatus;

@end

@class PortInfo, Printable;
@interface Printer : NSObject

@property (nonatomic, weak) id<PrinterDelegate> delegate;
@property (nonatomic, readwrite) PrinterStatus status;
@property (nonatomic, strong) SMPort *port;

@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSString *portName;
@property (nonatomic, strong) NSString *macAddress;
@property (nonatomic, strong) NSString *friendlyName;

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) BOOL isReadyToPrint;
@property (nonatomic, readonly) BOOL hasError;
@property (nonatomic, readonly) BOOL isOffline;
@property (nonatomic, readonly) BOOL isOnlineWithError;
@property (nonatomic, readonly) BOOL isCompatible;

+ (Printer *)printerFromPort:(PortInfo *)port;
+ (Printer *)connectedPrinter;
+ (void)search:(PrinterSearchBlock)block;
+ (Class)portClass;
+ (NSString *)stringForStatus:(PrinterStatus)status;

+ (void)enableDebugLogging;
+ (void)disableDebugLogging;
+ (void)enableHeartbeat;
+ (void)disableHeartbeat;

- (void)connect:(PrinterResultBlock)result;
- (void)disconnect;
- (void)printTest;
- (void)openCashDrawer;

// Should only be called by unit tests
@property (nonatomic, strong) NSMutableArray *jobs;
@property (nonatomic, strong) NSOperationQueue *queue;
- (void)startHeartbeat;
- (void)stopHeartbeat;

// This should usually not be called directly, rather objects should
// conform to the `Printable` protocol
- (void)print:(PrintData *)data;

@end

//
//  Printer.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/10/13.

#import <Foundation/Foundation.h>
#import <StarIO/SMPort.h>

#define kConnectedPrinterKey    @"ConnectedPrinterKey"

typedef enum PrinterStatus
{
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
    PrinterStatusNoStatus
} PrinterStatus;

typedef void(^PrinterResultBlock)(BOOL success);
typedef void(^PrinterSearchBlock)(NSArray *found);

@class Printer;
@protocol PrinterDelegate <NSObject>

@required
- (void)printer:(Printer *)printer didChangeStatus:(PrinterStatus)status;

@end

@class PortInfo, Printable;
@interface Printer : NSObject

@property (nonatomic, assign) BOOL debug;

@property (nonatomic, strong) NSMutableArray *jobs;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, weak) id<PrinterDelegate> delegate;
@property (nonatomic, readwrite) PrinterStatus status;
@property (nonatomic, strong) SMPort *port;

@property (nonatomic, strong) NSString *modelName;
@property (nonatomic, strong) NSString *portName;
@property (nonatomic, strong) NSString *macAddress;
@property (nonatomic, strong) NSString *friendlyName;

// Helper method
// Returns `friendlyName` if it exists, else `modelName`
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, assign) BOOL isReadyToPrint;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, assign) BOOL isOffline;
@property (nonatomic, assign) BOOL isOnlineWithError;

+ (Printer *)printerFromPort:(PortInfo *)port;
+ (Printer *)connectedPrinter;
+ (void)search:(PrinterSearchBlock)block;
+ (Class)portClass;

- (void)connect:(PrinterResultBlock)result;
- (void)disconnect;
- (void)printTest;

// Only to be used by unit tests
- (void)startHeartbeat;
- (void)stopHeartbeat;

// This should usually not be called directly, rather objects should
// conform to the `Printable` protocol
- (void)print:(NSData *)data;

// Convience methods
+ (NSString *)stringForStatus:(PrinterStatus)status;

@end

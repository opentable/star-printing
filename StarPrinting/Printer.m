//
//  Printer.m
//  StarPrinting
//
//  Created by Matthew Newberry on 4/10/13.
//  OpenTable

#import "Printer.h"
#import "PrintCommands.h"
#import "PrintParser.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <StarIO/Port.h>
#import <StarIO_Extension/StarIoExt.h>
#import <objc/runtime.h>

#define DEBUG_PREFIX            @"Printer:"

#define kHeartbeatInterval      5
#define kJobRetryInterval       2.f
#define kMaxOpenPortRetries     5

#define PORT_CLASS              [[self class] portClass]

static int ddLogLevel = DDLogLevelWarning;

typedef void(^PrinterOperationBlock)(void);
typedef void(^PrinterJobBlock)(BOOL portConnected);

@interface Printer ()

@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, assign) PrinterStatus previousOnlineStatus;
@property (nonatomic, readonly) uint32_t heartbeatInterval;

- (BOOL)performCompatibilityCheck;

@end

static Printer *connectedPrinter;

static char const * const PrintJobTag = "PrintJobTag";
static char const * const HeartbeatTag = "HeartbeatTag";
static char const * const ConnectJobTag = "ConnectJobTag";

static BOOL heartbeatEnabled = YES;

@implementation Printer

#pragma mark - Class Methods

+ (Printer *)printerFromPort:(PortInfo *)port {
    Printer *printer = [[Printer alloc] init];
    printer.modelName = port.modelName;
    printer.portName = port.portName;
    printer.macAddress = port.macAddress;

    [printer initialize];

    return printer;
}

+ (Printer *)connectedPrinter {
    if (connectedPrinter) return connectedPrinter;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kConnectedPrinterKey]) {
        NSData *encoded = [defaults objectForKey:kConnectedPrinterKey];
        connectedPrinter = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
        return connectedPrinter;
    }

    return nil;
}

+ (void)search:(PrinterSearchBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *found = [PORT_CLASS searchPrinter];
        NSMutableArray *printers = [NSMutableArray arrayWithCapacity:[found count]];

        for(PortInfo *p in found) {
            Printer *printer = [Printer printerFromPort:p];
            [printers addObject:printer];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            block(printers);
        });
    });
}

+ (Class)portClass {
    return [SMPort class];
}

+ (NSString *)stringForStatus:(PrinterStatus)status {
    switch (status) {
        case PrinterStatusConnected:
            return NSLocalizedString(@"Connected", @"Connected");

        case PrinterStatusConnecting:
            return NSLocalizedString(@"Connecting", @"Connecting");

        case PrinterStatusDisconnected:
            return NSLocalizedString(@"Disconnected", @"Disconnected");

        case PrinterStatusLowPaper:
            return NSLocalizedString(@"Low Paper", @"Low Paper");

        case PrinterStatusCoverOpen:
            return NSLocalizedString(@"Cover Open", @"Cover Open");

        case PrinterStatusOutOfPaper:
            return NSLocalizedString(@"Out of Paper", @"Out of Paper");

        case PrinterStatusConnectionError:
            return NSLocalizedString(@"Connection Error", @"Connection Error");

        case PrinterStatusLostConnectionError:
            return NSLocalizedString(@"Lost Connection", @"Lost Connection");

        case PrinterStatusPrintError:
            return NSLocalizedString(@"Print Error", @"Print Error");

        case PrinterStatusIncompatible:
            return NSLocalizedString(@"Incompatible Printer", @"Incompatible Printer");

        case PrinterStatusUnknownError:
        default:
            return NSLocalizedString(@"Unknown Error", @"Unknown Error");
    }
}

+ (void)enableDebugLogging {
    ddLogLevel = DDLogLevelDebug;
}

+ (void)disableDebugLogging {
    ddLogLevel = DDLogLevelWarning;
}

+ (void)disableHeartbeat {
    heartbeatEnabled = NO;
    [connectedPrinter stopHeartbeat];
}

+ (void)enableHeartbeat {
    heartbeatEnabled = YES;
    [connectedPrinter startHeartbeat];
}

#pragma mark - Initialization & Coding

- (void)initialize {
    self.jobs = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.previousOnlineStatus = PrinterStatusDisconnected;

    [self performCompatibilityCheck];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.modelName forKey:@"modelName"];
    [encoder encodeObject:self.portName forKey:@"portName"];
    [encoder encodeObject:self.macAddress forKey:@"macAddress"];
    [encoder encodeObject:self.friendlyName forKey:@"friendlyName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.modelName = [aDecoder decodeObjectForKey:@"modelName"];
        self.portName = [aDecoder decodeObjectForKey:@"portName"];
        self.macAddress = [aDecoder decodeObjectForKey:@"macAddress"];
        self.friendlyName = [aDecoder decodeObjectForKey:@"friendlyName"];
        [self initialize];
    }
    return self;
}

#pragma mark - Port Handling

- (BOOL)openPort {
    BOOL error = NO;

    @try {
        self.port = [PORT_CLASS getPort:self.portName :@"" :10000];
        if (!self.port) {
            error = YES;
        }
    } @catch (NSException *exception) {
        self.status = PrinterStatusUnknownError;
        error = YES;
    }

    return !error;
}

- (void)releasePort {
    if (self.port) {
        [PORT_CLASS releasePort:self.port];
        self.port = nil;
    }
}


#pragma mark - Job Handling

- (void)addJob:(PrinterJobBlock)job {
    if ([self isHeartbeatJob:job] && [self.jobs count] > 0) return;

    [self.jobs addObject:job];
    [self printJobCount:@"Adding job"];

    if ([self.jobs count] == 1 || self.queue.operationCount == 0) {
        [self runNext];
    }
}

- (void)runNext {
    PrinterOperationBlock block = ^{
        if ([self.jobs count] == 0) return;

        PrinterJobBlock job = self.jobs[0];
        BOOL portConnected = NO;
        int openPortRetries = arc4random_uniform(kMaxOpenPortRetries) + 1;

        for (int i = 0; i < openPortRetries; i++) {
            portConnected = [self openPort];
            if (portConnected) break;
            [self log:@"Retrying to open port!"];
            usleep(1000 * (arc4random_uniform(300) + 300)); // 300-600ms
        }

        if (!portConnected) {
            // Printer is offline
            if (self.status != PrinterStatusUnknownError) {
                if ([self isConnectJob:job]) {
                    self.status = PrinterStatusConnectionError;
                } else {
                    self.status = PrinterStatusLostConnectionError;
                }
            }
        }

        @try {
            StarPrinterStatus_2 beginStatus;
            [self.port beginCheckedBlock:&beginStatus :2];
            [self updateStatus:beginStatus];

            job(portConnected);

            StarPrinterStatus_2 endStatus;
            [self.port endCheckedBlock:&endStatus :2];
            [self updateStatus:endStatus];
        } @catch (PortException *exception) {
            [self log:@"Received PortException in job"];
        } @finally {
            [self releasePort];
        }
    };

    [self.queue addOperationWithBlock:block];
}

- (void)jobWasSuccessful {
    if (self.status == PrinterStatusDisconnected) return;

    [self _removeJob];
    [self printJobCount:@"SUCCESS, Removing job"];
    [self runNext];
}

- (void)jobFailedRetry:(BOOL)retry {
    if (!retry) {
        [self _removeJob];
        [self printJobCount:@"FAILURE, Removing job"];
    } else {
        double delayInSeconds = kJobRetryInterval;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (self.status == PrinterStatusDisconnected) return;

            if ([self.jobs count] == 0) return;
            [self log:@"***** RETRYING JOB ******"];

            PrinterJobBlock job = self.jobs[0];
            [self _removeJob];
            [self.jobs addObject:job];

            [self runNext];
        });
    }
}

#pragma mark - Connection

- (void)connect:(PrinterResultBlock)result {
    [self log:@"Attempting to connect"];

    if (connectedPrinter) {
        connectedPrinter.delegate = nil;
        [connectedPrinter disconnect];
    }
    connectedPrinter = self;
    self.status = PrinterStatusConnecting;

    PrinterJobBlock connectJob = ^(BOOL portConnected) {
        if (!portConnected) {
            [self jobFailedRetry:YES];
            [self log:@"Failed to connect"];
        } else {
            [self establishConnection];
            [self jobWasSuccessful];
            [self log:@"Successfully connected"];
        }

        if (result) {
            result(portConnected);
        }
    };

    objc_setAssociatedObject(connectJob, ConnectJobTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addJob:connectJob];
}

- (void)establishConnection {
    if (!self.isOnlineWithError) {
        self.status = PrinterStatusConnected;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self];
    [defaults setObject:encoded forKey:kConnectedPrinterKey];
    [defaults synchronize];

    [self startHeartbeat];
}

- (void)disconnect {
    self.status = PrinterStatusDisconnected;
    connectedPrinter = nil;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kConnectedPrinterKey];

    [self.jobs removeAllObjects];
    [self.queue cancelAllOperations];
    [self stopHeartbeat];
}

#pragma mark - Cash Drawer

- (void)openCashDrawer {
    [self log:@"Queued an open cash drawer job"];

    PrinterJobBlock printJob = ^(BOOL portConnected) {
        BOOL error = !portConnected || !self.isReadyToPrint;

        if (!error) {
            unsigned char commandCode = 0x07; // Open Cash Drawer Command

            if (![self printChit:[NSData dataWithBytes:&commandCode length:1]]) {
                self.status = PrinterStatusPrintError;
                error = YES;
            }
        }

        if (error) {
            [self log:@"Cash drawer job unsuccessful"];
            [self jobFailedRetry:YES];
        } else {
            [self log:@"Cash drawer job successfully finished"];
            [self jobWasSuccessful];
        }
    };

    objc_setAssociatedObject(printJob, PrintJobTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addJob:printJob];
}

#pragma mark - Printing

- (void)printTest {
    if (![Printer connectedPrinter]) return;

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];

    NSDictionary *dictionary = @{
                           @"{{printerStatus}}" : [Printer stringForStatus:[Printer connectedPrinter].status],
                           @"{{printerName}}" : [Printer connectedPrinter].name
                           };

    PrintData *printData = [[PrintData alloc] initWithDictionary:dictionary atFilePath:filePath];

    [self print:printData];
}

- (void)print:(PrintData *)printData {
    [self log:@"Queued a print job"];

    PrinterJobBlock printJob = ^(BOOL portConnected) {
        BOOL error = !portConnected || !self.isReadyToPrint;

        if (!error) {
            ISCBBuilder *builder = [StarIoExt createCommandBuilder:StarIoExtEmulationStarGraphic];

            [builder beginDocument];

            if (printData.image != nil) {
                [builder appendBitmap:printData.image diffusion:NO];
            } else {
                NSDictionary *dictionary = printData.dictionary;
                NSString *filePath = printData.filePath;

                NSData *contents = [[NSFileManager defaultManager] contentsAtPath:filePath];
                NSMutableString *s = [[NSMutableString alloc] initWithData:contents encoding:NSUTF8StringEncoding];

                [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
                    [s replaceOccurrencesOfString:key withString:value options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
                }];

                PrintParser *parser = [[PrintParser alloc] init];
                [builder appendData:[parser parse:[s dataUsingEncoding:NSUTF8StringEncoding]]];
            }

            [builder appendCutPaper:SCBCutPaperActionPartialCutWithFeed];
            [builder endDocument];

            if (![self printChit:[builder.commands copy]]) {
                self.status = PrinterStatusPrintError;
                error = YES;
            }
        }

        if (error) {
            [self log:@"Print job unsuccessful"];
            [self jobFailedRetry:YES];
        } else {
            [self log:@"Print job successfully finished"];
            [self jobWasSuccessful];
        }
    };

    objc_setAssociatedObject(printJob, PrintJobTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addJob:printJob];
}

- (BOOL)printChit:(NSData *)data {
    [self log:@"Printing"];

    BOOL error = NO;
    BOOL completed = NO;

    NSMutableData *printData = [NSMutableData dataWithData:data];

    int commandSize = (int)[printData length];
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [printData getBytes:dataToSentToPrinter];

    do {
        @try {
            int totalAmountWritten = 0;
            while (totalAmountWritten < commandSize) {
                int remaining = commandSize - totalAmountWritten;

                int blockSize = (remaining > 1024) ? 1024 : remaining;

                int amountWritten = [self.port writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
                totalAmountWritten += amountWritten;
            }

            if (totalAmountWritten < commandSize) {
                error = YES;
            }
        }
        @catch (PortException *exception) {
            [self log:[exception description]];
            error = YES;
        }

        completed = YES;

        free(dataToSentToPrinter);

        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:self.heartbeatInterval]];
    } while (!completed);

    return !error;
}

#pragma mark - Heartbeat

- (uint32_t)heartbeatInterval {
    return arc4random_uniform(kHeartbeatInterval) + kHeartbeatInterval;
}

- (void)heartbeat {
    PrinterJobBlock heartbeatJob = ^(BOOL portConnected) {
        [self jobWasSuccessful];
        [self log:@"*** Heartbeat ***"];
    };

    objc_setAssociatedObject(heartbeatJob, HeartbeatTag, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [self addJob:heartbeatJob];
    [self scheduleHeartbeat];
}

- (void)scheduleHeartbeat {
    if (!heartbeatEnabled) {
        return;
    }

    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartbeatInterval
                                                           target:self
                                                         selector:@selector(heartbeat)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)startHeartbeat {
    if (!self.heartbeatTimer && heartbeatEnabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scheduleHeartbeat];
        });
    }
}

- (void)stopHeartbeat {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
}

#pragma mark - Status

- (void)updateStatus:(StarPrinterStatus_2)printerStatus {
    if (![self performCompatibilityCheck]) {
        return;
    }

    PrinterStatus status = PrinterStatusNoStatus;

    if (printerStatus.offline == SM_TRUE) {
        if (printerStatus.coverOpen == SM_TRUE) {
            status = PrinterStatusCoverOpen;
        } else if (printerStatus.receiptPaperEmpty == SM_TRUE) {
            status = PrinterStatusOutOfPaper;
        } else if (printerStatus.receiptPaperNearEmptyInner == SM_TRUE ||
                printerStatus.receiptPaperNearEmptyOuter == SM_TRUE) {
            status = PrinterStatusLowPaper;
        }
    }

    // CoverOpen, LowPaper, or OutOfPaper
    if (status != PrinterStatusNoStatus) {
        self.status = status;
        return;
    }

    // Printer did have error, but error is now resolved
    if (self.hasError) {
        self.status = self.previousOnlineStatus;
    }
}

- (void)setStatus:(PrinterStatus)status {
    if (self.status != status) {
        if (!self.isOffline && !self.hasError && self.status != PrinterStatusConnecting) {
            self.previousOnlineStatus = self.status;
        }

        _status = status;
        PrinterStatus previousStatus = self.previousOnlineStatus;

        if (_delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate printer:self didChangeStatus:status previousStatus:previousStatus];
            });
        }
    }
}

#pragma mark - Properties

- (NSString *)description {
    NSString *desc = [NSString stringWithFormat:@"<Printer: %p { name:%@ mac:%@ model:%@ portName:%@ status:%@}>", self, self.name, self.macAddress, self.modelName, self.portName, [Printer stringForStatus:self.status]];
    return desc;
}

- (NSString *)name {
    return self.friendlyName == nil ? self.modelName : self.friendlyName;
}

- (BOOL)isReadyToPrint {
    return self.status == PrinterStatusConnected || self.status == PrinterStatusLowPaper;
}

- (BOOL)hasError {
    return self.status != PrinterStatusConnected &&
    self.status != PrinterStatusConnecting &&
    self.status != PrinterStatusDisconnected;
}

- (BOOL)isOffline {
    return self.status == PrinterStatusConnectionError ||
    self.status == PrinterStatusLostConnectionError ||
    self.status == PrinterStatusUnknownError;
}

- (BOOL)isOnlineWithError {
    return self.hasError && !self.isOffline && self.status != PrinterStatusPrintError;
}

/*
 For future potential incompatible printers.
*/
- (BOOL)isCompatible {
    return YES;
}

- (BOOL)performCompatibilityCheck {
    BOOL compatible = [self isCompatible];
    if (!compatible) {
        self.status = PrinterStatusIncompatible;
    }

    return compatible;
}

#pragma mark - Helpers

- (void)log:(NSString *)message {
    DDLogDebug(@"%@", [NSString stringWithFormat:@"%@ %@ -> %@", DEBUG_PREFIX, self, message]);
}

- (void)printJobCount:(NSString *)message {
    [self log:[NSString stringWithFormat:@"%@ -> Job Count = %lu", message, (unsigned long)[self.jobs count]]];
}

- (BOOL)isConnectJob:(PrinterJobBlock)job {
    NSNumber *isConnectJob = objc_getAssociatedObject(job, ConnectJobTag);
    return [isConnectJob intValue] == 1;
}

- (BOOL)isPrintJob:(PrinterJobBlock)job {
    NSNumber *isPrintJob = objc_getAssociatedObject(job, PrintJobTag);
    return [isPrintJob intValue] == 1;
}

- (BOOL)isHeartbeatJob:(PrinterJobBlock)job {
    NSNumber *isHeartbeatJob = objc_getAssociatedObject(job, HeartbeatTag);
    return [isHeartbeatJob intValue] == 1;
}

#pragma mark -

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Printer class]]) {
        return NO;
    }

    return [[object macAddress] isEqualToString:self.macAddress];
}

#pragma mark - Private

- (void)_removeJob {
    if ([self.jobs count] > 0) {
        [self.jobs removeObjectAtIndex:0];
    }
}

@end

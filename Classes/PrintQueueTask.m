//
//  PrintQueueTask.m
//  Quickcue
//
//  Created by Will Loderhose on 1/30/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import "PrintQueueTask.h"
#import "Printer.h"

@implementation PrintQueueTask

- (id)initWithPrinter:(Printer *)printer
{
    self = [super init];
    
    if(self) {
        self.printer = printer;
    }
    
    return self;
}

//#pragma mark - Statuses
//- (BOOL)openPort
//{
//    self.printer.busy = YES;
//    BOOL error = NO;
//    
//    @try {
//        self.printer.port = [SMPort getPort:self.printer.portName :nil :10000];
//        if(!self.printer.port) {
//            error = YES;
//        }
//    } @catch (NSException *exception) {
//        error = YES;
//    }
//    
//    if(error) {
//        [self.printer setStatus:PrinterStatusConnectionError];
//    }
//    
//    return !error;
//}
//
//- (void)releasePort
//{
//    if(self.printer.port) {
//        [SMPort releasePort:self.printer.port];
//        self.printer.port = nil;
//    }
//    
//    self.printer.busy = NO;
//}
//
//- (void)perform:(PrinterOperationBlock)block
//{
//    if(![self openPort]){
//        [self releasePort];
//        block(NO);
//        return;
//    };
//    
//    // Sleep taken from StarIO SDK example, needs this delay to work after connection
//    usleep(1000 * 1000);
//    block(YES);
//    [self releasePort];
//}
//
//- (void)updateStatus
//{
//    if(self.printer.busy) return;
//    
//    [self perform:^(BOOL connected){
//        if(connected) {
//            PrinterStatus status = PrinterStatusConnected;
//            StarPrinterStatus_2 printerStatus;
//            [self.printer.port getParsedStatus:&printerStatus :2];
//            
//            if (printerStatus.offline == SM_TRUE){
//                if(printerStatus.coverOpen == SM_TRUE) {
//                    status = PrinterStatusCoverOpen;
//                } else if(printerStatus.receiptPaperEmpty == SM_TRUE){
//                    status = PrinterStatusOutOfPaper;
//                } else if(printerStatus.receiptPaperNearEmptyInner == SM_TRUE ||
//                         printerStatus.receiptPaperNearEmptyOuter == SM_TRUE) {
//                    status = PrinterStatusLowPaper;
//                }
//            }
//            
//            [self.printer setStatus:status];
//        }
//    }];
//    
//    NSLog(@"%@", [NSString stringWithFormat:@"%@ Heartbeat => %@", DEBUG_PREFIX, self]);
//}
//
//- (void)connect:(PrinterResultBlock)result
//{
//    self.printer.status = PrinterStatusConnecting;
//    
//    [self perform:^(BOOL connected){
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSData *encoded = [NSKeyedArchiver archivedDataWithRootObject:self];
//        [defaults setObject:encoded forKey:kConnectedPrinterKey];
//        [defaults synchronize];
//        
//        if(connected) {
//            self.printer.status = PrinterStatusConnected;
//            
//            self.printer.heartbeat = [NSTimer scheduledTimerWithTimeInterval:kHeartbeat
//                                                              target:self
//                                                            selector:@selector(updateStatus)
//                                                            userInfo:nil
//                                                             repeats:YES];
//        }
//        
//        if(result){
//            result(connected);
//        }
//    }];
//}
//
//- (void)connect
//{
//    [self connect:nil];
//}
//
//- (void)disconnect
//{
//    [self.printer setStatus:PrinterStatusDisconnected];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey:kConnectedPrinterKey];
//    
//    [self.printer.heartbeat invalidate];
//    self.printer.heartbeat = nil;
//}


@end

















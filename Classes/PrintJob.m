//
//  PrintJob.m
//  Quickcue
//
//  Created by Will Loderhose on 1/29/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import "PrintJob.h"
#import "PrintCommands.h"

#define DEBUG_PRINTING        1
#define DEBUG_PREFIX          @"Printer:"
#define kHeartbeat            2.f
#define DEFAULT_NAME          @"Anonymous Print Job"

@implementation PrintJob

- (id)initWithPrinter:(Printer *)printer printData:(NSData *)data
{
    self = [super initWithPrinter:printer];
    
    if(self) {
        self.data = data;
    }
    
    return self;
}
//
//- (void)main
//{
//    @autoreleasepool {
//        [self print:self.data];
//    }
//}
//
//- (void)print:(NSData *)data
//{
//    if(DEBUG_PRINTING) {
//        NSLog(@"%@", [NSString stringWithFormat:@"%@ %@ is printing", DEBUG_PREFIX, self]);
//    }
//    [self.printer perform:^(BOOL connected){
//        
//        BOOL error = NO;
//        BOOL completed = NO;
//        
//        // Add cut manually
//        NSMutableData *printData = [NSMutableData dataWithData:data];
//        [printData appendData:[kPrinterCMD_CutFull dataUsingEncoding:NSASCIIStringEncoding]];
//        
//        int commandSize = [printData length];
//        unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
//        [printData getBytes:dataToSentToPrinter];
//        
//        do {
//            @try {
//                int totalAmountWritten = 0;
//                while (totalAmountWritten < commandSize) {
//                    
//                    int remaining = commandSize - totalAmountWritten;
//                    
//                    int blockSize = (remaining > 1024) ? 1024 : remaining;
//                    
//                    int amountWritten = [self.printer.port writePort:dataToSentToPrinter :totalAmountWritten :blockSize];
//                    totalAmountWritten += amountWritten;
//                }
//                
//                usleep(1000 * 1000);
//                
//                if (totalAmountWritten < commandSize) {
//                    error = YES;
//                }
//            }
//            @catch (PortException *exception) {
//                NSLog(@"%@", exception);
//                error = YES;
//            }
//            
//            completed = YES;
//            free(dataToSentToPrinter);
//            
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:kHeartbeat]];
//        } while (!completed);
//        
//        if(error) {
//            self.printer.status = PrinterStatusPrintError;
//            [self setCompletionBlock:^{
//                [[NSOperationQueue currentQueue] setSuspended:YES];
//            }];
//        }
//        
//    }];
//}

@end

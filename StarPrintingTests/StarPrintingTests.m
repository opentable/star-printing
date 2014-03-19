//
//  PrinterTests.m
//  Quickcue
//
//  Created by Matthew Newberry on 2/20/14.
//  Copyright (c) 2014 quickcue. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "FakeSMPort.h"
#import "Printer.h"
#import "FakePrinterManager.h"
#import "SenAsyncTestCase.h"

#define kWaitTimeout    10.f

@interface StarPrintingTests : SenAsyncTestCase

@end

@implementation StarPrintingTests

+ (void)load
{
    [FakeSMPort setup];
}

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Tests

- (void)testPrinterStatusChanges
{
    Printer *printer = [Printer printerFromPort:[FakeSMPort fakePortInfo]];
    
    [self bringPrinterOnline:printer];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:kWaitTimeout];
    STAssertTrue(printer.status == PrinterStatusConnected, @"Failed to bring printer online");
    
    [self takePrinterOffline:printer];
    STAssertTrue(printer.status == PrinterStatusDisconnected, @"Failed to take printer offline");
    
    [self bringPrinterOnline:printer];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:kWaitTimeout];
    STAssertTrue(printer.status == PrinterStatusConnected, @"Failed to bring printer online");
    
    [self waitForTimeout:5.f];
    STAssertTrue(printer.status == PrinterStatusCoverOpen, [self wrongStatusForPrinter:printer withExpectedStatus:PrinterStatusCoverOpen]);
}

- (void)testPrint
{
    Printer *printer = [Printer printerFromPort:[FakeSMPort fakePortInfo]];
    
    // Test that there are no print jobs initially
    [self bringPrinterOnline:printer];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:kWaitTimeout];
    [printer stopHeartbeat];
    
    NSUInteger empty = 0;
    STAssertEquals([printer.jobs count], empty, [self wrongJobCountForPrinter:printer withExpectedCount:empty]);
    
    // Test printing one job
    [printer printTest];
    [self waitForTimeout:2.f];
    STAssertEquals([printer.jobs count], empty, [self wrongJobCountForPrinter:printer withExpectedCount:empty]);
    
    // Test taking printer offline, printing several jobs, and then bringing printer back online
    [self takePrinterOffline:printer];
    
    NSUInteger jobs = 5;
    for (int i = 0; i < jobs; i++) {
        [printer printTest];
    }
    
    [self waitForTimeout:2.f];
    STAssertEquals([printer.jobs count], jobs, [self wrongJobCountForPrinter:printer withExpectedCount:jobs]);
    
    [self bringPrinterOnline:printer];
    [printer stopHeartbeat];
    [self waitForStatus:SenAsyncTestCaseStatusSucceeded timeout:kWaitTimeout];
    STAssertEquals([printer.jobs count], empty, [self wrongJobCountForPrinter:printer withExpectedCount:empty]);
}

#pragma mark - Helpers

- (void)takePrinterOffline:(Printer *)printer
{
    [[FakePrinterManager sharedInstance] setStatus:PrinterStatusDisconnected forPrinter:printer];
    [printer disconnect];
}

- (void)bringPrinterOnline:(Printer *)printer
{
    [[FakePrinterManager sharedInstance] setStatus:PrinterStatusConnected forPrinter:printer];
    [printer connect:^(BOOL success) {
        [self notify:SenAsyncTestCaseStatusSucceeded];
    }];
}

- (void)openCover:(Printer *)printer
{
    [[FakePrinterManager sharedInstance] setStatus:PrinterStatusCoverOpen forPrinter:printer];
}

- (NSString *)wrongJobCountForPrinter:(Printer *)printer withExpectedCount:(int)expected
{
    return [NSString stringWithFormat:@"Currently: %i jobs in array => Expecting: %i jobs", [printer.jobs count], expected];
}

- (NSString *)wrongStatusForPrinter:(Printer *)printer withExpectedStatus:(PrinterStatus)status
{
    return [NSString stringWithFormat:@"Currently: %@ => Expecting: %@", [Printer stringForStatus:printer.status], [Printer stringForStatus:status]];
}

@end

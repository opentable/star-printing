//
//  NSObject+Printable.m
//  StarPrinting
//
//  Created by Matthew Newberry on 4/11/13.
//  OpenTable
//

#import "Printable.h"

@implementation NSObject (Printable)

- (void)print
{
    [self print:[Printer connectedPrinter]];
}

- (void)print:(Printer *)printer
{
    [printer print:[self performSelector:@selector(printedFormat)]];
}

@end

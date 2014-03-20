//
//  PrintParser.h
//  StarPrinting
//
//  Created by Matthew Newberry on 4/11/13.
//  OpenTable
//

#import <Foundation/Foundation.h>

@interface PrintParser : NSObject <NSXMLParserDelegate>

- (NSData *)parse:(NSData *)data;

@end

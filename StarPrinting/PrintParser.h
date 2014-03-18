//
//  PrintParser.h
//  Quickcue
//
//  Created by Matthew Newberry on 4/11/13.
//  Copyright (c) 2013 Quickcue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintParser : NSObject <NSXMLParserDelegate>

- (NSData *)parse:(NSData *)data;

@end

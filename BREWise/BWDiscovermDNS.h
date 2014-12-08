//
//  BWDiscovermDNS.h
//  BREWise
//
//  Created by Jackson Keating on 8/17/14.
//  Copyright (c) 2014 Brewise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#include <arpa/inet.h>

@interface BWDiscovermDNS : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (nonatomic, strong) NSString *ipAddress;
@property (nonatomic) NSUInteger port;
@property (nonatomic) BOOL didFind;

- (void)findBrewiseService;

@end

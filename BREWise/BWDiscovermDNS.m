//
//  BWDiscovermDNS.m
//  BREWise
//
//  Created by Jackson Keating on 8/17/14.
//  Copyright (c) 2014 Brewise. All rights reserved.
//

#import "BWDiscovermDNS.h"

@interface BWDiscovermDNS()

@property (strong,atomic) NSNetServiceBrowser *serviceBrowser;
@property (strong,atomic) NSMutableArray *services;

@end

@implementation BWDiscovermDNS

@synthesize ipAddress;
@synthesize port;

@synthesize serviceBrowser;
@synthesize services;

//*********************************************
//
// mDNS Discovery
//
// 1. An NSNetServiceBrowser object is initialized.  Delegate is self.
// 2. didFindService callback stores service in mutable array.
// 3. didFindService callback starts the resolve process. Resolve delegate is self.
// 4. netServiceDidResolveAddress callback updates IP address string and port number.
//
//*********************************************

- (void)findBrewiseService
{
    [self initServiceBrowser];
}

- (void)initServiceBrowser
{
    [self.serviceBrowser stop];
    
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
    [serviceBrowser searchForServicesOfType:@"_uart._tcp" inDomain:@"local"];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
    if(!moreComing)
    {
        if (!self.services) {
            self.services = [[NSMutableArray alloc] init];
        }
        [self.services addObject:aNetService];
        NSLog(@"Done adding.");
        NSLog(@"%@",[[self.services objectAtIndex:([self.services count] -1)] name]);
        [self resolveIPAddress:[self.services objectAtIndex:([self.services count] -1)]];
    }
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary *)errorDict
{
    NSNumber *error = [[NSNumber alloc] init];
    error = [errorDict objectForKey:NSNetServicesErrorCode];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The service browser did not search."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    NSLog(@"Search error");
    NSLog(@"%@", errorDict);
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
    [alert show];
    
    [serviceBrowser stop];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.services removeObject:aNetService];
    
    if(!moreComing)
    {
        NSLog(@"Done removing.");
    }
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"Started searching.");
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"Stopped searching.");
}

//*********************************************
//
//Resolve service
//
//*********************************************
-(void) resolveIPAddress:(NSNetService *)service {
    NSNetService *remoteService = service;
    remoteService.delegate = self;
    [remoteService resolveWithTimeout:5];
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService
{
    // Make sure [netService addresses] contains the
    // necessary connection information
    
    struct sockaddr *sa;
    struct sockaddr_in *ipv4;
    struct sockaddr_in6 *ipv6;
    NSData *addressData;
    NSString *addressLog;
    
    if ([self addressesComplete:[netService addresses]
                 forServiceType:[netService type]]) {
        NSLog(@"Service was resolved. Details: %@.%@.%@.  Port: %ld.  Address: %@.",
              [netService name], [netService type], [netService domain], [netService port], [netService addresses]);
        
        addressData = [[netService addresses] objectAtIndex:0];
        sa = (struct sockaddr*)[addressData bytes];
        
        switch( sa->sa_family ) {
            case AF_INET: {
                char dest[INET_ADDRSTRLEN];
                ipv4 = (struct sockaddr_in *) [addressData bytes];
                port = ntohs(ipv4->sin_port);
                ipAddress = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET, &ipv4->sin_addr, dest, sizeof dest)];
                addressLog = [NSString stringWithFormat: @"IP4: %@ Port: %ld", ipAddress, port];
            }   break;
                
            case AF_INET6: {
                char dest[INET6_ADDRSTRLEN];
                ipv6 = (struct sockaddr_in6 *) [addressData bytes];
                port = ntohs(ipv6->sin6_port);
                ipAddress = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET6, &ipv6->sin6_addr, dest, sizeof dest)];
                addressLog = [NSString stringWithFormat: @"IP6: %@ Port: %ld", ipAddress, port];
            }   break;
            default:
                addressLog=@"Unknown family";
                break;
        }
        
        NSLog(@"Client Address: %@",addressLog);
        
        [self.serviceBrowser stop];
    }
}

- (void)netService:(NSNetService *)netService
     didNotResolve:(NSDictionary *)errorDict
{
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode] withService:netService];
    [services removeObject:netService];
    [self.serviceBrowser stop];
}

// Verifies [netService addresses]
- (BOOL)addressesComplete:(NSArray *)addresses
           forServiceType:(NSString *)serviceType
{
    // Perform appropriate logic to ensure that [netService addresses]
    // contains the appropriate information to connect to the service
    return YES;
}

// Error handling code
- (void)handleError:(NSNumber *)error withService:(NSNetService *)service
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"The service did not resolve."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    NSLog(@"An error occurred with service %@.%@.%@, error code = %d",
          [service name], [service type], [service domain], [error intValue]);
    
    [alert show];
}

@end

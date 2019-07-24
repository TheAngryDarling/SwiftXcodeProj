//
//  MacXPCService.h
//  MacXPCService
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacXPCServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface MacXPCService : NSObject <MacXPCServiceProtocol>
@end

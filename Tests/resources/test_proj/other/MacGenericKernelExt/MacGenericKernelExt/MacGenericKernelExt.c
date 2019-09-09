//
//  MacGenericKernelExt.c
//  MacGenericKernelExt
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#include <mach/mach_types.h>

kern_return_t MacGenericKernelExt_start(kmod_info_t * ki, void *d);
kern_return_t MacGenericKernelExt_stop(kmod_info_t *ki, void *d);

kern_return_t MacGenericKernelExt_start(kmod_info_t * ki, void *d)
{
    return KERN_SUCCESS;
}

kern_return_t MacGenericKernelExt_stop(kmod_info_t *ki, void *d)
{
    return KERN_SUCCESS;
}

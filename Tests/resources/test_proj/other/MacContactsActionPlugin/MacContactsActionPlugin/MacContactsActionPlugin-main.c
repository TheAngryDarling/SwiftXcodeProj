//
//  MacContactsActionPlugin-main.c
//  MacContactsActionPlugin
//
//  Created by Tyler Anger on 2019-06-12.
//  Copyright © 2019 Tyler Anger. All rights reserved.
//

#include <AddressBook/ABAddressBookC.h>
#include <AddressBook/ABActionsC.h>
#include <CoreFoundation/CoreFoundation.h>

CFStringRef actionProperty(void);
CFStringRef actionTitle(ABPersonRef person, CFStringRef identifier);
Boolean actionEnabled(ABPersonRef person, CFStringRef identifier);
void actionSelected(ABPersonRef person, CFStringRef identifier);

ABActionCallbacks* ABActionRegisterCallbacks(void)
{
    ABActionCallbacks *callbacks;

    callbacks = malloc(sizeof(ABActionCallbacks));
    if (callbacks == NULL)
        return NULL;
    
    callbacks->version = 0;
    callbacks->property = actionProperty;
    callbacks->title = actionTitle;
    callbacks->enabled = actionEnabled;
    callbacks->selected = actionSelected;
    return callbacks;
}

CFStringRef actionProperty(void)
{
    return kABEmailProperty;
}

CFStringRef actionTitle(ABPersonRef person, CFStringRef identifier)
{
    return CFSTR("MacContactsActionPlugin");
}

Boolean actionEnabled(ABPersonRef person, CFStringRef identifier)
{
    return TRUE;
}

void actionSelected(ABPersonRef person, CFStringRef identifier)
{
   CFShow(CFSTR("I am the chosen one!\n"));
}

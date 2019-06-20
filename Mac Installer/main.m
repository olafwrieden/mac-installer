//
//  main.m
//  BYOD Mac Installer
//
//  Created by Olaf Wrieden on 28/10/17.
//  Copyright © 2017 Olaf Wrieden. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[]) {
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}

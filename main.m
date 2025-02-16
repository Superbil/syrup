//
// main.m
//
// Copyright (c) 2010-2011 Lukhnos D. Liu (lukhnos at openvanilla dot org)
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import <Cocoa/Cocoa.h>
#import "OVInputSourceHelper.h"

#define CONNECTION_NAME "org.sharpstudio.inputmethod.liu"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // register and enable the input source (along with all its input modes)
    if (argc > 1 && !strcmp(argv[1], "install")) {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
        TISInputSourceRef inputSource = [OVInputSourceHelper inputSourceForInputSourceID:bundleID];

        if (!inputSource) {
            NSLog(@"Registering input source %@ at %@.", bundleID, [bundleURL absoluteString]);
			BOOL status = [OVInputSourceHelper registerInputSource:bundleURL];
            
            if (!status) {
                NSLog(@"Fatal error: Cannot register input source %@ at %@.", bundleID, [bundleURL absoluteString]);
                [pool drain];
                return -1;                
            }
            
            inputSource = [OVInputSourceHelper inputSourceForInputSourceID:bundleID];
            if (!inputSource) {
                NSLog(@"Fatal error: Cannot find input source %@ after registration.", bundleID, [bundleURL absoluteString]);
                [pool drain];
                return -1;                
            }
        }
        
        if (inputSource && ![OVInputSourceHelper inputSourceEnabled:inputSource]) {							
            NSLog(@"Enabling input source %@ at %@.", bundleID, [bundleURL absoluteString]);
            BOOL status = [OVInputSourceHelper enableInputSource:inputSource];
            
            if (!status != noErr) {
                NSLog(@"Fatal error: Cannot enable input source %@.", bundleID);
                [pool drain];
                return -1;
            }
        }
        
        return 0;
    }
    
    
    NSString *mainNibName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSMainNibFile"];
    if (!mainNibName) {
        NSLog(@"Fatal error: NSMainNibFile key not defined in Info.plist.");
        [pool drain];        
        return -1;
    }
    
    NSString *connectionName = [NSString stringWithUTF8String:CONNECTION_NAME];
    if (!connectionName) {
        NSLog(@"Fatal error: InputMethodConnectionName key not defined in Info.plist.");
        [pool drain];        
        return -1;
    }    

    BOOL loadResult = [NSBundle loadNibNamed:mainNibName owner:[NSApplication sharedApplication]];
    if (!loadResult) {
        NSLog(@"Fatal error: Cannot load %@.", mainNibName);
        [pool drain];        
        return -1;        
    }
    
    IMKServer *server = [[IMKServer alloc] initWithName:connectionName bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
    if (!server) {
        NSLog(@"Fatal error: Cannot initialize input method server with connection %@.", connectionName);
        [pool drain];        
        return -1;    
    }

    [[NSApplication sharedApplication] run];
    [server release];    
    [pool drain];
    return 0;
}

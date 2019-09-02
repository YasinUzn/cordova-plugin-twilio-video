/********* TwilioVideo.m Cordova Plugin Implementation *******/

#import "TwilioVideoPlugin.h"

@implementation TwilioVideoPlugin

#pragma mark - Plugin Initialization
- (void)pluginInitialize
{
    [[TwilioVideoManager getInstance] setEventDelegate:self];
}

- (void)openRoom:(CDVInvokedUrlCommand*)command {
    self.listenerCallbackID = command.callbackId;
    NSArray *args = command.arguments;
    NSString* token = args[0];
    NSString* room = args[1];
    TwilioVideoConfig *config = [[TwilioVideoConfig alloc] init];
    if ([args count] > 2) {
        [config parse: command.arguments[2]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"TwilioVideo" bundle:nil];
        TwilioVideoViewController *vc = [sb instantiateViewControllerWithIdentifier:@"TwilioVideoViewController"];
        
        vc.config = config;

        vc.view.backgroundColor = [UIColor clearColor];
        vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
        [self.viewController presentViewController:vc animated:NO completion:^{
            [vc connectToRoom:room token:token];
        }];
    });

}

- (void)closeRoom:(CDVInvokedUrlCommand*)command {
    if ([[TwilioVideoManager getInstance] publishDisconnection]) {
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Twilio video is not running"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

#pragma mark - TwilioVideoEventProducerDelegate

- (void)onCallEvent:(NSString *)event with:(NSDictionary*)data {
    if (!self.listenerCallbackID) {
        NSLog(@"Listener callback unavailable.  event %@", event);
        return;
    }
    
    if (data != NULL) {
        NSLog(@"Event received %@ with data %@", event, data);
    } else {
        NSLog(@"Event received %@", event);
    }
    
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    [message setValue:event forKey:@"event"];
    [message setValue:data != NULL ? data : [NSNull null] forKey:@"data"];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [result setKeepCallbackAsBool:YES];
    
    [self.commandDelegate sendPluginResult:result callbackId:self.listenerCallbackID];
}

@end

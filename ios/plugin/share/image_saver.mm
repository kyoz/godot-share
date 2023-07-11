//
//  image_saver.m
//  share
//
//  Created by Kyoz on 11/07/2023.
//

#import <UIKit/UIKit.h>

#ifdef VERSION_4_0
#include "core/object/class_db.h"
#else
#include "core/class_db.h"
#endif

#include "image_saver.h"

@implementation ImageSaver

+ (void) saveImage: (const String &) path {
  NSString * imagePath = [NSString stringWithCString:path.utf8().get_data() encoding:NSUTF8StringEncoding];

  UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

+ (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
  if (error != NULL)
  {
      NSLog(@"Error during saving image: %@", error);
      UIAlertController * alert = [UIAlertController
                                   alertControllerWithTitle:@"Permission required"
                                   message:@"The app need Add Only permission to add image to your gallery?"
                                   preferredStyle:UIAlertControllerStyleAlert];
      
      
      UIAlertAction* yesButton = [UIAlertAction
                                  actionWithTitle:@"Yes"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
             options:[[NSDictionary alloc] init]
             completionHandler:^(BOOL success) {
            }];

      }];
      
      UIAlertAction* noButton = [UIAlertAction
                                 actionWithTitle:@"No"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
          // Do nothing
      }];
      
      [alert addAction:noButton];
      [alert addAction:yesButton];

      UIViewController *root_controller = [[UIApplication sharedApplication] delegate].window.rootViewController;
      [root_controller presentViewController:alert animated:YES completion:nil];
  }
}

@end

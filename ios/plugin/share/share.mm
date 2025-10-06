//
//  share.m
//  share
//
//  Created by Kyoz on 11/07/2023.
//

#ifdef VERSION_4_0
#include "core/object/class_db.h"
// #include "platform/ios/app_delegate.h"
#import <UIKit/UIKit.h>
#else
#include "core/class_db.h"
#include "platform/iphone/app_delegate.h"
#endif

#include "share.h"
#include "image_saver.h"

Share *Share::instance = NULL;

Share::Share() {
    instance = this;
    NSLog(@"initialize share");
}

Share::~Share() {
    if (instance == this) {
        instance = NULL;
    }
    NSLog(@"deinitialize share");
}

Share *Share::get_singleton() {
    return instance;
};


void Share::_bind_methods() {
    ADD_SIGNAL(MethodInfo("share_error", PropertyInfo(Variant::STRING, "error_code")));
    ADD_SIGNAL(MethodInfo("saved_to_gallery"));

    ClassDB::bind_method("shareText", &Share::shareText);
    ClassDB::bind_method("shareImage", &Share::shareImage);
    ClassDB::bind_method("saveImageToGallery", &Share::saveImageToGallery);
}

void Share::shareText(const String &title, const String &subject, const String &content) {
    NSLog(@"[GodotShare] called shareText()");

    UIViewController *root_controller = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    NSString * shareMessage = [NSString stringWithCString:content.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    NSArray * shareItems = @[shareMessage];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    // iPhone
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [root_controller presentViewController:avc animated:YES completion:nil];
    }
    // iPad
    else {
        avc.modalPresentationStyle = UIModalPresentationPopover;
        avc.popoverPresentationController.sourceView = root_controller.view;
        avc.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(root_controller.view.bounds), CGRectGetMidY(root_controller.view.bounds),0,0);
        avc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(0);
        [root_controller presentViewController:avc animated:YES completion:nil];
    }
}

void Share::shareImage(const String &image_path, const String &title, const String &subject, const String &content) {
    NSLog(@"[GodotShare] called shareImage()");

    UIViewController *root_controller = [[UIApplication sharedApplication] delegate].window.rootViewController;
    
    NSString * shareMessage = [NSString stringWithCString:content.utf8().get_data() encoding:NSUTF8StringEncoding];
    NSString * imagePath = [NSString stringWithCString:image_path.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (image == nil) {
        emit_signal("share_error", "ERROR_IMAGE_FILE");
        return;
    }
    
    NSArray * shareItems = @[shareMessage, image];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    // iPhone
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        [root_controller presentViewController:avc animated:YES completion:nil];
    }
    // iPad
    else {
        // Change Rect to position Popover
        avc.modalPresentationStyle = UIModalPresentationPopover;
        avc.popoverPresentationController.sourceView = root_controller.view;
        avc.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(root_controller.view.bounds), CGRectGetMidY(root_controller.view.bounds),0,0);
        avc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(0);
        [root_controller presentViewController:avc animated:YES completion:nil];
    }
}

void Share::saveImageToGallery(const String &image_path) {
    NSLog(@"[GodotShare] called saveImageToGallery()");

    [ImageSaver saveImage:image_path];
}


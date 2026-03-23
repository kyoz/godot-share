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
    
    // 1. Chuyển đổi toàn bộ string từ Godot sang NSString
    NSString *shareMessage = [NSString stringWithCString:content.utf8().get_data() encoding:NSUTF8StringEncoding];
    NSString *shareTitle   = [NSString stringWithCString:title.utf8().get_data() encoding:NSUTF8StringEncoding];
    NSString *shareSubject = [NSString stringWithCString:subject.utf8().get_data() encoding:NSUTF8StringEncoding];
    NSString *imagePath   = [NSString stringWithCString:image_path.utf8().get_data() encoding:NSUTF8StringEncoding];
    
    // 2. Load ảnh từ path
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    if (image == nil) {
        NSLog(@"[GodotShare] Image is NIL at path: %@", imagePath);
        emit_signal("share_error", "ERROR_IMAGE_FILE");
        return;
    }

    // 3. Đẩy việc hiển thị UI lên Main Thread để tránh crash
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        
        // Lấy Window chuẩn cho iOS 13+ và Fallback cho máy cổ (iPhone 5S)
        if (@available(iOS 13.0, *)) {
            for (UIScene* scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    window = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        }
        
        if (!window) {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (!window || !window.rootViewController) {
            NSLog(@"[GodotShare] Could not find rootViewController!");
            return;
        }

        UIViewController *root_controller = window.rootViewController;
        
        // Tìm Controller đang hiển thị trên cùng (tránh bị đè bởi popup khác)
        while (root_controller.presentedViewController) {
            root_controller = root_controller.presentedViewController;
        }

        // 4. Chuẩn bị các item để share
        // Thường shareItems gồm Message và Image là đủ cho hầu hết các App
        NSArray *shareItems = @[shareMessage, image];
        
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];

        // 5. Gán Title và Subject (Cực kỳ quan trọng khi share qua Email/Notes)
        if (shareSubject.length > 0) {
            [avc setValue:shareSubject forKey:@"subject"];
        }
        
        // Nếu title khác subject thì có thể dùng title làm tiêu đề chung
        if (shareTitle.length > 0 && ![shareTitle isEqualToString:shareSubject]) {
            // Một số app dùng key "title", một số dùng "header"
            [avc setValue:shareTitle forKey:@"title"];
        }

        // 6. Hiển thị bảng Share
        if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            // iPhone hiện từ dưới lên
            [root_controller presentViewController:avc animated:YES completion:nil];
        } else {
            // iPad hiện dạng Popover ở giữa màn hình (tránh crash)
            avc.modalPresentationStyle = UIModalPresentationPopover;
            avc.popoverPresentationController.sourceView = root_controller.view;
            avc.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(root_controller.view.bounds), CGRectGetMidY(root_controller.view.bounds), 0, 0);
            avc.popoverPresentationController.permittedArrowDirections = 0; // Không hiện mũi tên chỉ trỏ
            [root_controller presentViewController:avc animated:YES completion:nil];
        }
    });
}

void Share::saveImageToGallery(const String &image_path) {
    NSLog(@"[GodotShare] called saveImageToGallery()");

    [ImageSaver saveImage:image_path];
}


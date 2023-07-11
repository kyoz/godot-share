//
//  share.h
//  share
//
//  Created by Kyoz on 11/07/2023.
//

#ifndef SHARE_H
#define SHARE_H

#ifdef VERSION_4_0
#include "core/object/object.h"
#endif

#ifdef VERSION_3_X
#include "core/object.h"
#endif

class Share : public Object {

    GDCLASS(Share, Object);

    static Share *instance;

public:
    void shareText(const String &title, const String &subject, const String &content);
    void shareImage(const String &image_path, const String &title, const String &subject, const String &content);
    void saveImageToGallery(const String &image_path);

    static Share *get_singleton();
    
    Share();
    ~Share();

protected:
    static void _bind_methods();
};

#endif

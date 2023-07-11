//
//  share_module.m
//  share
//
//  Created by Kyoz on 11/07/2023.
//


#ifdef VERSION_4_0
#include "core/config/engine.h"
#else
#include "core/engine.h"
#endif


#include "share_module.h"

Share * share;

void register_share_types() {
    share = memnew(Share);
    Engine::get_singleton()->add_singleton(Engine::Singleton("Share", share));
};

void unregister_share_types() {
    if (share) {
        memdelete(share);
    }
}

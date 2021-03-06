/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "NSLayoutManager+CKPlatform.h"

// Added to SDK in 10.11. Will crash on older OS, but we're not using this now.
#if __MAC_OS_X_VERSION_MAX_ALLOWED < 101100

@implementation NSLayoutManager (CKPlatform)

- (void)enumerateLineFragmentsForGlyphRange:(NSRange)glyphRange usingBlock:(void (^)(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop))block
{
  NSAssert(0, @"Unimplemented");
}

@end

#endif
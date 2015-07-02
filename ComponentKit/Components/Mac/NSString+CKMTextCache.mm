/*
 *  Copyright (c) 2014-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import <ComponentKit/CKCacheImpl.h>

#import "CKEqualityHashHelpers.h"

#import "NSString+CKMTextCache.h"

static inline BOOL _objectsEqual(id<NSObject> obj1, id<NSObject> obj2)
{
  return obj1 == obj2 ? YES : [obj1 isEqual:obj2];
}

struct NSStringDrawingKey
{
  NSString *string;
  CGSize constrainedSize;
  NSStringDrawingOptions options;
  NSDictionary *attributes;

  NSStringDrawingKey(NSString *string, CGSize constrainedSize, NSStringDrawingOptions options, NSDictionary *attributes) : string(string), constrainedSize(constrainedSize), options(options), attributes(attributes) {
    hash = _hash();
  };

  size_t hash;

  bool operator == (const NSStringDrawingKey &other) const {
    // These comparisons are in a specific order to reduce the overall cost of this function.
    return hash == other.hash
    && CGSizeEqualToSize(constrainedSize, other.constrainedSize)
    && _objectsEqual(attributes, other.attributes);
  }

  size_t _hash() const
  {
    NSUInteger subhashes[] = {
      [string hash],
      std::hash<CGFloat>()(constrainedSize.width),
      std::hash<CGFloat>()(constrainedSize.height),
      std::hash<NSStringDrawingOptions>()(options),
      [attributes hash],
    };
    return CKIntegerArrayHash(subhashes, sizeof(subhashes) / sizeof(subhashes[0]));
  }


};

struct KeyHasher {
  size_t operator()(const NSStringDrawingKey &k) const
  {
    return k.hash;
  }
};


static CGRect boundsForText(NSStringDrawingKey text)
{
  static CK::ConcurrentCacheImpl<NSStringDrawingKey, CGRect, KeyHasher> *cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = new CK::ConcurrentCacheImpl<NSStringDrawingKey, CGRect, KeyHasher>();
  });


  CGRect bounds = cache->find(text, CGRectNull);
  if (CGRectIsNull(bounds)) {
    bounds = [text.string boundingRectWithSize:text.constrainedSize options:text.options attributes:text.attributes];
    NSUInteger cost = 2 * text.string.length + 4 * text.attributes.count;
    cache->insert(text, bounds, cost);
  }

  return bounds;
}

@implementation NSString (CKMTextCache)

- (CGRect)ckm_boundingRectWithSize:(NSSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes
{
  return boundsForText({self, size, options, attributes});
}

@end

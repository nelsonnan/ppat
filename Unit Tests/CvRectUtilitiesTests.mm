//
//  CvRectUtilitiesTests.mm
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/29/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import "CvRectUtilitiesTests.h"
#import "opencv2/opencv.hpp"
#import "Bvh.hpp"


@implementation CvRectUtilitiesTests

- (void)testBVH
{
    CvRect rect1 = cvRect(0, 0, 100, 100);
    Bvh bvh;
    try {
        bvh.getAnyRect();
        STFail(nil);
    } catch (...) { }
    bvh.insert(rect1);
    STAssertEquals(bvh.getAnyRect(), rect1, nil);
    
    bvh = Bvh();
    CvRect rect2 = cvRect(200, 200, 100, 100);
    bvh.insert(rect1);
    bvh.insert(rect2);
    STAssertTrue(bvh.memberContains(50, 50), nil);
    STAssertFalse(bvh.memberContains(150, 150), nil);
    STAssertFalse(bvh.memberContains(1000, 1000), nil);
    
    std::vector<CvRect> rects;
    bvh.allMembersIntersecting(cvRect(-100, -100, 1000, 1000), rects);
    STAssertEquals(rects.size(), (size_t)2, nil);
    bvh.insert(cvRect(10, 10, 10, 10));
    rects.clear();
    bvh.allMembersIntersecting(cvRect(-100, -100, 1000, 1000), rects);
    STAssertEquals(rects.size(), (size_t)3, nil);
    
    CvRect rectFar = cvRect(10000, 10000, 10, 10);
    bvh.insert(rectFar);
    rects.clear();
    bvh.allMembersIntersecting(cvRect(-100, -100, 1000, 1000), rects, true);    // remove true
    STAssertEquals(rects.size(), (size_t)3, nil);
    rects.clear();
    bvh.allMembersIntersecting(cvRect(-100, -100, 1000, 1000), rects, true);    // remove true
    STAssertEquals(rects.size(), (size_t)0, nil);
    
    STAssertEquals(bvh.getAnyRect(true), rectFar, nil);
    
    rects.clear();
    bvh.allMembersContaining(rectFar.x, rectFar.y, rects, true);    // remove true
    STAssertTrue(bvh.empty(), nil);
}

@end

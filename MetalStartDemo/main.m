//
//  main.m
//  MetalStartDemo
//
//  Created by liqinghua on 13.4.23.
//

#import <Foundation/Foundation.h>
#import "MetalAdder.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        MetalAdder *adder = [[MetalAdder alloc] initWithDevice:device];
        //初始化数据数据
        [adder prepareData];
        //开始使用GPU计算相加
        [adder sendComputeCommand];
    }
    return 0;
}
